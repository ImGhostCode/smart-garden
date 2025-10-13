const cronScheduler = require('../services/cronScheduler');
const {
    getMockWeatherData,
    calculateEffectiveWateringDuration,
    formatDuration
} = require('./helpers');
const db = require('../models/database');
const { log } = require('winston');

/**
 * Helper function similar to Go's GetNextWaterDetails
 * Gets next water time and applies weather scaling
 */
const getNextWaterDetails = (waterSchedule, excludeWeatherData = false) => {
    const result = {
        duration: waterSchedule.duration,
        water_schedule_id: waterSchedule._id,
        message: 'Next scheduled watering'
    };

    // Try to get next execution time from cron scheduler first
    const cronNextTime = cronScheduler.getNextExecutionTime(waterSchedule._id.toString());

    if (cronNextTime) {
        result.time = cronNextTime;
        result.message = 'Next scheduled watering (cron)';
    } else {
        result.time = null;
        result.message = 'Water schedule not active';
        return result;
    }

    // Apply weather scaling if enabled
    if (waterSchedule.weather_control && !excludeWeatherData) {
        try {
            const weatherData = getMockWeatherData();
            const effectiveWatering = calculateEffectiveWateringDuration(
                waterSchedule,
                weatherData,
                0 // skip_count
            );
            console.log('Effective watering after weather scaling:', effectiveWatering);


            if (effectiveWatering.scaleFactor !== 1) {
                result.duration = formatDuration(effectiveWatering.duration);
                result.message = `Watering adjusted by weather (${Math.round(effectiveWatering.scaleFactor * 100)}%)`;
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
        const cronNextTime = cronScheduler.getNextExecutionTime(ws._id.toString());
        if (cronNextTime) {
            if (!earliestTime || cronNextTime < earliestTime) {
                earliestTime = cronNextTime;
                nextSchedule = ws;
            }
        }
    }

    return nextSchedule;
};

module.exports = {
    getNextWaterDetails,
    getNextActiveWaterSchedule
};