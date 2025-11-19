const cronScheduler = require('../services/cronScheduler');
const db = require('../models/database');
const { createLink } = require('../utils/helpers');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');

const SchedulerController = {
    // Get scheduler status and active jobs
    getSchedulerStatus: async (req, res, next) => {
        try {
            const activeJobs = cronScheduler.getActiveJobs();
            const response = new ApiSuccess(200, "Scheduler status retrieved successfully", {
                scheduler: {
                    status: 'active',
                    active_jobs_count: activeJobs.length,
                    initialized_at: new Date().toISOString()
                },
                active_jobs: activeJobs,
                links: [
                    createLink('self', '/scheduler'),
                    createLink('initialize', '/scheduler/initialize'),
                    createLink('stop_all', '/scheduler/stop')
                ]
            });
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },

    // Initialize/reinitialize the scheduler
    initializeScheduler: async (req, res, next) => {
        try {
            // Stop existing jobs first
            cronScheduler.stopAllJobs();

            // Initialize with all active schedules
            const success = await cronScheduler.initialize();

            if (success) {
                const activeJobs = cronScheduler.getActiveJobs();
                return res.json(new ApiSuccess(200, 'Scheduler initialized successfully', {
                    active_jobs_count: activeJobs.length,
                    active_jobs: activeJobs,
                    initialized_at: new Date().toISOString()
                }));
            } else {
                throw new ApiError(500, 'Failed to initialize scheduler');
            }
        } catch (error) {
            next(error);
        }
    },

    // Stop all scheduled jobs
    stopAllJobs: async (req, res, next) => {
        try {
            cronScheduler.stopAllJobs();
            return res.json(new ApiSuccess(200, 'All scheduled jobs stopped', {
                stopped_at: new Date().toISOString()
            }));
        } catch (error) {
            next(error);
        }
    },

    // Schedule a specific water schedule
    scheduleWaterSchedule: async (req, res, next) => {
        const { waterScheduleId } = req.params;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            const success = await cronScheduler.scheduleWaterAction(waterSchedule);

            if (success) {
                const nextExecution = cronScheduler.getNextExecutionTime(waterScheduleId);

                return res.json(new ApiSuccess(200, 'Water schedule scheduled successfully', {
                    water_schedule_id: waterScheduleId,
                    water_schedule_name: waterSchedule.name,
                    next_execution: nextExecution,
                    scheduled_at: new Date().toISOString()
                }));
            } else {
                throw new ApiError(500, 'Failed to schedule water schedule');
            }
        } catch (error) {
            next(error);
        }
    },

    // Unschedule a specific water schedule
    unscheduleWaterSchedule: async (req, res, next) => {
        const { waterScheduleId } = req.params;

        try {
            const success = cronScheduler.removeJobById(waterScheduleId);

            if (success) {
                return res.json(new ApiSuccess(200, 'Water schedule unscheduled successfully', {
                    water_schedule_id: waterScheduleId,
                    unscheduled_at: new Date().toISOString()
                }));
            } else {
                throw new ApiError(500, 'Failed to unschedule water schedule');
            }
        } catch (error) {
            next(error);
        }
    },

    // Reschedule a water schedule (useful after updates)
    rescheduleWaterSchedule: async (req, res, next) => {
        const { waterScheduleId } = req.params;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            const success = await cronScheduler.resetWaterSchedule(waterSchedule);

            if (success) {
                const nextExecution = cronScheduler.getNextExecutionTime(waterScheduleId);

                return res.json(new ApiSuccess(200, 'Water schedule rescheduled successfully', {
                    water_schedule_id: waterScheduleId,
                    water_schedule_name: waterSchedule.name,
                    next_execution: nextExecution,
                    rescheduled_at: new Date().toISOString()
                }));
            } else {
                throw new ApiError(500, 'Failed to reschedule water schedule');
            }
        } catch (error) {
            next(error);
        }
    },

    // Manual trigger of a water schedule (bypasses cron)
    triggerWaterSchedule: async (req, res, next) => {
        const { waterScheduleId } = req.params;
        const { force } = req.body;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            const gardens = await db.gardens.getAll({ end_date: null });
            for (const garden of gardens) {
                const zones = await db.zones.getByGardenId(garden._id.toString());
                for (const zone of zones) {
                    if (zone.water_schedule_ids.includes(waterSchedule._id.toString())) {
                        // Execute immediately
                        if (force) {
                            // Force execution regardless of schedule
                            await cronScheduler.executeWaterAction(
                                garden, zone,
                                waterSchedule, {
                                duration: require('../utils/helpers').durationToMillis(waterSchedule.duration),
                                scaleFactor: 1,
                                reason: 'manual_trigger_forced'
                            });
                        } else {
                            // Execute with normal logic
                            await cronScheduler.executeScheduledWaterAction(
                                garden, zone,
                                waterScheduleId);
                        }
                    }
                }
            }

            return res.json(new ApiSuccess(200, 'Water schedule triggered successfully', {
                water_schedule_id: waterScheduleId,
                water_schedule_name: waterSchedule.name,
                triggered_at: new Date().toISOString(),
                force_execution: force || false
            }));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = SchedulerController;