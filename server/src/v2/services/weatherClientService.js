const FakeWeatherClient = require("../utils/fakeWeatherClient");
const NetatmoClient = require("../utils/netatmoWeatherClient");
const db = require("../models/database");
const { ApiError } = require("../utils/apiResponse");

// Global cache for all WeatherClient instances
const globalCache = new Map();

class WeatherClient {
    constructor(config
        // , storageCallback = () => { }
    ) {
        this.config = config;
        // this.storageCallback = storageCallback;
        this.cache = globalCache; // Use global cache instead of instance cache
        this.cacheTTL = 5 * 60 * 1000; // 5 minutes

        switch (config.type) {
            case 'netatmo':
                this.client = new NetatmoClient(config.options, async updatedConfig => {
                    console.log('Updated config:', updatedConfig);
                    await db.weatherClientConfigs.updateById(this.config._id, {
                        type: 'netatmo',
                        options: updatedConfig
                    });
                    this.config.options = updatedConfig;
                });
                break;
            case 'fake':
                this.client = new FakeWeatherClient(config.options);
                break;
            default:
                throw new ApiError(400, `Invalid client type: ${config.type}`);
        }
    }

    _getCache(key) {
        const entry = this.cache.get(key);
        if (!entry) return null;

        const { value, timestamp } = entry;
        if (Date.now() - timestamp > this.cacheTTL) {
            this.cache.delete(key);
            return null;
        }
        return value;
    }

    _setCache(key, value) {
        this.cache.set(key, { value, timestamp: Date.now() });
    }

    clearCacheById(id) {
        for (const key of this.cache.keys()) {
            if (key.endsWith(`_${id}`)) {
                this.cache.delete(key);
            }
        }
    }

    async getTotalRain(sinceMs) {
        const cacheKey = `total_rain_${sinceMs}_${this.config._id}`;
        const cached = this._getCache(cacheKey);
        if (cached !== null) {
            this._recordMetric('getTotalRain', true);
            return cached;
        }

        const result = await this.client.getTotalRain(sinceMs);
        this._setCache(cacheKey, result);
        this._recordMetric('getTotalRain', false);
        return result;
    }

    async getAverageHighTemperature(sinceMs) {
        const cacheKey = `avg_temp_${sinceMs}_${this.config._id}`;
        const cached = this._getCache(cacheKey);
        if (cached !== null) {
            this._recordMetric('getAverageHighTemperature', true);
            return cached;
        }

        const result = await this.client.getAverageHighTemperature(sinceMs);
        this._setCache(cacheKey, result);
        this._recordMetric('getAverageHighTemperature', false);
        return result;
    }

    _recordMetric(functionName, cached) {
        // Placeholder for Prometheus-like metric tracking
        console.log(`[Metric] ${functionName} - cached: ${cached}`);
    }

    resetCache() {
        this.cache.clear();
    }

    // Clean up expired cache entries
    static cleanupGlobalCache() {
        const now = Date.now();
        const cacheTTL = 5 * 60 * 1000; // 5 minutes

        for (const [key, entry] of globalCache.entries()) {
            if (now - entry.timestamp > cacheTTL) {
                globalCache.delete(key);
            }
        }
    }
}

module.exports = WeatherClient;