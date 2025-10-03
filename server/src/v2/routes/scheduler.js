const express = require('express');
const router = express.Router();
const SchedulerController = require('../controllers/schedulerController');
const Joi = require('joi');
const { validateParams, validateBody } = require('../utils/validation');

// GET /scheduler - Get scheduler status and active jobs
router.get('/', SchedulerController.getSchedulerStatus);

// POST /scheduler/initialize - Initialize/reinitialize scheduler
router.post('/initialize', SchedulerController.initializeScheduler);

// POST /scheduler/stop - Stop all scheduled jobs
router.post('/stop', SchedulerController.stopAllJobs);

// POST /scheduler/water_schedules/:waterScheduleId/schedule - Schedule specific water schedule
router.post('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: Joi.string().required().description('Water schedule ID')
    })),
    SchedulerController.scheduleWaterSchedule);

// DELETE /scheduler/water_schedules/:waterScheduleId/schedule - Unschedule specific water schedule
router.delete('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: Joi.string().required().description('Water schedule ID')
    })),
    SchedulerController.unscheduleWaterSchedule);

// PUT /scheduler/water_schedules/:waterScheduleId/schedule - Reschedule water schedule
router.put('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: Joi.string().required().description('Water schedule ID')
    })),
    SchedulerController.rescheduleWaterSchedule);

// POST /scheduler/water_schedules/:waterScheduleId/trigger - Manually trigger water schedule
router.post('/water_schedules/:waterScheduleId/trigger',
    validateParams(Joi.object({
        waterScheduleId: Joi.string().required().description('Water schedule ID')
    })),
    validateBody(Joi.object({
        force: Joi.boolean().optional().default(false).description('Force execution regardless of conditions')
    })),
    SchedulerController.triggerWaterSchedule);

module.exports = router;