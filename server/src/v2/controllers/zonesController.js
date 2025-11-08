const db = require('../models/database');
const { createLink, durationToMillis } = require('../utils/helpers');
const { getNextActiveWaterSchedule, getNextWaterDetails } = require('../utils/waterScheduleHelpers');
const mqttService = require('../services/mqttService');
const influxdbService = require('../services/influxdbService');
const { getWeatherData } = require('../utils/weatherHelper');

const ZonesController = {
    getAllZones: async (req, res) => {
        const { gardenID } = req.params;
        const { end_dated, exclude_weather_data } = req.query;
        const filters = { garden_id: gardenID };
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }


        const zones = await db.zones.getAll(filters);

        res.json({
            items: await Promise.all(zones.map(async (zone) => {
                // Get next active water schedule for this zone
                const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
                let weatherData;
                if (nextSchedule.hasWeatherControl() && nextSchedule.end_date == null && exclude_weather_data !== 'true') {
                    weatherData = await getWeatherData(nextSchedule);
                }

                let nextWaterDetails;
                if (nextSchedule) {
                    nextWaterDetails = getNextWaterDetails(
                        nextSchedule,
                        exclude_weather_data === 'true'
                    );

                    // Apply skip count if present
                    if (zone.skip_count && zone.skip_count > 0) {
                        nextWaterDetails.message = `skip_count ${zone.skip_count} affected the time`;
                        //A adjust the time based on skip count: skip_count * interval
                        if (nextWaterDetails.time) {
                            nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * durationToMillis(nextSchedule.interval));
                        }
                    }
                } else {
                    nextWaterDetails = {
                        time: null,
                        message: 'No active water schedules'
                    };
                }

                return {
                    ...zone.toObject(),
                    links: [
                        createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                        createLink('garden', `/gardens/${gardenID}`),
                        createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                        createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
                    ],
                    weather_data: weatherData,
                    next_water: nextWaterDetails
                };
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

        const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
        let weatherData;
        if (nextSchedule.hasWeatherControl() && nextSchedule.end_date == null && exclude_weather_data !== 'true') {
            weatherData = await getWeatherData(nextSchedule);
        }

        let nextWaterDetails;
        if (nextSchedule) {
            nextWaterDetails = getNextWaterDetails(
                nextSchedule,
                exclude_weather_data === 'true'
            );

            // Apply skip count if present
            if (zone.skip_count && zone.skip_count > 0) {
                nextWaterDetails.message = `skip_count ${zone.skip_count} affected the time`;
                //A adjust the time based on skip count: skip_count * interval
                if (nextWaterDetails.time) {
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * durationToMillis(nextSchedule.interval));
                }
            }
        } else {
            nextWaterDetails = {
                time: null,
                message: 'No active water schedules'
            };
        }

        res.json({
            ...zone.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
            weather_data: weatherData,
            next_water: nextWaterDetails
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

        const nextSchedule = await getNextActiveWaterSchedule(updatedZone.water_schedule_ids || []);
        let weatherData;
        if (nextSchedule.hasWeatherControl() && nextSchedule.end_date == null && exclude_weather_data !== 'true') {
            weatherData = await getWeatherData(nextSchedule);
        }

        let nextWaterDetails;
        if (nextSchedule) {
            nextWaterDetails = getNextWaterDetails(
                nextSchedule,
                exclude_weather_data === 'true'
            );

            // Apply skip count if present
            if (updatedZone.skip_count && updatedZone.skip_count > 0) {
                nextWaterDetails.message = `skip_count ${updatedZone.skip_count} affected the time`;
                //A adjust the time based on skip count: skip_count * interval
                if (nextWaterDetails.time) {
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + updatedZone.skip_count * durationToMillis(nextSchedule.interval));
                }
            }
        }
        res.json({
            ...updatedZone.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
            ],
            weather_data: weatherData,
            next_water: nextWaterDetails
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
            if (action.water && action.water.duration) {
                const durationMs = durationToMillis(action.water.duration);
                const result = await mqttService.sendWaterCommand(garden, zoneID, zone.position, durationMs, "command");
                console.log('MQTT water command result:', result);
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
        const { range = '72h', limit = 5 } = req.query;

        const zone = await db.zones.getById(zoneID);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Zone not found' });
        }

        const garden = await db.gardens.getById(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        const result = await influxdbService.getWaterHistory(garden.topic_prefix, range, zoneID, limit);
        res.json(result);
    }
};

module.exports = ZonesController;