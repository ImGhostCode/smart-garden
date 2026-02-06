const { ApiError } = require("./apiResponse");

class FakeWeatherClient {
    constructor(options) {
        this.config = {
            rainMM: options.rain_mm || 0,
            rainIntervalMs: options.rain_interval_ms || 60 * 60 * 1000, // Default 1 hour
            avgHighTemperature: options.avg_high_temperature || 0,
            error: options.error || ''
        };

    }

    getTotalRain(sinceMs) {
        if (this.config.error) {
            throw new ApiError(400, this.config.error);
        }
        const numIntervals = sinceMs / this.config.rainIntervalMs;
        return numIntervals * this.config.rainMM;
    }

    getAverageHighTemperature() {
        if (this.config.error) {
            throw new ApiError(400, this.config.error);
        }

        return this.config.avgHighTemperature;
    }
}

module.exports = FakeWeatherClient;