const { InfluxDB, Point } = require('@influxdata/influxdb-client');

class InfluxDBService {
    constructor() {
        this.config = null;
        this.client = null;
        this.writeApi = null;
        this.queryApi = null;
    }

    connect(config) {
        this.config = config;
        this.client = new InfluxDB({
            url: config.url,
            token: config.token
        });
        this.writeApi = this.client.getWriteApi(config.org, config.bucket, 'ms');
        this.queryApi = this.client.getQueryApi(config.org);
    }

    // Write health data
    writeHealthData(topicPrefix) {
        try {
            const point = new Point('health')
                .tag('topic', `${topicPrefix}/data/health`)
                .stringField('garden', topicPrefix)
                .timestamp(new Date());

            this.writeApi.writePoint(point);
            this.writeApi.flush();
            console.log(`Wrote health data for garden: ${topicPrefix}`);
        } catch (error) {
            console.error('Error writing health data:', error);
        }
    }

    // Write temperature data
    writeTemperatureData(topicPrefix, temperature) {
        const point = new Point('temperature')
            .tag('topic', `${topicPrefix}/data/temperature`)
            .floatField('value', parseFloat(temperature))
            .timestamp(new Date());

        this.writeApi.writePoint(point);
    }

    // Write humidity data
    writeHumidityData(topicPrefix, humidity) {
        const point = new Point('humidity')
            .tag('topic', `${topicPrefix}/data/humidity`)
            .floatField('value', parseFloat(humidity))
            .timestamp(new Date());

        this.writeApi.writePoint(point);
    }

    // Write water command
    writeWaterCommand(topicPrefix, zoneId, duration, eventId, source = 'api') {
        const point = new Point('water_command')
            .tag('topic', `${topicPrefix}/command/water`)
            .tag('zone_id', zoneId.toString())
            .stringField('id', eventId)
            .floatField('value', this.parseDurationToMs(duration))
            .stringField('source', source)
            .timestamp(new Date());

        this.writeApi.writePoint(point);
    }

    // Write water event from ESP32
    writeWaterEvent(topicPrefix, zoneId, duration, eventId, status) {
        const point = new Point('water')
            .tag('topic', `${topicPrefix}/data/water`)
            .tag('zone_id', zoneId.toString())
            .stringField('id', eventId)
            .stringField('status', status)
            .floatField('value', this.parseDurationToMs(duration))
            .timestamp(new Date());

        this.writeApi.writePoint(point);
    }

    // Get last contact time for garden
    async getLastContact(topicPrefix) {
        const query = `
      from(bucket: "${this.config.bucket}")
      |> range(start: -15m)
      |> filter(fn: (r) => r["_measurement"] == "health")
      |> filter(fn: (r) => r["_field"] == "garden")
      |> filter(fn: (r) => r["_value"] == "${topicPrefix}")
      |> drop(columns: ["host"])
      |> last()
    `;

        try {
            const results = await this.queryApi.collectRows(query);
            return results.length > 0 ? new Date(results[0]._time) : null;
        } catch (error) {
            console.error('Error querying last contact:', error);
            return null;
        }
    }

    // Get water history for zone
    async getWaterHistory(topicPrefix, zoneId, timeRange = '72h', limit = 0) {
        const query = `
      waterCommands = from(bucket: "${this.config.bucket}")
        |> range(start: -${timeRange})
        |> filter(fn: (r) => r._measurement == "water_command")
        |> filter(fn: (r) => r["topic"] == "${topicPrefix}/command/water")
        |> filter(fn: (r) => r["zone_id"] == "${zoneId}")
        |> keep(columns: ["_time", "zone_id", "id", "_value", "source"])
        |> set(key: "command", value: "true")

      waterEvents = from(bucket: "${this.config.bucket}")
        |> range(start: -${timeRange})
        |> filter(fn: (r) => r._measurement == "water")
        |> filter(fn: (r) => r["topic"] == "${topicPrefix}/data/water")
        |> filter(fn: (r) => r["zone_id"] == "${zoneId}")
        |> keep(columns: ["_time", "zone_id", "id", "status", "_value"])

      union(tables: [waterCommands, waterEvents])
        |> group(columns: ["zone_id", "id"])
        |> sort(columns: ["_time"], desc: false)
        |> reduce(
            fn: (r, accumulator) => ({
              event_id: r.id,
              zone_id: r.zone_id,
              status: if exists r.status then r.status else "sent",
              source: if exists r.source then r.source else accumulator.source,
              _value: if r.status == "start" then accumulator._value else r._value,
              sent_at: if exists r.command then r._time else accumulator.sent_at,
              started_at: if r.status == "start" then r._time else accumulator.started_at,
              completed_at: if r.status == "complete" then r._time else accumulator.completed_at,
            }),
            identity: {event_id: "", zone_id: "", status: "", source: "", sent_at: time(v:0), started_at: time(v:0), completed_at: time(v:0), _value: 0.0}
          )
        ${limit > 0 ? `|> limit(n: ${limit})` : ''}
        |> yield(name: "waterHistory")
    `;

        try {
            const results = await this.queryApi.collectRows(query);
            return results.map(row => ({
                event_id: row.event_id,
                zone_id: row.zone_id,
                status: row.status,
                source: row.source,
                duration: `${row._value}ms`,
                sent_at: row.sent_at,
                started_at: row.started_at,
                completed_at: row.completed_at,
                record_time: row.completed_at || row.started_at || row.sent_at
            }));
        } catch (error) {
            console.error('Error querying water history:', error);
            return [];
        }
    }

    // Get temperature and humidity averages
    async getTemperatureAndHumidity(topicPrefix) {
        const query = `
      from(bucket: "${this.config.bucket}")
      |> range(start: -15m)
      |> filter(fn: (r) => r["_measurement"] == "temperature" or r["_measurement"] == "humidity")
      |> filter(fn: (r) => r["_field"] == "value")
      |> filter(fn: (r) => r["topic"] == "${topicPrefix}/data/temperature" or r["topic"] == "${topicPrefix}/data/humidity")
      |> drop(columns: ["host"])
      |> mean()
    `;

        try {
            const results = await this.queryApi.collectRows(query);
            let temperature = null;
            let humidity = null;

            results.forEach(row => {
                if (row._measurement === 'temperature') {
                    temperature = row._value;
                } else if (row._measurement === 'humidity') {
                    humidity = row._value;
                }
            });

            return { temperature, humidity };
        } catch (error) {
            console.error('Error querying temperature and humidity:', error);
            return { temperature: null, humidity: null };
        }
    }

    // Helper function to parse duration string to milliseconds
    parseDurationToMs(duration) {
        if (typeof duration === 'number') return duration;
        if (typeof duration !== 'string') return 0;

        const match = duration.match(/^(\d+(?:\.\d+)?)(ms|s|m|h)?$/);
        if (!match) return 0;

        const value = parseFloat(match[1]);
        const unit = match[2] || 'ms';

        switch (unit) {
            case 'ms': return value;
            case 's': return value * 1000;
            case 'm': return value * 60 * 1000;
            case 'h': return value * 60 * 60 * 1000;
            default: return value;
        }
    }

    // Flush and close connections
    async close() {
        try {
            await this.writeApi.close();
            this.client = null;
        } catch (error) {
            console.error('Error closing InfluxDB connections:', error);
        }
    }
}

module.exports = new InfluxDBService();