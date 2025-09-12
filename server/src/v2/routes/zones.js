const express = require('express');
const router = express.Router();
const ZonesController = require('../controllers/zonesController');

// Zones routes
router.get('/:gardenID/zones', ZonesController.getAllZones);
router.post('/:gardenID/zones', ZonesController.addZone);
router.get('/:gardenID/zones/:zoneID', ZonesController.getZone);
router.patch('/:gardenID/zones/:zoneID', ZonesController.updateZone);
router.delete('/:gardenID/zones/:zoneID', ZonesController.endDateZone);
router.post('/:gardenID/zones/:zoneID/action', ZonesController.zoneAction);
router.get('/:gardenID/zones/:zoneID/history', ZonesController.zoneHistory);

module.exports = router;