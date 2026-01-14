const { Router } = require('express');
const router = Router();
const SchedulerController = require('../controllers/schedulerController');
const Joi = require('joi');
const { validateBody, validateParams, validateQuery } = require('../middlewares/validationMiddleware');
const { schemas } = require('../utils/validation');

// GET /scheduler - Get scheduler status and active jobs
router.get('/', SchedulerController.getSchedulerStatus);

// POST /scheduler/initialize - Initialize/reinitialize scheduler
router.post('/initialize', SchedulerController.initializeScheduler);

// POST /scheduler/stop - Stop all scheduled jobs
router.post('/stop', SchedulerController.stopAllJobs);

// POST /scheduler/water_schedules/:waterScheduleId/schedule - Schedule specific water schedule
router.post('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: schemas.pathParams.id
    })),
    SchedulerController.scheduleWaterSchedule);

// DELETE /scheduler/water_schedules/:waterScheduleId/schedule - Unschedule specific water schedule
router.delete('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: schemas.pathParams.id
    })),
    SchedulerController.unscheduleWaterSchedule);

// PUT /scheduler/water_schedules/:waterScheduleId/schedule - Reschedule water schedule
router.put('/water_schedules/:waterScheduleId/schedule',
    validateParams(Joi.object({
        waterScheduleId: schemas.pathParams.id
    })),
    SchedulerController.rescheduleWaterSchedule);

// POST /scheduler/water_schedules/:waterScheduleId/trigger - Manually trigger water schedule
router.post('/water_schedules/:waterScheduleId/trigger',
    validateParams(Joi.object({
        waterScheduleId: schemas.pathParams.id
    })),
    validateBody(Joi.object({
        force: Joi.boolean().optional().default(false).description('Force execution regardless of conditions')
    })),
    SchedulerController.triggerWaterSchedule);

module.exports = router;