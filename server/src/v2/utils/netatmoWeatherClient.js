const { ApiError } = require("./apiResponse");

class NetatmoClient {
    constructor(options, storageCallback = () => { }) {
        this.baseURI = process.env.NETATMO_BASE_URL || 'https://app.netatmo.net';
        this.config = options;
        this.storageCallback = storageCallback;

        if (!this.config.authentication || !this.config.client_id || !this.config.client_secret) {
            throw new ApiError(400, 'Authentication and client credentials are required');
        }

        if (!this.config.station_id || !this.config.rain_module_id || !this.config.outdoor_module_id) {
            this.setDeviceIDs();
        }
    }

    async setDeviceIDs() {
        const data = await this.getStationData();
        console.log(`Fetched station data: ${JSON.stringify(data)}`);

        const station = data.body.devices.find(
            s => s.station_name === this.config.station_name
        );
        if (!station) throw new ApiError(404, `No station found with name "${this.config.station_name}"`);
        this.config.station_id = station._id;

        for (const module of station.modules) {
            if (!this.config.rain_module_id && module.type === this.config.rain_module_type) {
                this.config.rain_module_id = module._id;
            }
            if (!this.config.outdoor_module_id && module.type === this.config.outdoor_module_type) {
                this.config.outdoor_module_id = module._id;
            }
        }

        if (!this.config.rain_module_id) {
            throw new ApiError(404, `No rain module found with name "${this.config.rain_module_name}"`);
        }
        if (!this.config.outdoor_module_id) {
            throw new ApiError(404, `No outdoor module found with name "${this.config.outdoor_module_name}"`);
        }

        console.log(`Set device IDs: station_id=${this.config.station_id}, rain_module_id=${this.config.rain_module_id}, outdoor_module_id=${this.config.outdoor_module_id}`);
    }

    async getStationData() {
        await this.refreshToken();

        const params = new URLSearchParams({
            get_favorites: 'false',
        });
        if (this.config.station_id) {
            params.append('device_id', this.config.station_id);
        }

        const response = await fetch(`${this.baseURI}/api/getstationsdata?${params.toString()}`, {
            method: 'GET',
            headers: {
                // Authorization: `Bearer ${this.config.authentication.access_token}`,
                Accept: 'application/json',
            },
        });

        if (!response.ok) {
            throw new ApiError(response.status, `Failed to fetch station data: ${response.status}`);
        }

        return await response.json();
    }

    async refreshToken() {
        const now = new Date();
        const expiry = new Date(Date.parse(this.config.authentication.expiration_date) || 0);

        if (now < expiry) {
            console.log('Token is still valid, no refresh needed');
            return;
        }

        console.log('Token expired, refreshing...');

        const body = new URLSearchParams({
            grant_type: 'refresh_token',
            refresh_token: this.config.authentication.refresh_token,
            client_id: this.config.client_id,
            client_secret: this.config.client_secret,
        });

        const response = await fetch(`${this.baseURI}/oauth2/token`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body,
        });

        const data = await response.json();
        if (!response.ok) {
            throw new ApiError(response.status, `Token refresh failed: ${response.status} - ${JSON.stringify(data)}`);
        }

        const newExpirationDate = new Date(Date.now() + data.expires_in * 1000).toISOString();

        this.config.authentication = {
            ...this.config.authentication,
            access_token: data.access_token,
            refresh_token: data.refresh_token,
            // expires_in: data.expires_in,
            expiration_date: newExpirationDate,
        };

        await this.storageCallback({
            station_id: this.config.station_id,
            station_name: this.config.station_name,
            rain_module_id: this.config.rain_module_id,
            rain_module_type: this.config.rain_module_type,
            outdoor_module_id: this.config.outdoor_module_id,
            outdoor_module_type: this.config.outdoor_module_type,
            authentication: this.config.authentication,
            client_id: this.config.client_id,
            client_secret: this.config.client_secret,
        });
    }

    async getMeasure(dataType, scale, beginDate, endDate = null) {
        await this.refreshToken();

        const moduleID = dataType.includes('rain')
            ? this.config.rain_module_id
            : this.config.outdoor_module_id;

        const body = new URLSearchParams({
            device_id: this.config.station_id,
            module_id: moduleID,
            scale,
            optimize: 'false',
            // real_time: 'false',
            type: dataType,
            date_begin: Math.floor(beginDate.getTime() / 1000).toString(),
        });

        if (endDate) {
            body.append('date_end', Math.floor(endDate.getTime() / 1000).toString());
        }

        const url = `${this.baseURI}/api/getmeasure`;

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                "Authorization": `Bearer ${this.config.authentication.access_token}`,
                "Content-Type": 'application/json',
            },
            // body,    
            body: JSON.stringify(Object.fromEntries(body)),
        });

        const data = await response.json();
        if (!response.ok) {
            throw new ApiError(response.status, `Unexpected status ${response.status} with body: ${JSON.stringify(data)}`);
        }
        console.log(`Fetched measures: ${JSON.stringify(data)}`);
        const result = {};

        for (const [epoch, values] of Object.entries(data.body)) {
            const timestamp = new Date(parseInt(epoch, 10) * 1000);
            result[timestamp.toISOString()] = values[0];
        }

        return {
            data: result,
            total: () => Object.values(result).reduce((sum, val) => sum + val, 0),
            average: () => {
                const values = Object.values(result);
                return values.length ? values.reduce((sum, val) => sum + val, 0) / values.length : 0;
            },
        };
    }

    async getTotalRain(sinceMs) {
        const minRainIntervalMs = 24 * 60 * 60 * 1000; // 24 hours

        if (sinceMs < minRainIntervalMs) {
            sinceMs = minRainIntervalMs;
        }
        const beginDate = new Date(Date.now() - sinceMs);
        const rainData = await this.getMeasure('sum_rain', '1day', beginDate);

        return rainData.total();
    }

    async getAverageHighTemperature(sinceMs) {
        const minTempIntervalMs = 72 * 60 * 60 * 1000; // 72 hours

        if (sinceMs < minTempIntervalMs) {
            sinceMs = minTempIntervalMs;
        }

        const now = new Date();
        const beginDate = new Date(now.getTime() - sinceMs);
        beginDate.setHours(23, 59, 59, 0);
        beginDate.setDate(beginDate.getDate() - 1);

        const endDate = new Date();
        endDate.setHours(23, 59, 59, 0);
        endDate.setDate(endDate.getDate() - 1);

        const temperatureData = await this.getMeasure('max_temp', '1day', beginDate, endDate);

        return temperatureData.average();
    }

}
module.exports = NetatmoClient;