const {
    millisToDuration, durationToMillis, validMonthToNumber
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
 * Helper function similar to Go's GetNextWaterDetails
 * Gets next water time and applies weather scaling
 */
const getNextWaterDetails = async (waterSchedule, excludeWeatherData = false) => {
    const result = {
        time: null,
        duration: waterSchedule.duration,
        water_schedule_id: waterSchedule._id,
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
            if (scaledDurationMs !== durationToMillis(waterSchedule.duration)) {
                result.duration = millisToDuration(scaledDurationMs);
                const scalePercent = Math.round((scaledDurationMs / durationToMillis(waterSchedule.duration)) * 100);
                result.message = `Watering adjusted by weather (${scalePercent}%)`;
            }

        } catch (error) {
            console.error('Error applying weather scaling:', error);
        }
    }

    return result;
};

/**
 * Helper function similar to Go's GetNextActiveWaterSchedule
 * Finds the water schedule with the earliest next execution time
 */
const getNextActiveWaterSchedule = async (waterScheduleIds) => {
    if (!waterScheduleIds || waterScheduleIds.length === 0) {
        return null;
    }

    const waterSchedules = [];
    for (const id of waterScheduleIds) {
        try {
            const ws = await db.waterSchedules.getById(id);
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
                durationToMillis(waterSchedule.interval)
            );
            const tempScaleFactor = waterSchedule.weather_control.temperature_control.scale(avgHighTemp);
            scaleFactor *= tempScaleFactor;
        } catch (error) {
            console.error('Error getting TemperatureControl scale factor:', error);
            throw new Error('Failed to get TemperatureControl scale factor');
        }
    }

    if (waterSchedule.hasRainControl() && waterSchedule.weather_control.rain_control.client_id != null) {
        try {
            const weatherClient = await db.weatherClientConfigs.getById(waterSchedule.weather_control.rain_control.client_id);
            if (!weatherClient) {
                throw new Error('WeatherClient not found for RainControl');
            }
            const totalRain = await new WeatherClient(weatherClient).getTotalRain(
                durationToMillis(waterSchedule.interval)
            );
            const rainScaleFactor = waterSchedule.weather_control.rain_control.invertedScaleDownOnly(totalRain);
            scaleFactor *= rainScaleFactor;
        }
        catch (error) {
            console.error('Error getting RainControl scale factor:', error);
            throw new Error('Failed to get RainControl scale factor');
        }
    }

    console.log('Final scale factor:', scaleFactor);
    return durationToMillis(waterSchedule.duration) * scaleFactor;
}

