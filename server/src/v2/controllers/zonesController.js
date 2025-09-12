const db = require('../models/database');
const { validateXid, addTimestamps, createLink, generateXid, getMockWeatherData, getNextWaterTime } = require('../utils/helpers');
const mqttService = require('../services/mqttService');

const ZonesController = {
    getAllZones: (req, res) => {
        const { gardenID } = req.params;
        const { end_dated, exclude_weather_data } = req.query;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const zones = Array.from(db.zones.values()).filter(zone => zone.garden_id === gardenID);

        let filteredZones = zones;
        if (!end_dated || end_dated === 'false') {
            filteredZones = zones.filter(zone => !zone.end_date);
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            items: filteredZones.map(zone => ({
                ...zone,
                links: [
                    createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                    createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
                ],
                weather_data: weatherData,
                next_water: {
                    time: getNextWaterTime(),
                    duration: '15m',
                    water_schedule_id: zone.water_schedule_ids?.[0] || generateXid(),
                    message: 'Next scheduled watering'
                }
            }))
        });
    },

    addZone: (req, res) => {
        const { gardenID } = req.params;
        const { exclude_weather_data } = req.query;
        const { name, position, water_schedule_ids, details, skip_count } = req.body;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        if (!name || position === undefined || !water_schedule_ids) {
            return res.status(400).json({ error: 'Name, position, and water_schedule_ids are required' });
        }

        // Check if garden exists
        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        // Check if position is already taken
        const existingZone = Array.from(db.zones.values())
            .find(z => z.garden_id === gardenID && z.position === position && !z.end_date);

        if (existingZone) {
            return res.status(400).json({ error: `Position ${position} is already occupied by zone "${existingZone.name}"` });
        }

        // Check if position exceeds max_zones
        if (garden.max_zones && position >= garden.max_zones) {
            return res.status(400).json({ error: `Position ${position} exceeds garden max zones (${garden.max_zones})` });
        }

        const zone = {
            id: generateXid(),
            garden_id: gardenID,
            name,
            position,
            water_schedule_ids,
            details,
            skip_count: skip_count || 0,
            ...addTimestamps({})
        };

        db.zones.set(zone.id, zone);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.status(201).json({
            ...zone,
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: '15m',
                water_schedule_id: zone.water_schedule_ids[0],
                message: 'Next scheduled watering'
            }
        });
    },

    getZone: (req, res) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;

        if (!validateXid(gardenID) || !validateXid(zoneID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const zone = db.zones.get(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...zone,
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: '15m',
                water_schedule_id: zone.water_schedule_ids?.[0] || generateXid(),
                message: 'Next scheduled watering'
            }
        });
    },

    updateZone: (req, res) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;

        if (!validateXid(gardenID) || !validateXid(zoneID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const zone = db.zones.get(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        // Check if position is being changed and if it conflicts with existing zones
        if (req.body.position !== undefined && req.body.position !== zone.position) {
            const existingZone = Array.from(db.zones.values())
                .find(z => z.garden_id === gardenID && z.position === req.body.position && z.id !== zoneID && !z.end_date);

            if (existingZone) {
                return res.status(400).json({ error: `Position ${req.body.position} is already occupied by zone "${existingZone.name}"` });
            }
        }

        const updatedZone = {
            ...zone,
            ...req.body,
            id: zoneID,
            garden_id: gardenID
        };

        db.zones.set(zoneID, updatedZone);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...updatedZone,
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: '15m',
                water_schedule_id: zone.water_schedule_ids?.[0] || generateXid(),
                message: 'Next scheduled watering'
            }
        });
    },

    endDateZone: (req, res) => {
        const { gardenID, zoneID } = req.params;

        if (!validateXid(gardenID) || !validateXid(zoneID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const zone = db.zones.get(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        zone.end_date = new Date().toISOString();
        db.zones.set(zoneID, zone);

        res.json({
            ...zone,
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`)
            ]
        });
    },

    zoneAction: async (req, res) => {
        const { gardenID, zoneID } = req.params;
        const action = req.body;

        if (!validateXid(gardenID) || !validateXid(zoneID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const zone = db.zones.get(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        if (zone.end_date) {
            return res.status(400).json({ error: 'Cannot perform actions on end-dated zone' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        if (garden.end_date) {
            return res.status(400).json({ error: 'Cannot perform actions on end-dated garden' });
        }

        try {
            // Handle water action
            if (action.water) {
                // await mqttService.sendWaterCommand(garden, zone.position, action.water.duration);
                // console.log(`Water command sent to zone ${zone.name} (position ${zone.position}):`, action.water);

                // Optimistically record water event (will be confirmed by ESP32 response)
                const historyRecord = {
                    id: generateXid(),
                    zone_id: zoneID,
                    duration: action.water.duration,
                    record_time: new Date().toISOString(),
                    status: 'commanded' // Will be updated when ESP32 confirms
                };

                if (!db.waterHistory.has(zoneID)) {
                    db.waterHistory.set(zoneID, []);
                }
                db.waterHistory.get(zoneID).push(historyRecord);
            }

            res.status(202).json({
                message: 'Action command sent to ESP32',
                garden_id: gardenID,
                zone_id: zoneID,
                zone_position: zone.position,
                action: action
            });

        } catch (error) {
            console.error('Failed to send zone action to ESP32:', error);
            res.status(500).json({
                error: 'Failed to communicate with garden controller',
                details: error.message
            });
        }
    },

    zoneHistory: async (req, res) => {
        const { gardenID, zoneID } = req.params;
        const { range = '72h', limit = 0 } = req.query;

        if (!validateXid(gardenID) || !validateXid(zoneID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const zone = db.zones.get(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        // try {
        //     // Try to get history from InfluxDB first
        //     if (mqttService.influxDB) {
        //         const influxHistory = await mqttService.influxDB.getWaterHistory(
        //             garden.topic_prefix,
        //             zone.position,
        //             range,
        //             limit > 0 ? limit : 0
        //         );

        //         if (influxHistory.length > 0) {
        //             const totalMs = influxHistory.reduce((sum, record) => {
        //                 const ms = mqttService.influxDB.parseDurationToMs(record.duration);
        //                 return sum + ms;
        //             }, 0);

        //             return res.json({
        //                 zone_id: zoneID,
        //                 zone_name: zone.name,
        //                 history: influxHistory,
        //                 summary: {
        //                     count: influxHistory.length,
        //                     total_duration: `${totalMs}ms`,
        //                     average_duration: `${Math.round(totalMs / influxHistory.length)}ms`,
        //                     range_requested: range,
        //                     limit_applied: limit > 0 ? limit : null,
        //                     data_source: 'influxdb'
        //                 }
        //             });
        //         }
        //     }
        // } catch (error) {
        //     console.warn('InfluxDB query failed, falling back to in-memory:', error.message);
        // }

        // Fallback to in-memory data
        let history = db.waterHistory.get(zoneID) || [];

        // Apply range filter
        const now = new Date();
        let rangeMs;

        const rangeMatch = range.match(/^(\d+)([hmsd])$/);
        if (rangeMatch) {
            const value = parseInt(rangeMatch[1]);
            const unit = rangeMatch[2];

            switch (unit) {
                case 'm': rangeMs = value * 60 * 1000; break;
                case 'h': rangeMs = value * 60 * 60 * 1000; break;
                case 'd': rangeMs = value * 24 * 60 * 60 * 1000; break;
                case 's': rangeMs = value * 1000; break;
                default: rangeMs = 72 * 60 * 60 * 1000;
            }
        } else {
            rangeMs = 72 * 60 * 60 * 1000;
        }

        const cutoffTime = new Date(now.getTime() - rangeMs);
        history = history.filter(record => new Date(record.record_time) > cutoffTime);

        history.sort((a, b) => new Date(b.record_time) - new Date(a.record_time));

        if (limit > 0) {
            history = history.slice(0, limit);
        }

        const count = history.length;
        const totalMs = history.reduce((sum, record) => {
            const duration = record.duration;
            const ms = duration.includes('ms') ? parseInt(duration) :
                duration.includes('s') ? parseInt(duration) * 1000 :
                    duration.includes('m') ? parseInt(duration) * 60 * 1000 : 0;
            return sum + ms;
        }, 0);

        const averageMs = count > 0 ? totalMs / count : 0;

        res.json({
            zone_id: zoneID,
            zone_name: zone.name,
            history: history.map(record => ({
                duration: record.duration,
                record_time: record.record_time,
                status: record.status || 'completed'
            })),
            summary: {
                count,
                total_duration: `${totalMs}ms`,
                average_duration: `${Math.round(averageMs)}ms`,
                range_requested: range,
                limit_applied: limit > 0 ? limit : null,
                data_source: 'memory'
            }
        });
    }
};

module.exports = ZonesController;