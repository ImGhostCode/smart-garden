const db = require('../models/database');
const { createLink, generateXid, getMockWeatherData, getNextWaterTime } = require('../utils/helpers');
const mqttService = require('../services/mqttService');

const ZonesController = {
    getAllZones: async (req, res) => {
        const { gardenID } = req.params;
        const { end_dated, exclude_weather_data } = req.query;
        const filters = { garden_id: gardenID };
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        const zones = await db.zones.getAll(filters);

        res.json({
            items: zones.map(zone => ({
                ...zone.toObject(),
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

    addZone: async (req, res) => {
        const { gardenID } = req.params;
        const { exclude_weather_data } = req.query;
        const { name, details, position, water_schedule_ids, skip_count } = req.body;


        // Check if garden exists
        const garden = await db.gardens.getById(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        // Check if position is already taken
        const existingZone = Array.from(await db.zones.getAll({ garden_id: gardenID, end_date: null }))
            .find(z => z.position === position && !z.end_date);

        if (existingZone) {
            return res.status(400).json({ error: `Position ${position} is already occupied by zone "${existingZone.name}"` });
        }

        // Check if position exceeds max_zones
        if (garden.max_zones && position >= garden.max_zones) {
            return res.status(400).json({ error: `Position ${position} exceeds garden max zones (${garden.max_zones})` });
        }

        const zone = {
            garden_id: gardenID,
            name,
            position,
            water_schedule_ids,
            details,
            skip_count: skip_count || 0,
        };

        await db.zones.create(zone);

        res.status(201).json({
            ...zone,
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
        });
    },

    getZone: async (req, res) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...zone.toObject(),
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

    updateZone: async (req, res) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;
        const { name, details, position, water_schedule_ids, skip_count } = req.body;

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const garden = await db.gardens.getById(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        if (garden.max_zones && position !== undefined && position >= garden.max_zones) {
            return res.status(400).json({ error: `Position ${position} exceeds garden max zones (${garden.max_zones})` });
        }

        // Check if position is being changed and if it conflicts with existing zones
        if (position !== undefined && position !== zone.position) {
            const existingZone = Array.from(await db.zones.getAll({ garden_id: gardenID, end_date: null }))
                .find(z => z.garden_id === gardenID && z.position === position && z.id !== zoneID && !z.end_date);

            if (existingZone) {
                return res.status(400).json({ error: `Position ${position} is already occupied by zone "${existingZone.name}"` });
            }
        }

        const updates = {};

        if (name !== undefined) updates.name = name;
        if (details !== undefined) updates.details = details;
        if (position !== undefined) updates.position = position;
        if (water_schedule_ids !== undefined) updates.water_schedule_ids = water_schedule_ids;
        if (skip_count !== undefined) updates.skip_count = skip_count;

        const updatedZone = await db.zones.updateById(zoneID, updates);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...updatedZone.toObject(),
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

    endDateZone: async (req, res) => {
        const { gardenID, zoneID } = req.params;

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const updatedZone = await db.zones.deleteById(zoneID);

        res.json({
            ...updatedZone.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`)
            ]
        });
    },

    zoneAction: async (req, res) => {
        const { gardenID, zoneID } = req.params;
        const action = req.body;

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const garden = await db.gardens.getById(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        try {
            // Handle water action
            if (action.water) {
                await mqttService.sendWaterCommand(garden, zoneID, zone.position, action.water.duration);
                console.log(`Water command sent to zone ${zone.name} (position ${zone.position}):`, action.water);

                // Optimistically record water event (will be confirmed by ESP32 response)
                // const historyRecord = {
                //     id: generateXid(),
                //     zone_id: zoneID,
                //     duration: action.water.duration,
                //     record_time: new Date().toISOString(),
                //     status: 'commanded' // Will be updated when ESP32 confirms
                // };

                // if (!db.waterHistory.has(zoneID)) {
                //     db.waterHistory.set(zoneID, []);
                // }
                // db.waterHistory.get(zoneID).push(historyRecord);
            }

            res.status(202);

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

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const garden = await db.gardens.getById(gardenID);
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

        res.json({
            "history": [
                {
                    "duration": "15000ms",
                    "record_time": "2025-09-16T09:48:13.107Z"
                }
            ],
            "count": 1,
            "average": "15s",
            "total": "15s"
        });
    }
};

module.exports = ZonesController;