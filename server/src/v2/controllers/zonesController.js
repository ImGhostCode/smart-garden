const db = require('../models/database');
const { createLink, intervalToMillis } = require('../utils/helpers');
const { getNextActiveWaterSchedule, getNextWaterDetails } = require('../utils/waterScheduleHelpers');
const influxdbService = require('../services/influxdbService');
const { getWeatherData } = require('../utils/weatherHelper');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const mqttService = require('../services/mqttService');

const ZonesController = {
    getAllZones: async (req, res, next) => {
        const { gardenID } = req.params;
        const { end_dated, exclude_weather_data } = req.query;
        const filters = { garden_id: gardenID };
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        try {
            const zones = await db.zones.getAll({ filters: filters, garden: true, waterSchedules: true });

            return res.json(new ApiSuccess(200, 'Zones retrieved successfully',
                await Promise.all(zones.map(async (zone) => {
                    // Get next active water schedule for this zone
                    const waterScheduleIds = zone.water_schedule_ids.map(ws => ws._id);
                    const nextSchedule = await getNextActiveWaterSchedule(waterScheduleIds || []);
                    let weatherData;
                    let nextWaterDetails;
                    if (nextSchedule && nextSchedule.hasWeatherControl() && nextSchedule.end_date == null && exclude_weather_data !== 'true') {
                        weatherData = await getWeatherData(nextSchedule);
                    }

                    if (nextSchedule) {
                        nextWaterDetails = await getNextWaterDetails(
                            nextSchedule,
                            exclude_weather_data === 'true'
                        );

                        // Apply skip count if present
                        if (zone.skip_count && zone.skip_count > 0) {
                            nextWaterDetails.message = `skip_count ${zone.skip_count} affected the time`;
                            //A adjust the time based on skip count: skip_count * interval
                            if (nextWaterDetails.time) {
                                nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * intervalToMillis(nextSchedule.interval));
                            }
                        }
                    } else {
                        nextWaterDetails = {
                            time: null,
                            message: 'No active water schedules'
                        };
                    }

                    return {
                        id: zone._id.toString(),
                        ...zone.toObject(),
                        _id: undefined,
                        garden_id: undefined,
                        garden: {
                            id: zone.garden_id._id,
                            name: zone.garden_id.name
                        },
                        water_schedule_ids: undefined,
                        water_schedules: zone.water_schedule_ids
                            .filter(ws => !ws.end_date)
                            .map(ws => ({
                                id: ws._id,
                                ...ws.toObject(),
                                _id: undefined,
                            })),
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
            ));
        } catch (error) {
            next(error);
        }
    },

    addZone: async (req, res, next) => {
        const { gardenID } = req.params;
        const { exclude_weather_data } = req.query;
        const { name, details, position, water_schedule_ids, skip_count } = req.body;

        try {
            // Check if garden exists
            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            // Check if position is already taken
            const existingZone = Array.from(await db.zones.getAll({ filters: { garden_id: gardenID, end_date: null } }))
                .find(z => z.position === position && !z.end_date);

            if (existingZone) {
                throw new ApiError(400, `Position ${position} is already occupied by zone "${existingZone.name}"`);
            }

            // Check if position exceeds max_zones
            if (garden.max_zones && position >= garden.max_zones) {
                throw new ApiError(400, `Position ${position} exceeds garden max zones (${garden.max_zones})`);
            }

            // Check if water schedule ids exist
            if (water_schedule_ids && water_schedule_ids.length > 0) {
                for (const wsid of water_schedule_ids) {
                    const ws = await db.waterSchedules.getById(wsid);
                    if (!ws) {
                        throw new ApiError(404, `Water schedule ID ${wsid} not found`);
                    }
                }
            }

            const zone = {
                garden_id: gardenID,
                name,
                position,
                water_schedule_ids,
                details,
                skip_count: skip_count || 0,
            };

            const newZone = await db.zones.create({ data: zone, garden: true, waterSchedules: true });

            return res.status(201).json(new ApiSuccess(201, 'Zone added successfully', {
                id: newZone._id.toString(),
                ...newZone.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    _id: newZone.garden_id._id,
                    name: newZone.garden_id.name
                },
                water_schedule_ids: undefined,
                water_schedules: newZone.water_schedule_ids.map(ws => ({
                    id: ws._id,
                    ...ws.toObject(),
                    _id: undefined,
                })),
                links: [
                    createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                    createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
                ],
            }));
        } catch (error) {
            next(error);
        }
    },

    getZone: async (req, res, next) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;

        try {
            const zone = await db.zones.getById({ id: zoneID, garden: true, waterSchedules: true });
            if (!zone || zone.garden_id._id.toString() !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const waterScheduleIds = zone.water_schedule_ids.map(ws => ws._id);
            const nextSchedule = await getNextActiveWaterSchedule(waterScheduleIds || []);
            let weatherData;
            if (nextSchedule && nextSchedule.hasWeatherControl() && !nextSchedule.end_date && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(nextSchedule);
            }

            let nextWaterDetails;
            if (nextSchedule) {
                nextWaterDetails = await getNextWaterDetails(
                    nextSchedule,
                    exclude_weather_data === 'true'
                );

                // Apply skip count if present
                if (zone.skip_count && zone.skip_count > 0) {
                    nextWaterDetails.message = `Skip count ${zone.skip_count} affected the time`;
                    //A adjust the time based on skip count: skip_count * interval
                    if (nextWaterDetails.time) {
                        nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * intervalToMillis(nextSchedule.interval));
                    }
                }
            } else {
                nextWaterDetails = {
                    time: null,
                    message: 'No active water schedules'
                };
            }

            return res.json(new ApiSuccess(200, 'Zone retrieved successfully', {
                id: zone._id.toString(),
                ...zone.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    id: zone.garden_id._id,
                    name: zone.garden_id.name
                },
                water_schedule_ids: undefined,
                water_schedules: zone.water_schedule_ids
                    .filter(ws => !ws.end_date)
                    .map(ws => ({
                        id: ws._id,
                        ...ws.toObject(),
                        _id: undefined,
                    })),
                links: [
                    createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                    createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            }));
        } catch (error) {
            next(error);
        }
    },

    updateZone: async (req, res, next) => {
        const { gardenID, zoneID } = req.params;
        const { exclude_weather_data } = req.query;
        const { name, details, position, water_schedule_ids, skip_count } = req.body;

        try {
            const zone = await db.zones.getById({ id: zoneID });
            if (!zone || zone.garden_id.toString() !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            if (garden.max_zones && position && position >= garden.max_zones) {
                throw new ApiError(400, `Position ${position} exceeds garden max zones (${garden.max_zones})`);
            }

            // Check if position is being changed and if it conflicts with existing zones
            if (position && position !== zone.position) {
                const existingZone = Array.from(await db.zones.getAll({ filters: { garden_id: gardenID, end_date: null } }))
                    .find(z => z.garden_id === gardenID && z.position === position && z.id !== zoneID && !z.end_date);

                if (existingZone) {
                    throw new ApiError(400, `Position ${position} is already occupied by zone "${existingZone.name}"`);
                }
            }

            // Check if water schedule ids exist
            if (water_schedule_ids && water_schedule_ids.length > 0) {
                for (const wsid of water_schedule_ids) {
                    const ws = await db.waterSchedules.getById(wsid);
                    if (!ws) {
                        throw new ApiError(404, `Water schedule ID ${wsid} not found`);
                    }
                }
            }

            const updates = {};

            if (name) updates.name = name;
            if (details) updates.details = details;
            if (position) updates.position = position;
            if (water_schedule_ids) updates.water_schedule_ids = water_schedule_ids;
            if (skip_count) updates.skip_count = skip_count;

            const updatedZone = await db.zones.updateById({
                id: zoneID, data: updates,
                garden: true,
                waterSchedules: true
            });

            const waterScheduleIds = updatedZone.water_schedule_ids.map(ws => ws._id);
            const nextSchedule = await getNextActiveWaterSchedule(waterScheduleIds || []);
            let weatherData;
            if (nextSchedule != null && nextSchedule.hasWeatherControl() && !nextSchedule.end_date && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(nextSchedule);
            }

            let nextWaterDetails;
            if (nextSchedule) {
                nextWaterDetails = await getNextWaterDetails(
                    nextSchedule,
                    exclude_weather_data === 'true'
                );

                // Apply skip count if present
                if (updatedZone.skip_count && updatedZone.skip_count > 0) {
                    nextWaterDetails.message = `skip_count ${updatedZone.skip_count} affected the time`;
                    //A adjust the time based on skip count: skip_count * interval
                    if (nextWaterDetails.time) {
                        nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + updatedZone.skip_count * intervalToMillis(nextSchedule.interval));
                    }
                }
            }
            return res.json(new ApiSuccess(200, 'Zone updated successfully', {
                id: updatedZone._id.toString(),
                ...updatedZone.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    id: updatedZone.garden_id._id,
                    name: updatedZone.garden_id.name
                },
                water_schedule_ids: undefined,
                water_schedules: updatedZone.water_schedule_ids.map(ws => ({
                    id: ws._id,
                    ...ws.toObject(),
                    _id: undefined,
                })),
                links: [
                    createLink('self', `/gardens/${gardenID}/zones/${zone.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('action', `/gardens/${gardenID}/zones/${zone.id}/action`),
                    createLink('history', `/gardens/${gardenID}/zones/${zone.id}/history`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            }));
        } catch (error) {
            next(error);
        }
    },

    endDateZone: async (req, res, next) => {
        const { gardenID, zoneID } = req.params;

        try {
            const zone = await db.zones.getById({ id: zoneID });
            if (!zone || zone.garden_id.toString() !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const deletedZone = await db.zones.deleteById(zoneID);

            // TODO: Stop any ongoing watering for this zone
            const garden = await db.gardens.getById(gardenID);
            if (garden) {
                await mqttService.sendClearAction(garden, deletedZone.position);
            }
            return res.json(new ApiSuccess(200, 'Zone end date set successfully', deletedZone.id));
        } catch (error) {
            next(error);
        }
    },

    zoneAction: async (req, res, next) => {
        const { gardenID, zoneID } = req.params;
        const action = req.body;

        try {
            const zone = await db.zones.getById({ id: zoneID });
            if (!zone || zone.garden_id.toString() !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            try {
                // Handle water action
                if (action.water && action.water.duration_ms) {
                    const cronScheduler = require('../services/cronScheduler');
                    await cronScheduler.executeWaterAction(garden, zone, action.water.duration_ms, "command");
                }
                res.status(202).json(new ApiSuccess(202, 'Zone action executed successfully'));
            } catch (error) {
                console.error('Error executing zone action:', error);
                throw new ApiError(500, 'Failed to execute zone action');
            }
        } catch (error) {
            next(error);
        }
    },

    zoneHistory: async (req, res, next) => {
        const { gardenID, zoneID } = req.params;
        const { range = '72h', limit = 5 } = req.query;

        try {
            const zone = await db.zones.getById({ id: zoneID });
            if (!zone || zone.garden_id.toString() !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            const result = await influxdbService.getWaterHistory(garden.topic_prefix, range, zoneID, limit);
            return res.json(new ApiSuccess(200, 'Zone history retrieved successfully', result));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = ZonesController;