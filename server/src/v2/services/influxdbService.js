const { InfluxDB, Point } = require('@influxdata/influxdb-client');

/*
Measurement: water
- Tags:
    status = "start" | "complete"
    zone = zone position number (0, 1, 2...)
    id = event ID (unique identifier for this watering event)
    zone_id = zone's unique ID
- Fields:
    millis = duration in milliseconds (0 for start, actual duration for complete)

Measurement: light
- Tags:
    garden = garden topic prefix (e.g., "front-yard")
- Fields:
    state = 0 (OFF) or 1 (ON)

Measurement: health
- Tags:
- Fields:
    garden = garden topic prefix (e.g., "front-yard")

Measurement: temperature
- Tags:
- Fields: 
    value: temperature value

Measurement: humidity
- Tags:
- Fields: 
    value: humidity value

Measurement: logs
- Tags:
- Fields: 
    message: message from controller

Measurement: health
- Tags:
- Fields: 
    garden: prefix topic

Measurement: water_command (due to name_suffix = "_command")
- Tags:
    id = command ID
    zone_id = target zone ID
    position = zone position
    source = command source
    topic = full MQTT topic (auto-added by Telegraf)
- Fields:
    duration = duration in milliseconds

Measurement: light_command (due to name_suffix = "_command")
- Tags:
    topic = full MQTT topic (auto-added by Telegraf)
- Fields:
    state = command state (as string)
*/

