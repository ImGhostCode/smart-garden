const cronScheduler = require('../services/cronScheduler');
const db = require('../models/database');
const { createLink } = require('../utils/helpers');

const SchedulerController = {
    // Get scheduler status and active jobs
    getSchedulerStatus: async (req, res) => {
        try {
            const activeJobs = cronScheduler.getActiveJobs();

            res.json({
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
        } catch (error) {
            console.error('Error getting scheduler status:', error);
            res.status(500).json({
                error: 'Failed to get scheduler status',
                details: error.message
            });
        }
    },

    // Initialize/reinitialize the scheduler
    initializeScheduler: async (req, res) => {
        try {
            // Stop existing jobs first
            cronScheduler.stopAllJobs();

            // Initialize with all active schedules
            const success = await cronScheduler.initialize();

            if (success) {
                const activeJobs = cronScheduler.getActiveJobs();
                res.json({
                    message: 'Scheduler initialized successfully',
                    active_jobs_count: activeJobs.length,
                    active_jobs: activeJobs,
                    initialized_at: new Date().toISOString()
                });
            } else {
                res.status(500).json({
                    error: 'Failed to initialize scheduler'
                });
            }
        } catch (error) {
            console.error('Error initializing scheduler:', error);
            res.status(500).json({
                error: 'Failed to initialize scheduler',
                details: error.message
            });
        }
    },

    // Stop all scheduled jobs
    stopAllJobs: async (req, res) => {
        try {
            cronScheduler.stopAllJobs();
            res.json({
                message: 'All scheduled jobs stopped',
                stopped_at: new Date().toISOString()
            });
        } catch (error) {
            console.error('Error stopping jobs:', error);
            res.status(500).json({
                error: 'Failed to stop jobs',
                details: error.message
            });
        }
    },

    // Schedule a specific water schedule
    scheduleWaterSchedule: async (req, res) => {
        const { waterScheduleId } = req.params;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            const success = await cronScheduler.scheduleWaterAction(waterSchedule);

            if (success) {
                const nextExecution = cronScheduler.getNextExecutionTime(waterScheduleId);
                res.json({
                    message: 'Water schedule scheduled successfully',
                    water_schedule_id: waterScheduleId,
                    water_schedule_name: waterSchedule.name,
                    next_execution: nextExecution,
                    scheduled_at: new Date().toISOString()
                });
            } else {
                res.status(500).json({
                    error: 'Failed to schedule water schedule'
                });
            }
        } catch (error) {
            console.error('Error scheduling water schedule:', error);
            res.status(500).json({
                error: 'Failed to schedule water schedule',
                details: error.message
            });
        }
    },

    // Unschedule a specific water schedule
    unscheduleWaterSchedule: async (req, res) => {
        const { waterScheduleId } = req.params;

        try {
            const success = cronScheduler.removeJobById(waterScheduleId);

            if (success) {
                res.json({
                    message: 'Water schedule unscheduled successfully',
                    water_schedule_id: waterScheduleId,
                    unscheduled_at: new Date().toISOString()
                });
            } else {
                res.status(404).json({
                    error: 'No scheduled job found for this water schedule'
                });
            }
        } catch (error) {
            console.error('Error unscheduling water schedule:', error);
            res.status(500).json({
                error: 'Failed to unschedule water schedule',
                details: error.message
            });
        }
    },

    // Reschedule a water schedule (useful after updates)
    rescheduleWaterSchedule: async (req, res) => {
        const { waterScheduleId } = req.params;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            const success = await cronScheduler.resetWaterSchedule(waterSchedule);

            if (success) {
                const nextExecution = cronScheduler.getNextExecutionTime(waterScheduleId);
                res.json({
                    message: 'Water schedule rescheduled successfully',
                    water_schedule_id: waterScheduleId,
                    water_schedule_name: waterSchedule.name,
                    next_execution: nextExecution,
                    rescheduled_at: new Date().toISOString()
                });
            } else {
                res.status(500).json({
                    error: 'Failed to reschedule water schedule'
                });
            }
        } catch (error) {
            console.error('Error rescheduling water schedule:', error);
            res.status(500).json({
                error: 'Failed to reschedule water schedule',
                details: error.message
            });
        }
    },

    // Manual trigger of a water schedule (bypasses cron)
    triggerWaterSchedule: async (req, res) => {
        const { waterScheduleId } = req.params;
        const { force } = req.body;

        try {
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
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

            res.json({
                message: 'Water schedule triggered successfully',
                water_schedule_id: waterScheduleId,
                water_schedule_name: waterSchedule.name,
                triggered_at: new Date().toISOString(),
                force_execution: force || false
            });
        } catch (error) {
            console.error('Error triggering water schedule:', error);
            res.status(500).json({
                error: 'Failed to trigger water schedule',
                details: error.message
            });
        }
    }
};

module.exports = SchedulerController;