const express = require('express');
const router = express.Router();
const PlantsController = require('../controllers/plantsController');

// Plants routes
router.get('/:gardenID/plants', PlantsController.getAllPlants);
router.post('/:gardenID/plants', PlantsController.addPlant);
router.get('/:gardenID/plants/:plantID', PlantsController.getPlant);
router.patch('/:gardenID/plants/:plantID', PlantsController.updatePlant);
router.delete('/:gardenID/plants/:plantID', PlantsController.endDatePlant);

module.exports = router;