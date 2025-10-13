const db = require('../models/database');
const cronScheduler = require('../services/cronScheduler');
const {
    createLink,
    getMockWeatherData,
    calculateEffectiveWateringDuration,
    isActiveTime,
    formatDuration,
    durationToMilliseconds,
    validMonthToNumber
} = require('../utils/helpers');
const { getNextWaterDetails } = require('../utils/waterScheduleHelpers');

const WaterSchedulesController = {
    getAllWaterSchedules: async (req, res) => {
        const { end_dated, exclude_weather_data } = req.query;

        const filters = {};
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;
        const waterSchedules = await db.waterSchedules.getAll(filters);

        res.json({
            items: waterSchedules.map(schedule => {
                const nextWaterDetails = getNextWaterDetails(
                    schedule,
                    exclude_weather_data === 'true'
                );

                return {
                    ...schedule.toObject(),
                    links: [
                        createLink('self', `/water_schedules/${schedule.id}`)
                    ],
                    weather_data: weatherData,
                    next_water: nextWaterDetails
                };
            })
        });
    },

    addWaterSchedule: async (req, res) => {
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        const schedule = {
            duration,
            interval,
            start_time,
            weather_control,
            active_period,
            name,
            description
        };

        // Validate active_period months if provided
        if (active_period) {
            const { start_month, end_month } = active_period;
            const startMonth = validMonthToNumber(start_month);
            const endMonth = validMonthToNumber(end_month);
            if (startMonth === null || endMonth === null) {
                return res.status(400).json({ error: 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)' });
            }
            // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
            if (startMonth === endMonth) {
                return res.status(400).json({ error: 'Active period start month must be different from end month' });
            }
        }

        const result = await db.waterSchedules.create(schedule);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;
        let nextWaterDetails;

        try {
            // Auto-schedule the new water schedule with cron
            const cronScheduler = require('../services/cronScheduler');
            await cronScheduler.scheduleWaterAction(result);
            nextWaterDetails = getNextWaterDetails(
                result,
                exclude_weather_data === 'true'
            );
        } catch (error) {
            console.error('Error calculating next water time:', error);
        }

        res.status(201).json({
            ...result.toObject(),
            links: [
                createLink('self', `/water_schedules/${result.id}`)
            ],
            weather_data: weatherData,
            next_water: nextWaterDetails
        });
    },

    getWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;
        const nextWaterDetails = getNextWaterDetails(
            schedule,
            exclude_weather_data === 'true'
        );

        const response = {
            ...schedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${schedule.id}`)
            ],
            weather_data: weatherData,
            next_water: nextWaterDetails
        };

        res.json(response);
    }, updateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const update = {};

        if (duration !== undefined) update.duration = duration;
        if (interval !== undefined) update.interval = interval;
        if (start_time !== undefined) update.start_time = start_time;
        if (weather_control !== undefined) update.weather_control = weather_control;
        if (name !== undefined) update.name = name;
        if (description !== undefined) update.description = description;
        // Validate active_period months if provided
        if (active_period !== undefined) {
            const { start_month, end_month } = active_period;
            const startMonth = validMonthToNumber(start_month);
            const endMonth = validMonthToNumber(end_month);
            if (startMonth === null || endMonth === null) {
                return res.status(400).json({ error: 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)' });
            }
            // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
            if (startMonth === endMonth) {
                return res.status(400).json({ error: 'Active period start month must be different from end month' });
            }

            update.active_period = active_period;
        }

        const updatedSchedule = await db.waterSchedules.updateById(waterScheduleID, update);
        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;
        let nextWaterDetails;

        try {
            // Reschedule the updated water schedule with cron
            const cronScheduler = require('../services/cronScheduler');
            await cronScheduler.resetWaterSchedule(updatedSchedule);
            nextWaterDetails = getNextWaterDetails(
                updatedSchedule,
                exclude_weather_data === 'true'
            );
        } catch (error) {
            console.error('Error calculating next water time:', error);
        }

        res.json({
            ...updatedSchedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${schedule.id}`)
            ],
            weather_data: weatherData,
            next_water: nextWaterDetails
        });
    },

    endDateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const deletedWaterSchedule = await db.waterSchedules.deleteById(waterScheduleID);

        // Remove from cron scheduler
        const cronScheduler = require('../services/cronScheduler');
        const unscheduled = cronScheduler.removeJobById(waterScheduleID);

        res.json({
            ...deletedWaterSchedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${waterScheduleID}`)
            ],
            unscheduled: unscheduled
        });
    },

    // Execute a water schedule with advanced logic (similar to Go's ExecuteScheduledWaterAction)
    executeWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { skip_count, force_execution, simulate } = req.body;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const weatherData = getMockWeatherData();
        const skipCount = skip_count || 0;
        const isSimulation = simulate === true;
        const forceExecution = force_execution === true;

        // Calculate effective watering parameters
        const effectiveWatering = calculateEffectiveWateringDuration(schedule, weatherData, skipCount);

        // Log execution details
        const executionLog = {
            water_schedule_id: waterScheduleID,
            executed_at: new Date().toISOString(),
            weather_data: weatherData,
            effective_watering: effectiveWatering,
            simulation: isSimulation,
            force_execution: forceExecution
        };

        // Determine if watering should proceed
        let shouldWater = effectiveWatering.duration > 0 || forceExecution;
        let executionReason = effectiveWatering.reason;

        if (forceExecution && effectiveWatering.duration === 0) {
            executionReason = 'forced_execution';
            effectiveWatering.duration = effectiveWatering.originalDuration || durationToMilliseconds(schedule.duration);
            effectiveWatering.scaleFactor = 1;
        }

        // Update skip count if watering is happening
        let updatedSkipCount = skipCount;
        if (shouldWater && skipCount > 0 && !forceExecution) {
            updatedSkipCount = Math.max(0, skipCount - 1);
            executionLog.skip_count_updated = {
                before: skipCount,
                after: updatedSkipCount
            };
        }

        // Build response
        const response = {
            ...schedule.toObject(),
            execution: {
                will_execute: shouldWater,
                reason: executionReason,
                duration_ms: effectiveWatering.duration,
                duration_formatted: formatDuration(effectiveWatering.duration),
                scale_factor: effectiveWatering.scaleFactor,
                weather_adjustments: effectiveWatering.adjustments || [],
                skip_count: updatedSkipCount,
                is_simulation: isSimulation,
                executed_at: executionLog.executed_at
            },
            weather_data: weatherData,
            links: [
                createLink('self', `/water_schedules/${waterScheduleID}`)
            ]
        };

        // Add detailed execution log
        if (isSimulation) {
            response.execution.note = 'This was a simulation - no actual watering occurred';
        } else if (shouldWater) {
            response.execution.note = 'Watering executed successfully';
            // In a real implementation, you would trigger the actual watering hardware here
            console.log(`Executing water schedule ${waterScheduleID} for ${formatDuration(effectiveWatering.duration)}`);
            const gardens = await db.gardens.getAll({ end_date: null });
            for (const garden of gardens) {
                const zones = await db.zones.getByGardenId(garden._id.toString());
                for (const zone of zones) {
                    if (zone.water_schedule_ids.includes(waterScheduleID)) {
                        await cronScheduler.executeWaterAction(
                            garden, zone,
                            schedule, {
                            duration: effectiveWatering.duration,
                            scaleFactor: effectiveWatering.scaleFactor,
                            reason: executionReason
                        });
                    }
                }
            }
        } else {
            response.execution.note = 'Watering skipped based on conditions';
        }

        // Log the execution details
        console.log('Water Schedule Execution:', JSON.stringify(executionLog, null, 2));

        res.json(response);
    },

    // Get execution preview for a water schedule
    previewExecution: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { skip_count } = req.query;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const weatherData = getMockWeatherData();
        const skipCount = skip_count ? parseInt(skip_count, 10) : 0;

        // Calculate what would happen if executed now
        const effectiveWatering = calculateEffectiveWateringDuration(schedule, weatherData, skipCount);

        res.json({
            water_schedule_id: waterScheduleID,
            preview: {
                will_execute: effectiveWatering.duration > 0,
                reason: effectiveWatering.reason,
                duration_ms: effectiveWatering.duration,
                duration_formatted: formatDuration(effectiveWatering.duration),
                original_duration_ms: effectiveWatering.originalDuration,
                original_duration_formatted: formatDuration(effectiveWatering.originalDuration || durationToMilliseconds(schedule.duration)),
                scale_factor: effectiveWatering.scaleFactor,
                weather_adjustments: effectiveWatering.adjustments || [],
                skip_count: skipCount,
                is_active_period: isActiveTime(schedule),
                current_weather: weatherData
            },
            schedule_info: {
                name: schedule.name,
                description: schedule.description,
                interval: schedule.interval,
                start_time: schedule.start_time
            },
            links: [
                createLink('self', `/water_schedules/${waterScheduleID}`),
                createLink('execute', `/water_schedules/${waterScheduleID}/execute`)
            ]
        });
    }
};

module.exports = WaterSchedulesController;