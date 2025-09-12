const express = require('express');
const router = express.Router();
const GardensController = require('../controllers/gardensController');

// Gardens routes
router.get('/', GardensController.getAllGardens);
router.post('/', GardensController.createGarden);
router.get('/:gardenID', GardensController.getGarden);
router.patch('/:gardenID', GardensController.updateGarden);
router.delete('/:gardenID', GardensController.endDateGarden);
router.post('/:gardenID/action', GardensController.gardenAction);

module.exports = router;