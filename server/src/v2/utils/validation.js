const Joi = require('joi');
const config = require('../config/app.config');
const { millisToDuration } = require('./helpers');
// MongoDB ObjectId pattern (24 hex characters)
const xidPattern = /^[0-9a-v]{24}$/;

// Time validation pattern (HH:MM:SS)
const timePattern = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]?$/;

const topicPrefixPattern = /^[^#$+>*]+$/; // No spaces or MQTT wildcards

const validMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const durationValidator = Joi.number().integer().min(0).required().messages({
    'number.base': 'Duration must be a non-negative integer representing milliseconds',
});
const waterDurValidator = Joi.number().integer().min(config.minWaterDuration).max(config.maxWaterDuration).messages({
    'number.min': `Duration must be at least ${millisToDuration(config.minWaterDuration)}`,
    'number.max': `Duration must not exceed ${millisToDuration(config.maxWaterDuration)}`,
    'number.base': 'Duration must be between 1 minute and 1 day in milliseconds',
});
const lightDurValidator = Joi.number().integer().messages({
    'number.min': `Duration must be at least ${millisToDuration(config.minLightDuration)}`,
    'number.max': `Duration must not exceed ${millisToDuration(config.maxLightDuration)}`,
    'number.base': 'Duration must be between 1 minute and 24 hours in milliseconds',
});

const startTimeValidator = Joi.string().pattern(timePattern).messages({
    'string.pattern.base': 'Time must be in HH:MM:SS format'
});
const durationPattern = /^(\d+(\.\d+)?)(ns|μs|ms|s|m|h)$/;
// const lightDurationPattern = /^(\d+h)?(\d+m)?(\d+s)?$/;

// Base schemas
const schemas = {
    gardenAction: Joi.object({
        light: Joi.object({
            state: Joi.string().valid('ON', 'OFF', '').optional(),
            for_duration_ms: Joi.number().integer().min(0).optional().messages({
                'number.base': 'for_duration_ms must be a non-negative integer representing milliseconds'
            })
        }).optional(),
        stop: Joi.object({
            all: Joi.boolean().optional()
        }).optional(),
        update: Joi.object({
            config: Joi.boolean().required(),
            controller_config: Joi.object({
                max_zones: Joi.number().integer().min(1).required(),
                valve_pins: Joi.array().items(Joi.number().integer().min(0).required()).required().when('max_zones', {
                    is: Joi.number().integer().min(1),
                    then: Joi.array().min(Joi.ref('max_zones')).max(Joi.ref('max_zones')).messages({
                        'array.min': 'valve_pins must have at least as many pins as max_zones',
                        'array.max': 'valve_pins cannot have more pins than max_zones'
                    }),
                    otherwise: Joi.forbidden()
                }),
                pump_pins: Joi.array().items(Joi.number().integer().min(0).required()).required().when('max_zones', {
                    is: Joi.number().integer().min(1),
                    then: Joi.array().min(Joi.ref('max_zones')).max(Joi.ref('max_zones')).messages({
                        'array.min': 'pump_pins must have at least as many pins as max_zones',
                        'array.max': 'pump_pins cannot have more pins than max_zones'
                    }),
                    otherwise: Joi.forbidden()
                }),
                light_pin: Joi.number().integer().min(0).optional(),
                temp_humidity_pin: Joi.number().integer().min(0).optional(),
                temp_hum_interval_ms: Joi.number().integer().min(0).optional()
            }).required()
        }).optional()
    }).or('light', 'stop', 'update').messages({
        'object.missing': 'Either light, stop or update action must be provided'
    }),

    zoneAction: Joi.object({
        water: Joi.object({
            duration_ms: durationValidator.required()
        }).optional()
    }).required(),

    // Request Body Schemas
    // Garden requests
    createGardenRequest: Joi.object({
        name: Joi.string().min(1).max(255).required().messages({
            'string.min': 'Garden name must be at least 1 character',
            'string.max': 'Garden name must not exceed 255 characters',
            'any.required': 'Garden name is required'
        }),
        // description: Joi.string().min(1).max(1000).optional().messages({
        //     'string.min': 'Description must be at least 1 character',
        //     'string.max': 'Description must not exceed 1000 characters'
        // }),
        topic_prefix: Joi.string().pattern(topicPrefixPattern).required().messages({
            'string.pattern.base': 'Topic prefix must not contain spaces or MQTT wildcards (#, +, >, *)',
            'any.required': 'Topic prefix is required'
        }),
        max_zones: Joi.number().integer().min(1).required(),
        light_schedule: Joi.object({
            duration_ms: lightDurValidator.required(),
            start_time: startTimeValidator.required(),
            // adhoc_on_time: Joi.string().isoDate().optional(),
        }).optional(),
        controller_config: Joi.object({
            valve_pins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            pump_pins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            light_pin: Joi.number().integer().min(0).optional(),
            temp_humidity_pin: Joi.number().integer().min(0).optional(),
            temp_hum_interval_ms: Joi.number().integer().min(0).optional().default(5000)
        }).optional()
    }),

    updateGardenRequest: Joi.object({
        name: Joi.string().min(1).max(255).optional().messages({
            'string.min': 'Garden name must be at least 1 character',
            'string.max': 'Garden name must not exceed 255 characters',
        }),
        // description: Joi.string().min(1).max(1000).optional().messages({
        //     'string.min': 'Description must be at least 1 character',
        //     'string.max': 'Description must not exceed 1000 characters'
        // }),
        topic_prefix: Joi.string().pattern(topicPrefixPattern).optional().messages({
            'string.pattern.base': 'Topic prefix must not contain spaces or MQTT wildcards (#, +, >, *)',
        }),
        max_zones: Joi.number().integer().min(1).optional(),
        light_schedule: Joi.object({
            duration_ms: durationValidator.optional(),
            start_time: startTimeValidator.optional(),
            adhoc_on_time: Joi.string().isoDate().optional(),
        }).optional().allow(null),
        // temperature_humidity_sensor: Joi.boolean().optional(),
        controller_config: Joi.object({
            valve_pins: Joi.array().items(Joi.number().integer().min(0).required()).optional(),
            pump_pins: Joi.array().items(Joi.number().integer().min(0).required()).optional(),
            light_pin: Joi.number().integer().min(0).optional(),
            temp_humidity_pin: Joi.number().integer().min(0).optional(),
            temp_hum_interval_ms: Joi.number().integer().min(0).optional().default(5000)
        }).optional().allow(null)
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Plant requests
    createPlantRequest: Joi.object({
        name: Joi.string().min(1).required().messages({
            'string.min': 'Plant name must be at least 1 character',
            'any.required': 'Plant name is required'
        }),
        zone_id: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'Zone ID must be a 24 character XID format',
            'any.required': 'Zone ID is required'
        }),
        details: Joi.object({
            description: Joi.string().optional(),
            notes: Joi.string().optional(),
            time_to_harvest: Joi.string().optional(),
            count: Joi.number().integer().min(0).optional()
        }).optional()
    }),

    updatePlantRequest: Joi.object({
        name: Joi.string().min(1).optional().messages({
            'string.min': 'Plant name must be at least 1 character'
        }),
        zone_id: Joi.string().pattern(xidPattern).optional().messages({
            'string.pattern.base': 'Zone ID must be a 24 character XID format'
        }),
        details: Joi.object({
            description: Joi.string().optional(),
            notes: Joi.string().optional(),
            time_to_harvest: Joi.string().optional(),
            count: Joi.number().integer().min(0).optional()
        }).optional().allow(null),
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Zone requests
    createZoneRequest: Joi.object({
        name: Joi.string().min(1).required().messages({
            'string.min': 'Zone name must be at least 1 character',
            'any.required': 'Zone name is required'
        }),
        details: Joi.object({
            description: Joi.string().required(),
            notes: Joi.string().optional()
        }).optional(),
        position: Joi.number().integer().min(0).required().messages({
            'number.min': 'Position must be 0 or greater',
            'any.required': 'Position is required'
        }),
        skip_count: Joi.number().integer().min(0).optional(),
        water_schedule_ids: Joi.array().items(
            Joi.string().pattern(xidPattern).messages({
                'string.pattern.base': 'Water Schedule ID must be a 24 character XID format'
            })
        ).optional()
    }),

    updateZoneRequest: Joi.object({
        name: Joi.string().min(1).optional().messages({
            'string.min': 'Zone name must be at least 1 character'
        }),
        details: Joi.object({
            description: Joi.string().optional(),
            notes: Joi.string().optional()
        }).optional().allow(null),
        position: Joi.number().integer().min(0).optional().messages({
            'number.min': 'Position must be 0 or greater'
        }),
        skip_count: Joi.number().integer().min(0).optional(),
        water_schedule_ids: Joi.array().items(
            Joi.string().pattern(xidPattern).messages({
                'string.pattern.base': 'Water Schedule ID must be a 24 character XID format'
            })
        ).optional().allow(null),
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Water Schedule requests
    createWaterScheduleRequest: Joi.object({
        duration_ms: waterDurValidator.required(),
        interval: Joi.number().min(1).required().messages({
            'number.base': 'Interval must be a positive number (e.g., 1, 2, ...) representing days between watering'
        }),
        start_time: startTimeValidator.required(),
        weather_control: Joi.object({
            rain_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().min(0).required(),
                client_id: Joi.string().pattern(xidPattern).required()
            }).optional(),
            temperature_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().min(0).required(),
                client_id: Joi.string().pattern(xidPattern).required()
            }).optional()
        }).optional(),
        active_period: Joi.object({
            start_month: Joi.string().valid(...validMonths).required(),
            end_month: Joi.string().valid(...validMonths).required()
        }).optional(),
        name: Joi.string().required(),
        description: Joi.string().optional()
    }),

    updateWaterScheduleRequest: Joi.object({
        duration_ms: waterDurValidator.optional(),
        interval: Joi.number().min(1).optional().messages({
            'number.base': 'Interval must be a positive number (e.g., 1, 2, ...) representing days between watering'
        }),
        start_time: startTimeValidator.optional(),
        weather_control: Joi.object({
            rain_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().min(0).required(),
                client_id: Joi.string().pattern(xidPattern).required()
            }).optional().allow(null),
            temperature_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().min(0).required(),
                client_id: Joi.string().pattern(xidPattern).required()
            }).optional().allow(null)
        }).optional().allow(null),
        active_period: Joi.object({
            start_month: Joi.string().valid(...validMonths).required(),
            end_month: Joi.string().valid(...validMonths).required()
        }).optional().allow(null),
        name: Joi.string().optional(),
        description: Joi.string().optional()
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Weather Client Config requests
    createWeatherClientRequest: Joi.object({
        type: Joi.string().valid('netatmo', 'fake').required(),
        name: Joi.string().min(1).required(),
        options: Joi.when('type', {
            switch: [
                {
                    is: 'fake',
                    then: Joi.object({
                        rain_mm: Joi.number().min(0).required().messages({
                            'any.required': 'rain_mm is required for fake weather client'
                        }),
                        rain_interval_ms: durationValidator.required(),
                        avg_high_temperature: Joi.number().required().messages({
                            'any.required': 'avg_high_temperature is required for fake weather client'
                        }),
                        error: Joi.string().optional().allow('')
                    }).required()
                },
                {
                    is: 'netatmo',
                    then: Joi.object({
                        station_id: Joi.string().optional(),
                        station_name: Joi.string().optional(),
                        rain_module_id: Joi.string().optional(),
                        rain_module_type: Joi.string().optional(),
                        outdoor_module_id: Joi.string().optional(),
                        outdoor_module_type: Joi.string().optional(),
                        authentication: Joi.object({
                            // access_token: Joi.string().optional(),
                            refresh_token: Joi.string().required(),
                            // expiration_date: Joi.string().isoDate().optional()
                        }).required(),
                        client_id: Joi.string().required(),
                        client_secret: Joi.string().required()
                    }).or('station_id', 'station_name')
                        .or('rain_module_id', 'rain_module_type')
                        .or('outdoor_module_id', 'outdoor_module_type')
                        .messages({
                            'object.missing': 'Missing required fields: Either (station_id or station_name) AND (rain_module_id or rain_module_type) AND (outdoor_module_id or outdoor_module_type) must be provided'
                        }).required()
                }
            ]
        }).required()
    }),

    updateWeatherClientRequest: Joi.object({
        type: Joi.string().valid('netatmo', 'fake').required(),
        name: Joi.string().min(1).optional(),
        options: Joi.when('type', {
            switch: [
                {
                    is: 'fake',
                    then: Joi.object({
                        rain_mm: Joi.number().min(0).optional(),
                        rain_interval_ms: durationValidator.optional(),
                        avg_high_temperature: Joi.number().optional(),
                        error: Joi.string().optional().allow('')
                    }).min(1).messages({
                        'object.min': 'At least one field must be provided for fake weather client options update'
                    })
                },
                {
                    is: 'netatmo',
                    then: Joi.object({
                        station_id: Joi.string().optional(),
                        station_name: Joi.string().optional(),
                        rain_module_id: Joi.string().optional(),
                        rain_module_type: Joi.string().optional(),
                        outdoor_module_id: Joi.string().optional(),
                        outdoor_module_type: Joi.string().optional(),
                        authentication: Joi.object({
                            // access_token: Joi.string().optional(),
                            refresh_token: Joi.string().optional(),
                            // expiration_date: Joi.string().isoDate().optional()
                        }).optional(),
                        client_id: Joi.string().optional(),
                        client_secret: Joi.string().optional()
                    }).min(1).messages({
                        'object.min': 'At least one field must be provided for netatmo weather client options update'
                    })
                }
            ],
            otherwise: Joi.object().optional()
        }).optional()
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    createWaterRoutineRequest: Joi.object({
        name: Joi.string().min(1).required().messages({
            'string.min': 'Water routine name must be at least 1 character',
            'any.required': 'Water routine name is required'
        }),
        steps: Joi.array().items(
            Joi.object({
                zone_id: Joi.string().pattern(xidPattern).required().messages({
                    'string.pattern.base': 'Zone ID must be a 24 character XID format',
                    'any.required': 'Zone ID is required'
                }),
                duration_ms: waterDurValidator.required()
            })
        ).min(1).required().messages({
            'array.min': 'At least one step is required in the water routine',
            'any.required': 'Steps are required'
        })
    }),

    updateWaterRoutineRequest: Joi.object({
        name: Joi.string().min(1).optional().messages({
            'string.min': 'Water routine name must be at least 1 character'
        }),
        steps: Joi.array().items(
            Joi.object({
                zone_id: Joi.string().pattern(xidPattern).required().messages({
                    'string.pattern.base': 'Zone ID must be a 24 character XID format',
                }),
                duration_ms: waterDurValidator.optional()
            })
        ).min(1).messages({
            'array.min': 'At least one step is required in the water routine'
        })
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Query parameter schemas
    queryParams: {
        endDated: Joi.boolean().optional(),
        excludeWeatherData: Joi.boolean().optional(),
        range: Joi.string().pattern(durationPattern).default('72h').messages({
            'string.pattern.base': 'Range must be in valid duration format (e.g., "72h", "30m")'
        }),
        limit: Joi.number().integer().min(0).optional().default(0)
    },

    // Path parameter schemas
    pathParams: {
        // MongoDB ObjectId pattern (24 hex characters)
        id: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'ID must be a 24 character XID format'
        }),
    }
};

// Combined validation for endpoints that need multiple validations
const validateEndpoint = (bodySchema, paramsSchema, querySchema) => {
    const middlewares = [];

    if (bodySchema) middlewares.push(validateBody(bodySchema));
    if (paramsSchema) middlewares.push(validateParams(paramsSchema));
    if (querySchema) middlewares.push(validateQuery(querySchema));

    return middlewares;
};

module.exports = {
    xidPattern,
    durationPattern,
    timePattern,
    topicPrefixPattern,
    schemas,
    validateEndpoint,
};