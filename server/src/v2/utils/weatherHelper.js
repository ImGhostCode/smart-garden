const db = require("../models/database");
const WeatherClient = require("../services/weatherClientService");
const { durationToMillis } = require("./helpers");

const getMockWeatherData = () => ({
    rain: {
        mm: parseFloat(process.env.DEFAULT_WEATHER_RAIN) || 2.5,
        scale_factor: 0.8
    },
    average_temperature: {
        celsius: parseFloat(process.env.DEFAULT_WEATHER_TEMP) || 22.5,
        scale_factor: 1.0
    }
});

const getWeatherData = async (waterSchedule) => {

    const weatherData = {};
    try {
        if (waterSchedule.hasRainControl() && waterSchedule.weather_control.rain_control.client_id != null) {
            const rainMM = await getRainData(waterSchedule);
            weatherData.rain = { mm: rainMM, scale_factor: waterSchedule.weather_control.rain_control.invertedScaleDownOnly(rainMM) };
        }

        if (waterSchedule.hasTemperatureControl() && waterSchedule.weather_control.temperature_control.client_id != null) {
            const celsius = await getTemperatureData(waterSchedule);
            weatherData.temperature = { celsius: celsius, scale_factor: waterSchedule.weather_control.temperature_control.scale(celsius) };
        }

    } catch (error) {
        console.error('Error getting weather data:', error);
        // throw new Error('Unable to get weather data from weather clients');
    }

    return weatherData;
};

const getRainData = async (waterSchedule) => {
    try {
        const weatherClient = await db.weatherClientConfigs.getById(waterSchedule.weather_control.rain_control.client_id);
        if (weatherClient == null) {
            throw new Error(`Error getting WeatherClient RainControl: ${waterSchedule._id.toString()}`);
        }
        const totalRain = await new WeatherClient(weatherClient).getTotalRain(durationToMillis(waterSchedule.interval));
        return totalRain;
    } catch (error) {
        console.error('Error getting rain data:', error);
        // throw new Error('Unable to get rain data from weather client');
    }
};

const getTemperatureData = async (waterSchedule) => {
    try {
        const weatherClient = await db.weatherClientConfigs.getById(waterSchedule.weather_control.temperature_control.client_id);
        if (weatherClient == null) {
            throw new Error(`Error getting WeatherClient for TemperatureControl: ${waterSchedule._id.toString()}`);
        }
        const totalRain = await new WeatherClient(weatherClient).getAverageHighTemperature(durationToMillis(waterSchedule.interval));
        return totalRain;
    } catch (error) {
        console.error('Error getting temperature data:', error);
        // throw new Error('Unable to get average high temperature from weather client');
    }
};

module.exports = {
    getWeatherData,
    getMockWeatherData
};