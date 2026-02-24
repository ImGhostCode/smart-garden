const cron = require('node-cron');
const db = require('../models/database');
const {
    waterScheduleLabels,
    gardenLabels
} = require('../utils/helpers');
const {
    isActiveTime,
    scaleWateringDuration
} = require('../utils/waterScheduleHelpers');
const mqttService = require('./mqttService');
const { ApiError } = require('../utils/apiResponse');
const notificationService = require('./notificationService');
const gardenService = require('./gardenService');
const client = require('prom-client');
const config = require('../config/app.config');
const register = client.register;

const schedulerJobsGauge = new client.Gauge({
    name: `${config.metric_prefix}scheduled_jobs`,
    help: 'gauge of the currently-scheduled jobs',
    labelNames: ['type', 'id'],
    registers: [register],
});

const schedulerErrors = new client.Counter({
    name: `${config.metric_prefix}scheduler_errors`,
    help: 'count of errors that occur in the background and do not have any visibility except logs',
    labelNames: ['type', 'id'],
    registers: [register],
});

class CronScheduler {
    constructor() {
        this.scheduledJobs = new Map(); // Store active cron jobs
        this.logger = console;
    }

    /**
     * Schedule a water schedule using cron
     */
    async scheduleWaterAction(waterSchedule) {
        // Remove existing job if it exists
        this.removeJobById(waterSchedule._id.toString());

        try {
            // Parse start_time to get hour and minute
            const timeMatch = waterSchedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})/);
            if (!timeMatch) {
                throw new Error(`Invalid start_time format: ${waterSchedule.start_time}`);
            }

            const [, hours, minutes] = timeMatch;
            const intervalHours = waterSchedule.interval * 24; // Convert days to hours

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

            this.logger.log(`Scheduling with cron pattern: ${cronPattern} for interval: ${waterSchedule.interval} day(s)`);

            // Create the cron job
            const task = cron.schedule(cronPattern, async () => {
                try {
                    const gardens = await db.gardens.getAll({ filters: { end_date: null } });
                    for (const garden of gardens) {
                        const zones = await db.zones.getByGardenId(garden._id.toString());
                        for (const zone of zones) {
                            if (zone.water_schedule_ids.includes(waterSchedule._id.toString())) {
                                try {
                                    await this.executeScheduledWaterAction(garden, zone, waterSchedule._id.toString());
                                } catch (error) {
                                    schedulerErrors.inc(waterScheduleLabels(waterSchedule), 1);
                                    this.logger.error('Error executing scheduled water action:', error);
                                    if (garden.notification_client_id) {
                                        notificationService.sendNotification(garden.notification_client_id, `${garden.name}: Watering Action Error`, error.message).catch((err) => {
                                            this.logger.error("Error sending watering action error notification:", err)
                                        });
                                    }
                                }
                            }
                        }
                    }
                } catch (error) {
                    this.logger.error('Error in scheduled water action cron job:', error);
                }
            }, {
                scheduled: true,
                timezone: 'UTC'
            });

            // Store the job reference
            this.scheduledJobs.set(waterSchedule._id.toString(), {
                task,
                waterSchedule: waterSchedule,
                cronPattern,
                createdAt: new Date(),
                type: 'water'
            });

            this.logger.log(`Successfully scheduled water action for ${waterSchedule.name}`);
            schedulerJobsGauge.inc(waterScheduleLabels(waterSchedule), 1);
            return true;
        } catch (error) {
            this.logger.error(`Error scheduling water action for ${waterSchedule._id}:`, error);
            schedulerErrors.inc(waterScheduleLabels(waterSchedule), 1);
            return false;
        }
    }

    /**
     * Execute scheduled water action
     */
    async executeScheduledWaterAction(garden, zone, waterScheduleId) {
        this.logger.log(`Executing scheduled water action for schedule: ${waterScheduleId}`);
        if (zone.skip_count !== undefined && zone.skip_count > 0) {
            this.logger.log(`Skipping watering for zone ${zone.name} due to skip_count (${zone.skip_count})`);
            await db.zones.updateById({ id: zone._id.toString(), data: { skip_count: zone.skip_count - 1 } });
            return;
        }

        // Get fresh water schedule data
        const waterSchedule = await db.waterSchedules.getById({ id: waterScheduleId });
        if (!waterSchedule) {
            throw new Error(`Water schedule not found: ${waterScheduleId}`);
        }

        // Check if we're in active period
        if (!isActiveTime(waterSchedule)) {
            this.logger.log(`Skipping water schedule ${waterScheduleId} - outside active period`);
            return;
        }

        // Check if it's actually time to water (for all intervals)
        // const shouldExecuteNow = this.shouldExecuteNow(waterSchedule);
        // if (!shouldExecuteNow) {
        //     this.logger.log(`Skipping water schedule ${waterScheduleId} - not time yet based on interval`);
        //     return; // Not time yet
        // }

        let duration;
        if (!waterSchedule.hasWeatherControl()) {
            duration = waterSchedule.duration_ms;
        } else {
            duration = await scaleWateringDuration(waterSchedule);
        }

        if (duration === 0) {
            this.logger.log(`Weather control determined that watering should be skipped`);
            return;
        }

        if (garden.notification_client_id) {
            notificationService.sendDownNotification(garden, garden.notification_client_id, "Water")
        }

        // Execute the actual watering
        await this.executeWaterAction(garden, zone, duration, 'scheduled');

        // TODO: Send notifications if configured
        // this.sendWateringNotification(waterSchedule, effectiveWatering);

    }

    /**
     * Execute the actual water action
     * This is where you'd interface with hardware or external APIs
     */
    async executeWaterAction(garden, zone, duration, source) {
        this.logger.log(`🚿 EXECUTING WATER ACTION`);
        this.logger.log(`   Garden: ${garden.name} (${garden._id})`);
        this.logger.log(`   Zone: ${zone.name} (Position ${zone.position})`);
        this.logger.log(`   Duration: ${duration}`);
        this.logger.log(`   Source: ${source}`);

        if (duration <= 0) {
            this.logger.log('Weather control determined that watering should be skipped');
            return;
        }
        await mqttService.sendWaterCommand(
            garden,
            zone._id.toString(),
            zone.position,
            duration,
            source
        );
    }

    /**
     * Check if it's time to execute for complex intervals
     */
    // shouldExecuteNow(waterSchedule) {
    //     try {
    //         const nextWaterTime = calculateNextWaterTime(waterSchedule.start_time, waterSchedule.interval);
    //         console.log('Next water time calculated as: %s', nextWaterTime.toUTCString());
    //         const now = new Date();
    //         now.setMilliseconds(0);
    //         console.log('Current time is: %s', now.toUTCString());
    //         // Allow execution within 1 minute window
    //         const timeDiff = nextWaterTime.getTime() - now.getTime();
    //         console.log('Time difference (ms): %d', timeDiff);
    //         return timeDiff >= 0 && timeDiff < 60000; // Within 1 minute
    //     } catch (error) {
    //         this.logger.error('Error checking execution time:', error);
    //         return false;
    //     }
    // }

    /**
     * Remove a scheduled job by water schedule ID
     */
    removeJobById(waterScheduleId) {
        const jobInfo = this.scheduledJobs.get(waterScheduleId);

        if (jobInfo) {
            jobInfo.task.destroy();
            this.scheduledJobs.delete(waterScheduleId);
            this.logger.log(`Removed cron job for water schedule: ${waterScheduleId}`);
            schedulerJobsGauge.dec(waterScheduleLabels(jobInfo.waterSchedule), 1);
            return true;
        }
        return false;
    }

    /**
     * Reset/reschedule a water schedule
     */
    async resetWaterSchedule(waterSchedule) {
        this.logger.log(`Resetting water schedule: ${waterSchedule._id}`);
        this.removeJobById(waterSchedule._id.toString());
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

        // Use node-cron's built-in method to get next execution time
        const nextRun = jobInfo.task.getNextRun();

        // Convert to Date object if needed
        const nextTime = nextRun instanceof Date ? nextRun : new Date(nextRun);
        return nextTime;
    }



    /**
     * Get all active jobs
     */
    getActiveJobs() {
        const jobs = [];
        for (const [jobId, jobInfo] of this.scheduledJobs) {
            jobs.push({
                job_id: jobId,
                type: jobInfo.type || 'water',
                name: jobInfo.waterSchedule ? jobInfo.waterSchedule.name : (jobInfo.garden ? jobInfo.garden.name : 'N/A'),
                cron_pattern: jobInfo.cronPattern,
                created_at: jobInfo.createdAt,
                next_execution: this.getNextExecutionTime(jobId)
            });
        }
        return jobs.sort((a, b) => a.next_execution - b.next_execution);
    }

    /**
     * Stop all scheduled jobs
     */
    stopAllJobs() {
        this.logger.log(`Stopping ${this.scheduledJobs.size} scheduled jobs`);
        for (const [jobId, jobInfo] of this.scheduledJobs) {
            schedulerJobsGauge.dec(jobInfo.type === 'water' ? waterScheduleLabels(jobInfo.waterSchedule) : gardenLabels(jobInfo.garden), 1);
            jobInfo.task.destroy();
        }
        this.scheduledJobs.clear();
    }

    // Light Schedule Management Methods

    /**
     * Schedule light actions for a garden (ON and OFF)
     */
    async scheduleLightActions(garden) {
        try {
            if (!garden.light_schedule || !garden.light_schedule.start_time || !garden.light_schedule.duration_ms) {
                throw new Error('Garden must have complete light_schedule configuration');
            }

            // Remove existing light jobs for this garden
            this.removeLightJobsByGardenId(garden._id.toString());

            // Parse start_time to get hour and minute
            const timeMatch = garden.light_schedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})/);
            if (!timeMatch) {
                throw new Error(`Invalid start_time format: ${garden.light_schedule.start_time}`);
            }

            const [, hours, minutes] = timeMatch;

            // Parse duration
            const durationMs = garden.light_schedule.duration_ms;
            const durationHours = Math.floor(durationMs / (1000 * 60 * 60));
            const durationMinutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60));

            // Calculate OFF time
            const offHours = (parseInt(hours) + durationHours) % 24;
            const offMinutes = (parseInt(minutes) + durationMinutes) % 60;

            // Create cron patterns for daily schedule
            const onCronPattern = `${minutes} ${hours} * * *`;  // Daily at start_time
            const offCronPattern = `${offMinutes} ${offHours} * * *`;  // Daily at start_time + duration

            // Schedule ON action with conflict handling
            const onTask = cron.schedule(onCronPattern, async () => {
                try {
                    await this.executeLightActionInScheduledJob(garden, 'ON');
                } catch (error) {
                    schedulerErrors.inc(gardenLabels(garden), 1);
                    this.logger.error('Error executing scheduled light ON action:', error);
                    if (garden.notification_client_id) {
                        notificationService.sendNotification(garden.notification_client_id, `${garden.name}: Light Action Error`, error.message).catch((err) => {
                            this.logger.error("Error sending light action error notification:", err);
                        });
                    }
                }
            }, {
                scheduled: true,
                timezone: 'UTC'
            });

            // Schedule OFF action
            const offTask = cron.schedule(offCronPattern, async () => {
                try {
                    await this.executeLightActionInScheduledJob(garden, 'OFF');
                } catch (error) {
                    schedulerErrors.inc(gardenLabels(garden), 1);
                    this.logger.error('Error executing scheduled light OFF action:', error);
                    if (garden.notification_client_id) {
                        notificationService.sendNotification(garden.notification_client_id, `${garden.name}: Light Action Error`, error.message).catch((err) => {
                            this.logger.error("Error sending light action error notification:", err);
                        });
                    }
                }
            }, {
                scheduled: true,
                timezone: 'UTC'
            });

            // Store the jobs
            this.scheduledJobs.set(`light_${garden._id}_ON`, {
                task: onTask,
                garden: garden,
                action: 'ON',
                cronPattern: onCronPattern,
                type: 'light',
                createdAt: new Date()
            });

            this.scheduledJobs.set(`light_${garden._id}_OFF`, {
                task: offTask,
                garden: garden,
                action: 'OFF',
                cronPattern: offCronPattern,
                type: 'light',
                createdAt: new Date()
            });
            schedulerJobsGauge.inc(gardenLabels(garden), 2); // ON and OFF jobs

            // Handle adhoc_on_time if present
            if (garden.light_schedule.adhoc_on_time) {
                // If AdhocOnTime is in the past, reset it and return
                const adhocTime = new Date(garden.light_schedule.adhoc_on_time);
                if (adhocTime <= new Date()) {
                    this.logger.log('Adhoc ON time is in the past and is being removed');
                    await db.gardens.updateById({
                        id: garden._id.toString(), data: {
                            light_schedule: {
                                ...garden.light_schedule,
                                adhoc_on_time: null
                            }
                        }
                    });
                    return;
                }

                // Get next ON job (non-adhoc) to check for conflicts
                const nextOnJob = this.getNextLightJob(garden, 'ON', false);
                if (nextOnJob) {
                    const nextOnTime = await nextOnJob.task.getNextRun();
                    // If nextOnTime is before AdhocOnTime, delay it by 24 hours
                    if (nextOnTime && nextOnTime.getTime() < adhocTime.getTime()) {
                        this.logger.log('Next ON time is before the adhoc time, so delaying it by 24 hours');
                        await this.updateJobStartTime(nextOnJob, garden, 'ON', 24 * 60 * 60 * 1000);
                    }
                }

                // Schedule the adhoc action
                await this.scheduleAdhocLightAction(garden);
                this.logger.log('Successfully scheduled adhoc ON time');
            }

            this.logger.log(`Successfully scheduled light actions for garden ${garden.name}`);
            return true;
        } catch (error) {
            schedulerErrors.inc(gardenLabels(garden), 1);
            this.logger.error(`Error scheduling light actions for garden ${garden._id}:`, error);
            return false;
        }
    }

    /**
     * Execute a light action
     */
    async executeLightActionInScheduledJob(garden, state) {
        if (garden.notification_client_id) {
            notificationService.sendDownNotification(garden, garden.notification_client_id, "Light")
        }
        await gardenService.executeLightAction(garden, { state: state });
        this.logger.log(`Successfully sent light ${state} command to garden ${garden.name}`);
        notificationService.sendLightActionNotification(garden, state)
    }

    /**
     * scheduleAdhocLightAction schedules a one-time action to turn a light on
     */
    async scheduleAdhocLightAction(garden) {
        if (!garden.light_schedule.adhoc_on_time) {
            throw new Error('Unable to schedule adhoc light schedule without AdhocOnTime');
        }

        // Remove existing adhoc Jobs for this Garden
        this.removeAdhocJobsByGardenId(garden._id.toString());

        const adhocTime = new Date(garden.light_schedule.adhoc_on_time);
        const adhocJobId = `light_${garden._id}_ADHOC`;

        // Create one-time schedule
        const cronTime = `${adhocTime.getUTCMinutes()} ${adhocTime.getUTCHours()} ${adhocTime.getUTCDate()} ${adhocTime.getUTCMonth() + 1} *`;

        const executeDelayedLightAction = async () => {
            await this.executeLightActionInScheduledJob(garden, 'ON');
            const currentGarden = await db.gardens.getById({ id: garden._id.toString() });
            await db.gardens.updateById({
                id: garden._id.toString(), data: {
                    light_schedule: {
                        ...currentGarden.light_schedule,
                        adhoc_on_time: null
                    }
                }
            });
            this.logger.log('Removed AdhocOnTime');

            // Remove this job
            this.scheduledJobs.delete(adhocJobId);
        };

        // Schedule the LightAction execution
        const adhocTask = cron.schedule(cronTime, async () => {
            try {
                await executeDelayedLightAction();
                schedulerJobsGauge.dec(gardenLabels(garden), 1);
            } catch (error) {
                schedulerErrors.inc(gardenLabels(garden), 1);
                this.logger.error('Error executing scheduled adhoc LightAction:', error);
            }
        }, {
            scheduled: true,
            timezone: 'UTC'
        });

        this.scheduledJobs.set(adhocJobId, {
            task: adhocTask,
            garden: garden,
            action: 'ON',
            cronPattern: cronTime,
            type: 'light_adhoc',
            createdAt: new Date()
        });
        schedulerJobsGauge.inc(gardenLabels(garden), 1);
    }

    /**
     * Remove adhoc jobs for a specific garden
     */
    removeAdhocJobsByGardenId(gardenId) {
        const jobsToRemove = [];
        for (const [jobId, jobInfo] of this.scheduledJobs) {
            if (jobInfo.type === 'light_adhoc' && jobInfo.garden._id.toString() === gardenId) {
                jobsToRemove.push(jobId);
            }
        }

        for (const jobId of jobsToRemove) {
            const jobInfo = this.scheduledJobs.get(jobId);
            jobInfo.task.destroy();
            this.scheduledJobs.delete(jobId);
            this.logger.log(`Removed adhoc light job: ${jobId}`);
            schedulerJobsGauge.dec(gardenLabels(jobInfo.garden), 1);
        }
    }

    /**
     * Reset light schedule for a garden
     */
    async resetLightSchedule(garden) {
        this.removeLightJobsByGardenId(garden._id.toString());
        return await this.scheduleLightActions(garden);
    }

    /**
     * Schedule light delay - handles a LightAction that requests delaying turning a light on
     */
    async scheduleLightDelay(garden, state, delayDuration) {
        if (state !== 'OFF') {
            throw new ApiError(400, 'Unable to use delay when state is not OFF');
        }

        // Parse delay duration
        const lightDurationMs = garden.light_schedule.duration_ms;

        if (delayDuration > lightDurationMs) {
            throw new ApiError(400, 'Unable to execute delay that lasts longer than the light duration');
        }

        const nextOnTime = this.getNextLightTime(garden, 'ON');
        if (!nextOnTime) {
            throw new ApiError(500, 'Unable to get next light-on time');
        }

        const nextOffTime = this.getNextLightTime(garden, 'OFF');
        if (!nextOffTime) {
            throw new ApiError(500, 'Unable to get next light-off time');
        }

        let adhocTime;
        // If nextOffTime is before nextOnTime, then the light was probably ON and we need to schedule now + delay to turn back on.
        // No need to change any schedules
        if (nextOffTime.getTime() < nextOnTime.getTime()) {
            this.logger.log(`Next OFF time is before next ON time; setting schedule to turn light back on after delay`);
            const now = new Date();

            // Don't allow a delayDuration that will occur after nextOffTime
            if (nextOffTime.getTime() < (now.getTime() + delayDuration)) {
                throw new ApiError(400, 'Unable to schedule delay that extends past the light turning back on');
            }

            adhocTime = new Date(now.getTime() + delayDuration);
        } else {
            // If nextOffTime is after nextOnTime, then light was not ON yet and we need to reschedule the regular ON time
            // and schedule nextOnTime + delay
            this.logger.log(`Next OFF time is after next ON time; delaying next ON time`);

            // Get the next ON job and delay it by 24 hours (following Go logic exactly)
            const nextOnJob = this.getNextLightJob(garden, 'ON', false);
            if (!nextOnJob) {
                throw new ApiError(500, 'Unable to find next ON Job for Garden');
            }

            this.logger.log(`Found next ON Job and rescheduling in 24 hours`);

            // Update the existing job to start 24 hours later
            await this.updateJobStartTime(nextOnJob, garden, 'ON', 24 * 60 * 60 * 1000); // +24 hours

            // Set adhoc time to original nextOnTime + delay
            adhocTime = new Date(nextOnTime.getTime() + delayDuration);
        }
        // Update garden with adhoc_on_time and save
        const updatedGarden = await db.gardens.updateById({
            id: garden._id.toString(), data: {
                light_schedule: {
                    ...garden.light_schedule,
                    adhoc_on_time: adhocTime.toISOString()
                }
            }
        });

        // Schedule the adhoc action
        await this.scheduleAdhocLightAction(updatedGarden);
    }

    /**
     * Update job start time by the specified delay
     */
    async updateJobStartTime(jobInfo, garden, state, delayMs) {

        this.logger.log(`Updating ${state} job start time by ${delayMs}ms for garden: ${garden.name}`);

        // Get current next run time
        const currentNextRun = jobInfo.task.getNextRun();
        if (!currentNextRun) {
            throw new Error(`Unable to get next execution time for ${state} job`);
        }

        // Calculate new start time (current + delay)
        const newStartTime = new Date(currentNextRun.getTime() + delayMs);

        // Destroy current job
        jobInfo.task.destroy();

        // Remove from scheduled jobs
        this.scheduledJobs.delete(`light_${garden._id}_${state}`);
        schedulerJobsGauge.dec(gardenLabels(garden), 1);

        // Create new job with delayed start time but same pattern for future runs
        const timeMatch = garden.light_schedule.start_time.match(/^(\d{2}):(\d{2}):(\d{2})/);
        const [, hours, minutes] = timeMatch;
        const regularPattern = `${minutes} ${hours} * * *`;

        // Create one-time job for the delayed execution, then resume regular schedule
        const delayedCronPattern = `${newStartTime.getMinutes()} ${newStartTime.getHours()} ${newStartTime.getDate()} ${newStartTime.getMonth() + 1} *`;

        const delayedTask = cron.schedule(delayedCronPattern, async () => {
            try {
                await this.executeLightActionInScheduledJob(garden, state);
                schedulerJobsGauge.dec(gardenLabels(garden), 1);
            } catch (error) {
                schedulerErrors.inc(gardenLabels(garden), 1);
                this.logger.error('Error executing delayed LightAction:', error);
            }

            // After executing delayed job, recreate regular daily schedule
            this.scheduledJobs.delete(`light_${garden._id}_DELAYED`);

            // Recreate regular daily job
            const regularTask = cron.schedule(regularPattern, async () => {
                try {
                    schedulerJobsGauge.dec(gardenLabels(garden), 1);
                    await this.executeLightActionInScheduledJob(garden, state);
                } catch (error) {
                    schedulerErrors.inc(gardenLabels(garden), 1);
                    this.logger.error('Error executing scheduled light action:', error);
                }
            }, {
                scheduled: true,
                timezone: 'UTC'
            });

            // Store the regular job
            this.scheduledJobs.set(`light_${garden._id}_${state}`, {
                task: regularTask,
                garden: garden,
                action: state,
                cronPattern: regularPattern,
                type: 'light',
                createdAt: new Date()
            });
            schedulerJobsGauge.inc(gardenLabels(garden), 1);

        }, {
            scheduled: true,
        });

        // Store the delayed job temporarily
        this.scheduledJobs.set(`light_${garden._id}_DELAYED`, {
            task: delayedTask,
            garden: garden,
            action: state,
            cronPattern: delayedCronPattern,
            type: 'light_delayed',
            createdAt: new Date()
        });

        schedulerJobsGauge.inc(gardenLabels(garden), 1);
    }

    /**
     * getNextLightJob returns the next Job tagged with the gardenID and state. 
     * If allowAdhoc is true, return whichever job is soonest, otherwise return the first non-adhoc Job
     */
    getNextLightJob(garden, state, allowAdhoc = false) {
        // Find all jobs for this garden and state
        const matchingJobs = [];
        for (const [jobId, jobInfo] of this.scheduledJobs) {
            if (jobInfo.garden && jobInfo.garden._id.toString() === garden._id.toString() &&
                jobInfo.action === state &&
                (jobInfo.type === 'light' || jobInfo.type === 'light_adhoc' || jobInfo.type === 'light_delayed')) {

                const nextRun = jobInfo.task.getNextRun();
                if (nextRun) {
                    matchingJobs.push({
                        jobId,
                        jobInfo,
                        nextRun,
                        isAdhoc: jobInfo.type === 'light_adhoc'
                    });
                }
            }
        }

        if (matchingJobs.length === 0) {
            console.log(`Unable to find next ${state} Job for Garden ${garden._id}`);
            return null;
        }

        // Sort by next run time (earliest first)
        matchingJobs.sort((a, b) => a.nextRun.getTime() - b.nextRun.getTime());

        if (allowAdhoc) {
            return matchingJobs[0].jobInfo;
        }

        // If allowAdhoc is false, find first non-adhoc job
        for (const job of matchingJobs) {
            if (!job.isAdhoc) {
                return job.jobInfo;
            }
        }

        console.log(`Unable to find next non-adhoc ${state} Job for Garden ${garden._id}`);
        return null;
    }

    /**
     * GetNextLightTime returns the next time that the Garden's light will be turned to the specified state
     */
    getNextLightTime(garden, state) {
        const nextJob = this.getNextLightJob(garden, state, true);
        if (!nextJob) {
            return null;
        }
        return nextJob.task.getNextRun();
    }

    /**
     * Remove light jobs for a specific garden
     */
    removeLightJobsByGardenId(gardenId) {
        const jobsToRemove = [];
        for (const [jobId, jobInfo] of this.scheduledJobs) {
            if (jobInfo.type === 'light' || jobInfo.type === 'light_adhoc' || jobInfo.type === 'light_delayed') {
                if (jobInfo.garden._id.toString() === gardenId) {
                    jobsToRemove.push(jobId);
                }
            }
        }

        for (const jobId of jobsToRemove) {
            const jobInfo = this.scheduledJobs.get(jobId);
            jobInfo.task.destroy();
            this.scheduledJobs.delete(jobId);
            this.logger.log(`Removed light job: ${jobId}`);
            schedulerJobsGauge.dec(gardenLabels(jobInfo.garden), 1);
        }
    }

    /**
     * Initialize scheduler - load all active water schedules and light schedules
     */
    async initialize() {
        this.logger.log('Initializing cron scheduler...');

        // Get all active water schedules
        const waterSchedules = await db.waterSchedules.getAll({ filters: { end_date: null } });

        let scheduledWaterCount = 0;
        for (const schedule of waterSchedules) {
            const success = await this.scheduleWaterAction(schedule);
            if (success) scheduledWaterCount++;
        }

        // Get all active gardens with light schedules
        const gardens = await db.gardens.getAll({ filters: { end_date: null } });
        let scheduledLightCount = 0;

        for (const garden of gardens) {
            const success = await this.scheduleLightActions(garden);
            if (success) scheduledLightCount++;
        }

        this.logger.log(`✅ Cron scheduler initialized with ${scheduledWaterCount} water schedules and ${scheduledLightCount} light schedules`);
    }
}

// Create singleton instance
const cronScheduler = new CronScheduler();

module.exports = cronScheduler;