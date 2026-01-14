class Config {
    constructor() {
        this.minWaterDuration = process.env.MIN_WATER_DURATION_MS ? parseInt(process.env.MIN_WATER_DURATION_MS) : 60000; // 1 minute
        this.maxWaterDuration = process.env.MAX_WATER_DURATION_MS ? parseInt(process.env.MAX_WATER_DURATION_MS) : 1 * 24 * 60 * 60 * 1000; // 1 days
        this.minLightDuration = process.env.MIN_LIGHT_DURATION_MS ? parseInt(process.env.MIN_LIGHT_DURATION_MS) : 60000; // 1 minute
        this.maxLightDuration = process.env.MAX_LIGHT_DURATION_MS ? parseInt(process.env.MAX_LIGHT_DURATION_MS) : 24 * 60 * 60 * 1000; // 24 hours
    }
}

module.exports = new Config();