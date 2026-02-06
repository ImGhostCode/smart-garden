const db = require('../models/database');
const { formatGardenResponse } = require('../utils/responseFormatters');
const mqttService = require('../services/mqttService');
const influxdbService = require('../services/influxdbService');
const cronScheduler = require('../services/cronScheduler');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const gardenService = require('../services/gardenService');

const GardensController = {
    getAllGardens: async (req, res, next) => {
        try {
            const { end_dated } = req.query;
            const filters = {};
            if (!end_dated || end_dated === 'false') {
                filters.end_date = null;
            }
            const gardens = await db.gardens.getAll({ filters, notification: true });

            // Get plant and zone counts for each garden
            const gardensWithCounts = await Promise.all(
                gardens.map(async (garden) => {
                    const [plantsCount, zonesCount,
                        health, temHumData, nextOnTime, nextOffTime
                    ] = await Promise.all([
                        db.plants.getByGardenId(garden.id).then(plants =>
                            plants.filter(p => !p.end_date).length
                        ),
                        db.zones.getByGardenId(garden.id).then(zones =>
                            zones.filter(z => !z.end_date).length
                        ),
                        gardenService.getGardenHealth(garden),
                        influxdbService.getTemperatureAndHumidity(garden.topic_prefix).then(data => data),
                        cronScheduler.getNextLightTime(garden, 'ON'),
                        cronScheduler.getNextLightTime(garden, 'OFF')
                    ]);

                    const formattedGarden = formatGardenResponse(garden, req);
                    formattedGarden.health = health;
                    if (temHumData) {
                        formattedGarden.temperature_humidity_data = {
                            temperature_celsius: temHumData.temperature,
                            humidity_percentage: temHumData.humidity
                        };
                    }
                    if (nextOnTime && nextOffTime) {
                        if (nextOnTime < nextOffTime) {
                            formattedGarden.next_light_action = {
                                action: 'ON',
                                time: nextOnTime
                            };
                        } else {
                            formattedGarden.next_light_action = {
                                action: 'OFF',
                                time: nextOffTime
                            };
                        }
                    } else if (nextOnTime) {
                        formattedGarden.next_light_action = {
                            action: 'ON',
                            time: nextOnTime
                        };
                    } else if (nextOffTime) {
                        formattedGarden.next_light_action = {
                            action: 'OFF',
                            time: nextOffTime
                        };
                    }
                    formattedGarden.num_plants = plantsCount;
                    formattedGarden.num_zones = zonesCount;

                    return formattedGarden;
                })
            );

            return res.json(new ApiSuccess(200, 'Gardens retrieved successfully', gardensWithCounts));

        } catch (error) {
            next(error);
        }
    },

    createGarden: async (req, res, next) => {
        try {
            const { name, topic_prefix, max_zones, light_schedule, controller_config, notification_client_id, notification_settings } = req.body;

            if (light_schedule != null) {
                if (light_schedule.duration_ms <= 0 || light_schedule.duration_ms >= (24 * 60 * 60 * 1000)) {
                    throw new ApiError(400, 'Light schedule duration must be greater than 0 and less than or equal to 24 hours in milliseconds');
                }
            }

            if (controller_config != null && (controller_config.valve_pins.length !== controller_config.pump_pins.length || controller_config.valve_pins.length > max_zones)) {
                throw new ApiError(400, 'Controller config valve pins and pump pins length must match and be less than or equal to max zones');
            }

            if (notification_client_id) {
                const client = await db.notificationClients.getById(notification_client_id);
                if (!client) {
                    throw new ApiError(400, 'Notification client does not exist');
                }
            }

            const newGarden = {
                name,
                topic_prefix,
                max_zones: max_zones,
                light_schedule: light_schedule || null,
                controller_config: controller_config || null,
                notification_client_id: notification_client_id || null,
                notification_settings: notification_settings || null,
                end_date: null
            };

            const savedGarden = await db.gardens.create({ data: newGarden, notification: true });

            // Sent config to garden controller via MQTT
            if (controller_config) {
                try {
                    await mqttService.sendUpdateAction(savedGarden, controller_config);
                } catch (mqttError) {
                    console.error('MQTT error sending initial config:', mqttError);
                    // Proceed without failing the request
                }
            }
            if (light_schedule) {
                try {
                    await cronScheduler.scheduleLightActions(savedGarden);
                } catch (scheduleError) {
                    console.error('Scheduling light error:', scheduleError);
                }
            }

            // Format and return the response
            const formattedGarden = formatGardenResponse(savedGarden, req);
            formattedGarden.num_plants = 0;
            formattedGarden.num_zones = 0;

            return res.status(201).json(new ApiSuccess(201, 'Garden created successfully', formattedGarden));

        } catch (error) {
            next(error);
        }
    },

    getGarden: async (req, res, next) => {
        try {
            const { gardenID } = req.params;

            const garden = await db.gardens.getById({ id: gardenID, notification: true });
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            // Get plant and zone counts
            const [plantsCount, zonesCount, health, temHumData, nextOnTime, nextOffTime
            ] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                ),
                gardenService.getGardenHealth(garden),
                influxdbService.getTemperatureAndHumidity(garden.topic_prefix).then(data => data),
                cronScheduler.getNextLightTime(garden, 'ON'),
                cronScheduler.getNextLightTime(garden, 'OFF')
            ]);

            // Format response with HATEOAS links and counts
            const formattedGarden = formatGardenResponse(garden, req);
            formattedGarden.health = health;
            if (temHumData) {
                formattedGarden.temperature_humidity_data = {
                    temperature_celsius: temHumData.temperature,
                    humidity_percentage: temHumData.humidity
                };
            }
            if (nextOnTime && nextOffTime) {
                if (nextOnTime < nextOffTime) {
                    formattedGarden.next_light_action = {
                        action: 'ON',
                        time: nextOnTime
                    };
                } else {
                    formattedGarden.next_light_action = {
                        action: 'OFF',
                        time: nextOffTime
                    };
                }
            } else if (nextOnTime) {
                formattedGarden.next_light_action = {
                    action: 'ON',
                    time: nextOnTime
                };
            } else if (nextOffTime) {
                formattedGarden.next_light_action = {
                    action: 'OFF',
                    time: nextOffTime
                };
            }
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            return res.json(new ApiSuccess(200, 'Garden retrieved successfully', formattedGarden));

        } catch (error) {
            next(error);
        }
    },

    updateGarden: async (req, res, next) => {
        try {
            const { gardenID } = req.params;
            const { name, topic_prefix, max_zones, light_schedule, controller_config, notification_client_id, notification_settings } = req.body;

            // Validate input fields if provided
            const updates = {};
            if (name) {
                updates.name = name;
            }

            if (topic_prefix) {
                updates.topic_prefix = topic_prefix;
            }

            if (max_zones) {
                updates.max_zones = max_zones;
            }

            if (notification_client_id) {
                const client = await db.notificationClients.getById(notification_client_id);
                if (!client) {
                    throw new ApiError(400, 'Notification client does not exist');
                }
                updates.notification_client_id = notification_client_id;
            }

            if (notification_settings) {
                updates.notification_settings = notification_settings;
            }

            if (light_schedule) {
                if (light_schedule) {
                    // Check if duration is valid < 24 hours
                    if (light_schedule.duration_ms <= 0 || light_schedule.duration_ms >= (24 * 60 * 60 * 1000)) {
                        throw new ApiError(400, 'Light schedule duration must be greater than 0 and less than or equal to 24 hours in milliseconds');
                    }

                    if (light_schedule.adhoc_on_time) {
                        const adhocTime = new Date(light_schedule.adhoc_on_time);
                        // Check if adhoc_on_time is greater than now
                        if (isNaN(adhocTime.getTime()) || adhocTime <= new Date()) {
                            // return res.status(400).json({ error: 'light_schedule adhoc_on_time must be a valid ISO 8601 date string in the future' });
                            throw new ApiError(400, 'Light schedule adhocOnTime must be a valid ISO 8601 date string in the future');
                        }
                    }
                }

                updates.light_schedule = light_schedule;
            }

            if (controller_config) {
                updates.controller_config = controller_config;
            }

            if (max_zones && controller_config && controller_config.valve_pins && controller_config.pump_pins) {
                if (controller_config.valve_pins.length !== controller_config.pump_pins.length) {
                    throw new ApiError(400, 'Controller config valve_pins and pump_pins length must match');
                }
                if (controller_config.valve_pins.length > max_zones || controller_config.pump_pins.length > max_zones) {
                    throw new ApiError(400, 'Controller config valve_pins and pump_pins length exceed max zones');
                }
            } else if (max_zones && !controller_config) {
                const garden = await db.gardens.getById({ id: gardenID });
                if (garden.controller_config && garden.controller_config.valve_pins && garden.controller_config.pump_pins) {
                    if (garden.controller_config.valve_pins.length > max_zones || garden.controller_config.pump_pins.length > max_zones) {
                        throw new ApiError(400, 'Existing controller config valve_pins and pump_pins length exceed new max zones');
                    }
                }
            } else if (!max_zones && controller_config) {
                const garden = await db.gardens.getById({ id: gardenID });
                if (garden) {
                    if (controller_config.valve_pins.length !== controller_config.pump_pins.length) {
                        throw new ApiError(400, 'Controller config valve_pins and pump_pins length must match');
                    }
                    if (controller_config.valve_pins.length > garden.max_zones || controller_config.pump_pins.length > garden.max_zones) {
                        throw new ApiError(400, 'Controller config valve_pins and pump_pins length exceed max zones');
                    }
                }
            }

            const updatedGarden = await db.gardens.updateById({ id: gardenID, data: updates, notification: true });
            if (!updatedGarden) {
                throw new ApiError(404, 'Garden not found');
            }

            if (controller_config) {
                try {
                    await mqttService.sendUpdateAction(updatedGarden, controller_config);
                } catch (mqttError) {
                    console.error('MQTT error sending initial config:', mqttError);
                }
            }

            if (light_schedule) {
                if (light_schedule) {
                    await cronScheduler.scheduleLightActions(updatedGarden);
                } else {
                    // If LightSchedule is set to null, remove the scheduled Jobs
                    cronScheduler.removeLightJobsByGardenId(updatedGarden._id.toString());
                }
            }

            // Get plant and zone counts
            const [plantsCount, zonesCount, health
                , nextOnTime, nextOffTime
            ] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                ),
                gardenService.getGardenHealth(updatedGarden),
                cronScheduler.getNextLightTime(updatedGarden, 'ON'),
                cronScheduler.getNextLightTime(updatedGarden, 'OFF')
            ]);

            // Format response
            const formattedGarden = formatGardenResponse(updatedGarden, req);
            formattedGarden.health = health;
            if (nextOnTime && nextOffTime) {
                if (nextOnTime < nextOffTime) {
                    formattedGarden.next_light_action = {
                        action: 'ON',
                        time: nextOnTime
                    };
                } else {
                    formattedGarden.next_light_action = {
                        action: 'OFF',
                        time: nextOffTime
                    };
                }
            } else if (nextOnTime) {
                formattedGarden.next_light_action = {
                    action: 'ON',
                    time: nextOnTime
                };
            } else if (nextOffTime) {
                formattedGarden.next_light_action = {
                    action: 'OFF',
                    time: nextOffTime
                };
            }
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            return res.json(new ApiSuccess(200, 'Garden updated successfully', formattedGarden));
        } catch (error) {
            next(error);
        }
    },

    endDateGarden: async (req, res, next) => {
        try {
            const { gardenID } = req.params;

            // End-date the garden (soft delete)
            const endDatedGarden = await db.gardens.deleteById(gardenID);
            if (!endDatedGarden) {
                throw new ApiError(404, 'Garden not found');
            }

            const cronScheduler = require('../services/cronScheduler');
            cronScheduler.removeLightJobsByGardenId(endDatedGarden._id.toString());

            // Stop all watering in garden, turn off lights, pumps, etc.
            await mqttService.sendStopAllAction(endDatedGarden, true);
            await mqttService.sendLightAction(endDatedGarden, 'OFF');
            // Reset device

            return res.json(new ApiSuccess(200, 'Garden end-dated successfully', gardenID));

        } catch (error) {
            next(error);
        }
    },

    gardenAction: async (req, res, next) => {
        try {
            const { gardenID } = req.params;
            const { light, stop, update } = req.body;

            // Verify garden exists
            const garden = await db.gardens.getById({ id: gardenID });
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            await gardenService.executeGardenAction(garden, { light, stop, update });

            return res.json(new ApiSuccess(200, 'Garden action executed successfully'));
        } catch (error) {
            next(error);
        }
    },

    // Light Schedule Management
    scheduleLightActions: async (req, res, next) => {
        try {
            const { gardenID } = req.params;

            // Verify garden exists and has light_schedule
            const garden = await db.gardens.getById({ id: gardenID });
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            if (!garden.light_schedule || !garden.light_schedule.duration_ms || !garden.light_schedule.start_time) {
                throw new ApiError(400, 'Garden does not have a valid light schedule to schedule');
            }

            await cronScheduler.scheduleLightActions(garden);

            return res.json(new ApiSuccess(200, 'Light schedule scheduled successfully', {
                garden_id: gardenID,
                next_light_on: cronScheduler.getNextLightTime(garden, 'ON'),
                next_light_off: cronScheduler.getNextLightTime(garden, 'OFF')
            }));
        } catch (error) {
            next(error);
        }
    },

    resetLightSchedule: async (req, res, next) => {
        try {
            const { gardenID } = req.params;

            // Verify garden exists
            const garden = await db.gardens.getById({ id: gardenID });
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            await cronScheduler.resetLightSchedule(garden);

            return res.json(new ApiSuccess(200, 'Light schedule reset successfully', {
                garden_id: gardenID,
                next_light_on: cronScheduler.getNextLightTime(garden, 'ON'),
                next_light_off: cronScheduler.getNextLightTime(garden, 'OFF')
            }));
        } catch (error) {
            next(error);
        }
    },
};

module.exports = GardensController;