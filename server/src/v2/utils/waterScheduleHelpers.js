const {
    validMonthToNumber,
    intervalToMillis
} = require('./helpers');
const db = require('../models/database');
const WeatherClient = require('../services/weatherClientService');

// Lazy load cronScheduler to avoid circular dependency
let cronScheduler;
const getCronScheduler = () => {
    if (!cronScheduler) {
        cronScheduler = require('../services/cronScheduler');
    }
    return cronScheduler;
};

/**
 * Gets next water time and applies weather scaling
 */
const getNextWaterDetails = async (waterSchedule, excludeWeatherData = false) => {
    const result = {
        time: null,
        duration_ms: waterSchedule.duration_ms,
        water_schedule: {
            id: waterSchedule._id,
            name: waterSchedule.name
        },
        message: 'Next scheduled watering'
    };

    // Try to get next execution time from cron scheduler first
    const cronNextTime = getCronScheduler().getNextExecutionTime(waterSchedule._id.toString());

    if (cronNextTime) {
        result.time = cronNextTime;
        result.message = 'Next scheduled watering (cron)';
    } else {
        result.time = null;
        result.message = 'Water schedule not active';
        return result;
    }

    // Apply weather scaling if enabled
    if (waterSchedule.hasWeatherControl() && !excludeWeatherData) {
        try {
            const scaledDurationMs = await scaleWateringDuration(waterSchedule);
            if (scaledDurationMs !== waterSchedule.duration_ms) {
                result.duration_ms = Math.round(scaledDurationMs);
                const scalePercent = Math.round((scaledDurationMs / waterSchedule.duration_ms) * 100);
                result.message = `Watering adjusted by weather (${scalePercent}%)`;
            }

        } catch (error) {
            console.error('Error applying weather scaling:', error);
        }
    }

    return result;
};

/**
 * Finds the water schedule with the earliest next execution time
 */
const getNextActiveWaterSchedule = async (waterScheduleIds) => {
    if (!waterScheduleIds || waterScheduleIds.length === 0) {
        return null;
    }

    const waterSchedules = [];
    for (const id of waterScheduleIds) {
        try {
            const ws = await db.waterSchedules.getById({ id });
            if (ws && !ws.end_date) {
                waterSchedules.push(ws);
            }
        } catch (error) {
            console.error(`Error getting water schedule ${id}:`, error);
        }
    }

    if (waterSchedules.length === 0) {
        return null;
    }

    // Find the schedule with the earliest next execution time
    let nextSchedule = null;
    let earliestTime = null;

    for (const ws of waterSchedules) {
        const cronNextTime = getCronScheduler().getNextExecutionTime(ws._id.toString());
        if (cronNextTime) {
            if (!earliestTime || cronNextTime < earliestTime) {
                earliestTime = cronNextTime;
                nextSchedule = ws;
            }
        }
    }

    return nextSchedule;
};

const scaleWateringDuration = async (waterSchedule) => {
    let scaleFactor = 1.0;
    if (waterSchedule.hasTemperatureControl() && waterSchedule.weather_control.temperature_control.client_id != null) {
        try {
            const weatherClient = await db.weatherClientConfigs.getById(waterSchedule.weather_control.temperature_control.client_id);
            if (!weatherClient) {
                throw new Error('WeatherClient not found for TemperatureControl');
            }
            const avgHighTemp = await new WeatherClient(weatherClient).getAverageHighTemperature(
                intervalToMillis(waterSchedule.interval)
            );
            const tempScaleFactor = waterSchedule.weather_control.temperature_control.scale(avgHighTemp);
            scaleFactor *= tempScaleFactor;
        } catch (error) {
            console.error('Error getting TemperatureControl scale factor:', error);
            // throw new Error('Failed to get TemperatureControl scale factor');
        }
    }

    if (waterSchedule.hasRainControl() && waterSchedule.weather_control.rain_control.client_id != null) {
        try {
            const weatherClient = await db.weatherClientConfigs.getById(waterSchedule.weather_control.rain_control.client_id);
            if (!weatherClient) {
                throw new Error('WeatherClient not found for RainControl');
            }
            const totalRain = await new WeatherClient(weatherClient).getTotalRain(
                intervalToMillis(waterSchedule.interval)
            );
            const rainScaleFactor = waterSchedule.weather_control.rain_control.invertedScaleDownOnly(totalRain);
            scaleFactor *= rainScaleFactor;
        }
        catch (error) {
            console.error('Error getting RainControl scale factor:', error);
            // throw new Error('Failed to get RainControl scale factor');
        }
    }

    console.log('Final scale factor:', scaleFactor);
    return waterSchedule.duration_ms * scaleFactor;
}

