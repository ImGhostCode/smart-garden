const { ApiError } = require("./apiResponse");
const { durationToMillis } = require("./helpers");

class FakeClient {
    constructor(options) {
        this.config = {
            rainMM: options.rain_mm || 0,
            rainIntervalStr: options.rain_interval || '1h',
            avgHighTemperature: options.avg_high_temperature || 0,
            error: options.error || ''
        };

        this.rainInterval = durationToMillis(this.config.rainIntervalStr);
        if (this.rainInterval === null) {
            throw new ApiError(400, `Invalid rain interval: ${this.config.rainIntervalStr}`);
        }
    }

    getTotalRain(sinceMs) {
        if (this.config.error) {
            throw new ApiError(400, this.config.error);
        }
        const numIntervals = sinceMs / this.rainInterval;
        return numIntervals * this.config.rainMM;
    }

    getAverageHighTemperature() {
        if (this.config.error) {
            throw new ApiError(400, this.config.error);
        }

        return this.config.avgHighTemperature;
    }
}

module.exports = FakeClient;