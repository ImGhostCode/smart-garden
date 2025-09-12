const express = require('express');
const router = express.Router();
const WaterSchedulesController = require('../controllers/waterSchedulesController');

// Water Schedules routes
router.get('/', WaterSchedulesController.getAllWaterSchedules);
router.post('/', WaterSchedulesController.addWaterSchedule);
router.get('/:waterScheduleID', WaterSchedulesController.getWaterSchedule);
router.patch('/:waterScheduleID', WaterSchedulesController.updateWaterSchedule);
router.delete('/:waterScheduleID', WaterSchedulesController.endDateWaterSchedule);

module.exports = router;