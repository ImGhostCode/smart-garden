const cron = require('node-cron');
const db = require('../models/database');
const {
    calculateNextWaterTime,
    calculateEffectiveWateringDuration,
    getMockWeatherData,
    isActiveTime,
    formatDuration,
    durationToMilliseconds
} = require('../utils/helpers');
const { log } = require('winston');
const mqttService = require('./mqttService');

class CronScheduler {
    constructor() {
        this.scheduledJobs = new Map(); // Store active cron jobs
        this.logger = console; // You can replace with proper logger
    }

    /**
     * Schedule a water schedule using cron
     */
    async scheduleWaterAction(waterSchedule) {
        this.logger.log(`Creating cron job for water schedule: ${waterSchedule.name} (${waterSchedule._id})`);

        // Remove existing job if it exists
        this.removeJobById(waterSchedule._id.toString());

        try {
            // Parse start_time to get hour and minute
            const timeMatch = waterSchedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})/);
            if (!timeMatch) {
                throw new Error(`Invalid start_time format: ${waterSchedule.start_time}`);
            }

            const [, hours, minutes] = timeMatch;
            const intervalHours = this.parseIntervalToHours(waterSchedule.interval);

            // Create cron pattern based on interval
            let cronPattern;
            if (intervalHours === 24) {
                // Daily watering
                cronPattern = `${minutes} ${hours} * * *`;
            } else if (intervalHours === 12) {
                // Twice daily
                cronPattern = `${minutes} ${hours},${(parseInt(hours) + 12) % 24} * * *`;
            } else if (intervalHours >= 24 && intervalHours % 24 === 0) {
                // Every N days
                const dayInterval = intervalHours / 24;
                cronPattern = `${minutes} ${hours} */${dayInterval} * *`;
            } else {
                // For complex intervals, use every minute check (less efficient but more flexible)
                cronPattern = '* * * * *'; // Every minute, will check if it's time
            }

            this.logger.log(`Scheduling with cron pattern: ${cronPattern} for interval: ${waterSchedule.interval}`);

            // Create the cron job
            const task = cron.schedule(cronPattern, async () => {
                const gardens = await db.gardens.getAll({ end_date: null });
                for (const garden of gardens) {
                    const zones = await db.zones.getByGardenId(garden._id.toString());
                    for (const zone of zones) {
                        if (zone.water_schedule_ids.includes(waterSchedule._id.toString())) {
                            await this.executeScheduledWaterAction(garden, zone, waterSchedule._id.toString());
                        }
                    }
                }
            }, {
                scheduled: true,
                timezone: "Asia/Ho_Chi_Minh" // Set to match +07:00 timezone from your start_time
            });

            // Store the job reference
            this.scheduledJobs.set(waterSchedule._id.toString(), {
                task,
                waterSchedule: waterSchedule,
                cronPattern,
                createdAt: new Date()
            });

            this.logger.log(`Successfully scheduled water action for ${waterSchedule.name}`);
            return true;

        } catch (error) {
            this.logger.error(`Error scheduling water action for ${waterSchedule._id}:`, error);
            return false;
        }
    }

    /**
     * Execute scheduled water action
     */
    async executeScheduledWaterAction(garden, zone, waterScheduleId) {
        const jobLogger = this.logger;
        jobLogger.log(`Executing scheduled water action for schedule: ${waterScheduleId}`);

        try {
            // Get fresh water schedule data
            const waterSchedule = await db.waterSchedules.getById(waterScheduleId);
            if (!waterSchedule) {
                jobLogger.error(`Water schedule not found: ${waterScheduleId}`);
                return;
            }

            // Check if we're in active period
            if (!isActiveTime(waterSchedule)) {
                jobLogger.log(`Skipping water schedule ${waterScheduleId} - outside active period`);
                return;
            }

            // Check if it's actually time to water (for all intervals)
            const jobInfo = this.scheduledJobs.get(waterScheduleId);
            if (jobInfo) {
                const shouldExecuteNow = await this.shouldExecuteNow(waterSchedule);
                if (!shouldExecuteNow) {
                    jobLogger.log(`Skipping water schedule ${waterScheduleId} - not time yet based on interval`);
                    return; // Not time yet
                }
            }

            // Get weather data and calculate effective watering
            const weatherData = getMockWeatherData();

            // TODO: Get skip count from zone data or database
            const skipCount = zone.skip_count || 0;

            const effectiveWatering = calculateEffectiveWateringDuration(
                waterSchedule,
                weatherData,
                skipCount
            );

            if (effectiveWatering.duration === 0) {
                jobLogger.log(`Skipping watering for schedule ${waterScheduleId}: ${effectiveWatering.reason}`);
                return;
            }

            // Log the execution
            const executionLog = {
                water_schedule_id: waterScheduleId,
                executed_at: new Date().toISOString(),
                duration_ms: effectiveWatering.duration,
                duration_formatted: formatDuration(effectiveWatering.duration),
                scale_factor: effectiveWatering.scaleFactor,
                reason: effectiveWatering.reason,
                weather_data: weatherData,
                weather_adjustments: effectiveWatering.adjustments
            };

            jobLogger.log('Water Schedule Execution:', JSON.stringify(executionLog, null, 2));

            // Execute the actual watering
            await this.executeWaterAction(garden, zone, waterSchedule, effectiveWatering);

            // TODO: Send notifications if configured
            // this.sendWateringNotification(waterSchedule, effectiveWatering);

        } catch (error) {
            jobLogger.error(`Error executing scheduled water action for ${waterScheduleId}:`, error);
            // TODO: Send error notifications
        }
    }

    /**
     * Execute the actual water action
     * This is where you'd interface with hardware or external APIs
     */
    async executeWaterAction(garden, zone, waterSchedule, effectiveWatering) {
        this.logger.log(`🚿 EXECUTING WATER ACTION`);
        this.logger.log(`   Garden: ${garden.name} (${garden._id})`);
        this.logger.log(`   Zone: ${zone.name} (Position ${zone.position})`);
        this.logger.log(`   Schedule: ${waterSchedule.name}`);
        this.logger.log(`   Duration: ${formatDuration(effectiveWatering.duration)}`);
        this.logger.log(`   Scale Factor: ${effectiveWatering.scaleFactor}`);

        // Get zones associated with this water schedule
        try {
            const result = await mqttService.sendWaterCommand(
                garden,
                zone._id.toString(),
                zone.position,
                durationToMilliseconds(effectiveWatering.duration),
                "scheduled"
            );
            console.log('MQTT water command result:', result);
        } catch (error) {
            console.error('Failed to send zone action to ESP32:', error);
            res.status(500).json({
                error: 'Failed to communicate with garden controller',
                details: error.message
            });
        }
    }

    /**
     * Check if it's time to execute for complex intervals
     */
    async shouldExecuteNow(waterSchedule) {
        try {
            const nextWaterTime = new Date(calculateNextWaterTime(waterSchedule));
            console.log('Next water time: %s', nextWaterTime.toISOString());
            const now = new Date();

            // Allow execution within 1 minute window
            const timeDiff = Math.abs(nextWaterTime.getTime() - now.getTime());
            return timeDiff < 60000; // Within 1 minute
        } catch (error) {
            this.logger.error('Error checking execution time:', error);
            return false;
        }
    }

    /**
     * Parse interval string to hours
     */
    parseIntervalToHours(interval) {
        const match = interval.match(/^(\d+)([smhd])$/);
        if (!match) return 24; // Default to daily

        const value = parseInt(match[1]);
        const unit = match[2];

        switch (unit) {
            case 's': return value / 3600;
            case 'm': return value / 60;
            case 'h': return value;
            case 'd': return value * 24;
            default: return 24;
        }
    }

    /**
     * Remove a scheduled job by water schedule ID
     */
    removeJobById(waterScheduleId) {
        const jobInfo = this.scheduledJobs.get(waterScheduleId);

        if (jobInfo) {
            jobInfo.task.destroy();
            this.scheduledJobs.delete(waterScheduleId);
            this.logger.log(`Removed cron job for water schedule: ${waterScheduleId}`);
            return true;
        }
        return false;
    }

    /**
     * Reset/reschedule a water schedule
     */
    async resetWaterSchedule(waterSchedule) {
        this.logger.log(`Resetting water schedule: ${waterSchedule._id}`);
        return await this.scheduleWaterAction(waterSchedule);
    }

    /**
     * Get next execution time for a water schedule
     */
    getNextExecutionTime(waterScheduleId) {
        const jobInfo = this.scheduledJobs.get(waterScheduleId);
        if (!jobInfo) {
            return null;
        }

        try {
            // Use node-cron's built-in method to get next execution time
            const nextRun = jobInfo.task.getNextRun();

            // Convert to Date object if needed
            const nextTime = nextRun instanceof Date ? nextRun : new Date(nextRun);

            console.log(`Next execution for ${waterScheduleId}: ${nextTime.toISOString()}`);
            return nextTime;

        } catch (error) {
            this.logger.error('Error getting next execution time:', error);
            return null;
        }
    }



    /**
     * Get all active jobs
     */
    getActiveJobs() {
        const jobs = [];
        for (const [waterScheduleId, jobInfo] of this.scheduledJobs) {
            jobs.push({
                water_schedule_id: waterScheduleId,
                water_schedule_name: jobInfo.waterSchedule.name,
                cron_pattern: jobInfo.cronPattern,
                created_at: jobInfo.createdAt,
                next_execution: this.getNextExecutionTime(waterScheduleId)
            });
        }
        return jobs.sort((a, b) => a.next_execution - b.next_execution);
    }

    /**
     * Stop all scheduled jobs
     */
    stopAllJobs() {
        this.logger.log(`Stopping ${this.scheduledJobs.size} scheduled jobs`);
        for (const [waterScheduleId, jobInfo] of this.scheduledJobs) {
            jobInfo.task.destroy();
        }
        this.scheduledJobs.clear();
    }

    /**
     * Initialize scheduler - load all active water schedules
     */
    async initialize() {
        this.logger.log('Initializing cron scheduler...');

        try {
            // Get all active water schedules
            const waterSchedules = await db.waterSchedules.getAll({ end_date: null });

            let scheduledCount = 0;
            for (const schedule of waterSchedules) {
                const success = await this.scheduleWaterAction(schedule);
                if (success) scheduledCount++;
            }

            this.logger.log(`Cron scheduler initialized with ${scheduledCount} water schedules`);
            return true;
        } catch (error) {
            this.logger.error('Error initializing cron scheduler:', error);
            return false;
        }
    }
}

// Create singleton instance
const cronScheduler = new CronScheduler();

module.exports = cronScheduler;