// Internal helper method for calculating effective watering duration
const calculateEffectiveWateringDuration = (schedule, weatherData, skipCount = 0) => {
    const originalDuration = durationToMillis(schedule.duration);

    // Check skip count first
    if (skipCount > 0) {
        return {
            duration: 0,
            scaleFactor: 0,
            reason: 'skipped_due_to_skip_count',
            adjustments: [],
            originalDuration
        };
    }

    // Check active period
    if (!isActiveTime(schedule)) {
        return {
            duration: 0,
            scaleFactor: 0,
            reason: 'outside_active_period',
            adjustments: [],
            originalDuration
        };
    }

    // Apply weather scaling if enabled
    if (!schedule.hasWeatherControl() || !weatherData) {
        return {
            duration: originalDuration,
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
            duration: 0,
            scaleFactor,
            reason: 'weather_conditions_skip',
            adjustments,
            originalDuration
        };
    }

    return {
        duration: finalDuration,
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
const calculateNextWaterTime = (schedule) => {
    const now = new Date();
    const currentMonth = now.getMonth() + 1; // JavaScript months are 0-indexed

    // Check if we're in active period (if defined)
    if (schedule.active_period) {
        const startMonth = validMonthToNumber(schedule.active_period.start_month);
        const endMonth = validMonthToNumber(schedule.active_period.end_month);

        // Handle year-spanning periods (e.g., Nov to Mar)
        const isInActivePeriod = startMonth <= endMonth
            ? (currentMonth >= startMonth && currentMonth <= endMonth)
            : (currentMonth >= startMonth || currentMonth <= endMonth);

        if (!isInActivePeriod) {
            // Find next start of active period
            let nextActiveMonth;
            if (startMonth <= endMonth) {
                // Same year period
                nextActiveMonth = currentMonth <= endMonth ? startMonth + 1 : startMonth;
            } else {
                // Year-spanning period
                nextActiveMonth = currentMonth <= endMonth ? startMonth : startMonth;
            }

            const nextYear = nextActiveMonth <= currentMonth ? now.getFullYear() + 1 : now.getFullYear();
            const nextActiveDate = new Date(nextYear, nextActiveMonth - 1, 1);
            return nextActiveDate.toISOString();
        }
    }

    // Parse start_time (format: "HH:MM:SS±HH:MM")
    const timeMatch = schedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})([+-])(\d{2}):(\d{2})$/);
    if (!timeMatch) {
        throw new Error('Invalid start_time format');
    }

    const [, hours, minutes, seconds, tzSign, tzHours, tzMinutes] = timeMatch;
    const startHour = parseInt(hours, 10);
    const startMinute = parseInt(minutes, 10);
    const startSecond = parseInt(seconds, 10);

    // Get timezone offset in hours
    const timezoneOffsetHours = (tzSign === '+' ? 1 : -1) * parseInt(tzHours, 10);
    const timezoneOffset = timezoneOffsetHours * 60 * 60 * 1000; // Convert to milliseconds

    // Parse interval to hours
    const intervalMatch = schedule.interval.match(/^(\d+)([smhd])$/);
    if (!intervalMatch) {
        throw new Error('Invalid interval format');
    }

    const value = parseInt(intervalMatch[1]);
    const unit = intervalMatch[2];
    let intervalHours;

    switch (unit) {
        case 's': intervalHours = value / 3600; break;
        case 'm': intervalHours = value / 60; break;
        case 'h': intervalHours = value; break;
        case 'd': intervalHours = value * 24; break;
        default: throw new Error('Invalid interval unit');
    }

    // Calculate execution times based on interval (similar to cron logic)
    let executionHours = [startHour];

    if (intervalHours === 12) {
        // Twice daily: original hour and 12 hours later
        executionHours = [startHour, (startHour + 12) % 24];
    } else if (intervalHours < 24) {
        // Multiple times per day
        executionHours = [];
        for (let h = 0; h < 24; h += intervalHours) {
            executionHours.push((startHour + h) % 24);
        }
    }
    // For 24h or longer intervals, keep original hour

    // Get current time in the schedule's timezone
    const nowInTimezone = new Date(now.getTime() + timezoneOffset);

    // Find next execution time
    let nextExecution = null;
    const sortedHours = [...executionHours].sort((a, b) => a - b);

    // Check today's times first
    for (const targetHour of sortedHours) {
        // Create time in target timezone
        const timezoneTime = new Date();
        timezoneTime.setUTCFullYear(nowInTimezone.getUTCFullYear());
        timezoneTime.setUTCMonth(nowInTimezone.getUTCMonth());
        timezoneTime.setUTCDate(nowInTimezone.getUTCDate());
        timezoneTime.setUTCHours(targetHour, startMinute, startSecond, 0);

        // Convert to UTC by subtracting timezone offset
        const utcTime = new Date(timezoneTime.getTime() - timezoneOffset);

        if (utcTime > now) {
            nextExecution = utcTime;
            break;
        }
    }

    // If no time today works, use tomorrow's earliest time
    if (!nextExecution) {
        const tomorrowInTimezone = new Date(nowInTimezone);
        tomorrowInTimezone.setUTCDate(tomorrowInTimezone.getUTCDate() + 1);
        tomorrowInTimezone.setUTCHours(sortedHours[0], startMinute, startSecond, 0);

        nextExecution = new Date(tomorrowInTimezone.getTime() - timezoneOffset);
    }

    // Handle day intervals (e.g., every 2 days, every 3 days)
    if (intervalHours >= 24 && intervalHours % 24 === 0) {
        const dayInterval = intervalHours / 24;
        let testExecution = new Date(nextExecution);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        let daysDiff = Math.floor((testExecution - today) / (24 * 60 * 60 * 1000));
        while (daysDiff % dayInterval !== 0) {
            testExecution.setDate(testExecution.getDate() + 1);
            daysDiff++;
        }

        nextExecution = testExecution;
    }

    // Double-check we're still in active period for the calculated date
    if (schedule.active_period) {
        const nextMonth = nextExecution.getMonth() + 1;
        const startMonth = validMonthToNumber(schedule.active_period.start_month);
        const endMonth = validMonthToNumber(schedule.active_period.end_month);

        const isInActivePeriod = startMonth <= endMonth
            ? (nextMonth >= startMonth && nextMonth <= endMonth)
            : (nextMonth >= startMonth || nextMonth <= endMonth);

        if (!isInActivePeriod) {
            // Find next start of active period
            const nextActiveYear = nextMonth > endMonth && startMonth <= endMonth ? nextExecution.getFullYear() + 1 : nextExecution.getFullYear();
            const nextActivePeriodStart = new Date(nextActiveYear, startMonth - 1, 1);
            nextActivePeriodStart.setUTCHours(startHour, startMinute, startSecond, 0);
            const nextActivePeriodUTC = new Date(nextActivePeriodStart.getTime() - timezoneOffset);
            return nextActivePeriodUTC.toISOString();
        }
    }

    return nextExecution.toISOString();
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
    calculateEffectiveWateringDuration,
    getMockNextWaterTime,
    calculateNextWaterTime,
    isActiveTime
};