/*
    healthQueryTemplate = `from(bucket: "{{.Bucket}}")
|> range(start: -{{.Start}})
|> filter(fn: (r) => r["_measurement"] == "health")
|> filter(fn: (r) => r["_field"] == "garden")
|> filter(fn: (r) => r["_value"] == "{{.TopicPrefix}}")
|> drop(columns: ["host"])
|> last()`
    waterHistoryQueryTemplate = `
waterCommands = from(bucket: "{{.Bucket}}")
  |> range(start: -{{.Start}})
  |> filter(fn: (r) => r._measurement == "water_command")
  |> filter(fn: (r) => r["topic"] == "{{.TopicPrefix}}/command/water")
  |> filter(fn: (r) => r["zone_id"] == "{{.ZoneID}}")
  |> keep(columns: ["_time", "zone_id", "id", "_value", "source"])
  |> set(key: "command", value: "true")

waterEvents = from(bucket: "garden")
  |> range(start: -{{.Start}})
  |> filter(fn: (r) => r._measurement == "water")
  |> filter(fn: (r) => r["topic"] == "{{.TopicPrefix}}/data/water")
  |> filter(fn: (r) => r["zone_id"] == "{{.ZoneID}}")
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
    {{- if .Limit }}
    |> limit(n: {{.Limit}})
    {{- end }}
    |> yield(name: "waterHistory")`
        temperatureAndHumidityQueryTemplate = `from(bucket: "{{.Bucket}}")
    |> range(start: -{{.Start}})
    |> filter(fn: (r) => r["_measurement"] == "temperature" or r["_measurement"] == "humidity")
    |> filter(fn: (r) => r["_field"] == "value")
    |> filter(fn: (r) => r["topic"] == "{{.TopicPrefix}}/data/temperature" or r["topic"] == "{{.TopicPrefix}}/data/humidity")
    |> drop(columns: ["host"])
    |> mean()`
)

*/

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
    async writeHealthData(topicPrefix) {
        try {
            const point = new Point('health')
                .tag('topic', `${topicPrefix}/data/health`)
                .stringField('garden', topicPrefix)

            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote health data for garden: ${topicPrefix}`);
        } catch (error) {
            console.error('Error writing health data:', error);
        }
    }

    async writeLightData(topicPrefix, state) {
        try {
            const point = new Point('light')
                .tag('topic', `${topicPrefix}/data/light`)
                .tag('garden', topicPrefix)
                .stringField('state', state);
            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote light data for garden: ${topicPrefix}, state: ${state || 'TOGGLE'}`);
        } catch (error) {
            console.error('Error writing light data:', error);
        }
    }

    // Write temperature data
    async writeTemperatureData(topicPrefix, temperature) {
        try {
            const point = new Point('temperature')
                .tag('topic', `${topicPrefix}/data/temperature`)
                .floatField('value', parseFloat(temperature))
                ;
            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote temperature data for garden: ${topicPrefix}`);
        } catch (error) {
            console.error('Error writing temperature data:', error);
        }
    }

    // Write humidity data
    async writeHumidityData(topicPrefix, humidity) {
        try {
            const point = new Point('humidity')
                .tag('topic', `${topicPrefix}/data/humidity`)
                .floatField('value', parseFloat(humidity))

            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote humidity data for garden: ${topicPrefix}`);
        } catch (error) {
            console.error('Error writing humidity data:', error);
        }
    }

    // Write water event from ESP32
    async writeWaterData(topicPrefix, status, zone, id, zoneId, duration) {
        try {
            const point = new Point('water')
                .tag('topic', `${topicPrefix}/data/water`)
                .tag('status', status)
                .tag('zone', zone)
                .tag('id', id)
                .tag('zone_id', zoneId)
                .intField('millis', duration);

            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote water data for garden: ${topicPrefix}, zone: ${zoneId}, status: ${status} duration: ${duration}`);
        } catch (error) {
            console.error('Error writing water data:', error);
        }
    }

    // Write water command
    async writeWaterCommand(topicPrefix, duration, id, zoneId, position, source) {
        try {
            const point = new Point('water_command')
                .tag('topic', `${topicPrefix}/command/water`)
                .tag('position', position)
                .tag('id', id)
                .tag('zone_id', zoneId)
                .tag('source', source)
                .intField('duration', duration);
            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote water command for garden: ${topicPrefix}, zone: ${zoneId}, duration: ${duration}`);
        } catch (error) {
            console.error('Error writing water command:', error);
        }
    }

    async writeLogData(topicPrefix, message) {
        try {
            const point = new Point('logs')
                .tag('topic', `${topicPrefix}/data/logs`)
                .stringField('message', message);
            this.writeApi.writePoint(point);
            await this.writeApi.flush();
            console.log(`Wrote log for garden: ${topicPrefix}, message: ${message}`);
        } catch (error) {
            console.error('Error writing log data:', error);
        }
    }

    // Get last contact time for garden
    async getLastContact(topicPrefix, start = '15m') {
        const query = `
      from(bucket: "${this.config.bucket}")
      |> range(start: -${start})
      |> filter(fn: (r) => r["_measurement"] == "health")
      |> filter(fn: (r) => r["_field"] == "garden")
      |> filter(fn: (r) => r["_value"] == "${topicPrefix}")
      |> drop(columns: ["host"])
      |> last()
    `;

        try {
            const results = await this.queryApi.collectRows(query);
            if (results.length > 0) {
                return results[0]._time;
            } else {
                return null;
            }
        } catch (error) {
            console.error('Error querying last contact:', error);
            return null;
        }
    }

    // Get water history for zone
    async getWaterHistory(topicPrefix, start = '24h', zoneId, limit = 5) {
        const query = `
      waterCommands = from(bucket: "${this.config.bucket}")
        |> range(start: -${start})
        |> filter(fn: (r) => r._measurement == "water_command")
        |> filter(fn: (r) => r["topic"] == "${topicPrefix}/command/water")
        |> filter(fn: (r) => r["zone_id"] == "${zoneId}")
        |> keep(columns: ["_time", "zone_id", "id", "_value", "source"])
        |> set(key: "command", value: "true")

      waterEvents = from(bucket: "${this.config.bucket}")
        |> range(start: -${start})
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
            identity: {event_id: "", zone_id: "", status: "", source: "", sent_at: time(v:0), started_at: time(v:0), completed_at: time(v:0), _value: 0}
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
    async getTemperatureAndHumidity(topicPrefix, start = '15m') {
        const query = `
      from(bucket: "${this.config.bucket}")
      |> range(start: -${start})
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

    // // Helper function to parse duration string to milliseconds
    // parseDurationToMs(duration) {
    //     if (typeof duration === 'number') return duration;
    //     if (typeof duration !== 'string') return 0;

    //     const match = duration.match(/^(\d+(?:\.\d+)?)(ms|s|m|h)?$/);
    //     if (!match) return 0;

    //     const value = parseFloat(match[1]);
    //     const unit = match[2] || 'ms';

    //     switch (unit) {
    //         case 'ms': return value;
    //         case 's': return value * 1000;
    //         case 'm': return value * 60 * 1000;
    //         case 'h': return value * 60 * 60 * 1000;
    //         default: return value;
    //     }
    // }

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