// Internal helper method for calculating effective watering duration
const calEffectiveWatering = (schedule, weatherData) => {
    const originalDuration = schedule.duration_ms;

    // Check active period
    if (!isActiveTime(schedule)) {
        return {
            duration_ms: 0,
            scaleFactor: 0,
            reason: 'outside_active_period',
            adjustments: [],
            originalDuration
        };
    }

    // Apply weather scaling if enabled
    if (!schedule.hasWeatherControl() || !weatherData) {
        return {
            duration_ms: originalDuration,
            scaleFactor: 1.0,
            reason: 'normal_watering',
            adjustments: [],
            originalDuration
        };
    }

    let scaleFactor = 1.0;
    const adjustments = [];

    // Temperature adjustment
    if (weatherData.temperature && weatherData.temperature.scale_factor) {
        const tempScaleFactor = weatherData.temperature.scale_factor;
        scaleFactor *= tempScaleFactor;
        adjustments.push({
            type: 'temperature',
            current_value: weatherData.temperature.celsius,
            scale_factor: tempScaleFactor
        });
    }

    // Rain adjustment
    if (weatherData.rain && weatherData.rain.scale_factor) {
        const rainScaleFactor = weatherData.rain.scale_factor;
        scaleFactor *= rainScaleFactor;
        adjustments.push({
            type: 'rain',
            current_value: weatherData.rain.mm,
            scale_factor: rainScaleFactor
        });
    }

    // Apply bounds (minimum 10% of original, maximum 200%)
    scaleFactor = Math.max(0.1, Math.min(2.0, scaleFactor));
    const finalDuration = Math.round(originalDuration * scaleFactor);

    // Skip if duration too low
    if (finalDuration < 1000) { // Less than 1 second
        return {
            duration_ms: 0,
            scaleFactor,
            reason: 'weather_conditions_skip',
            adjustments,
            originalDuration
        };
    }

    return {
        duration_ms: finalDuration,
        scaleFactor,
        reason: 'weather_adjusted_watering',
        adjustments,
        originalDuration
    };
};

const getMockNextWaterTime = () => {
    return new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
};

// Calculate the next water time based on schedule properties
// Calculate the next water time based on schedule properties
const calculateNextWaterTime = (startTime, interval) => {
    // startTime: "HH:MM:SS"
    // interval: string or number (days)
    const now = new Date();
    now.setUTCMilliseconds(0);

    // Parse start_time (format: "HH:MM:SS")
    const timeMatch = startTime.match(/^(\d{2}):(\d{2}):(\d{2})$/);
    if (!timeMatch) {
        throw new Error('Invalid start_time format');
    }
    const [, hours, minutes, seconds] = timeMatch;
    const startHour = parseInt(hours, 10);
    const startMinute = parseInt(minutes, 10);
    const startSecond = parseInt(seconds, 10);

    // Parse interval as integer days
    let intervalDays = parseInt(interval, 10);
    if (isNaN(intervalDays) || intervalDays < 1) {
        throw new Error('Invalid interval format');
    }

    // Find the first start time (today at start time)
    let nextExecution = new Date(Date.UTC(
        now.getUTCFullYear(),
        now.getUTCMonth(),
        now.getUTCDate(),
        startHour, startMinute, startSecond, 0
    ));

    // If the next execution is in the past, add interval days until it's in the future
    while (nextExecution <= now) {
        nextExecution.setUTCDate(nextExecution.getUTCDate() + intervalDays);
    }

    return nextExecution;
};

// Check if current time is within active period
const isActiveTime = (schedule, currentTime = new Date()) => {
    if (!schedule.active_period) {
        return true; // No active period restriction
    }

    const currentMonth = currentTime.getMonth() + 1;
    const startMonth = validMonthToNumber(schedule.active_period.start_month);
    const endMonth = validMonthToNumber(schedule.active_period.end_month);

    if (startMonth === null || endMonth === null) {
        return true; // Invalid months, assume active
    }

    // Handle year-spanning periods (e.g., Nov to Mar)
    const isInActivePeriod = startMonth <= endMonth
        ? (currentMonth >= startMonth && currentMonth <= endMonth)
        : (currentMonth >= startMonth || currentMonth <= endMonth);

    return isInActivePeriod;
};

module.exports = {
    getNextWaterDetails,
    getNextActiveWaterSchedule,
    scaleWateringDuration,
    calEffectiveWatering,
    getMockNextWaterTime,
    isActiveTime,
    calculateNextWaterTime
};