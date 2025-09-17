const { config } = require('dotenv');
const Joi = require('joi');

// MongoDB ObjectId pattern (24 hex characters)
const xidPattern = /^[0-9a-v]{24}$/;

// Duration validation pattern (supports formats like "72h", "30m", "15s", "15000ms")
const durationPattern = /^(\d+(\.\d+)?)(ns|μs|ms|s|m|h)$/;

// Time validation pattern (HH:MM:SS with optional timezone offset)
const timePattern = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\+|-[0-1][0-9]:[0-5][0-9])?$/;

const topicPrefixPattern = /^[^#$+>*]+$/; // No spaces or MQTT wildcards

// Base schemas
const schemas = {
    // Basic types
    xid: Joi.string().pattern(xidPattern).required().messages({
        'string.pattern.base': 'ID must be a 24 character XID format'
    }),

    optionalXid: Joi.string().pattern(xidPattern).optional().messages({
        'string.pattern.base': 'ID must be a 24 character XID format'
    }),

    duration: Joi.string().pattern(durationPattern).required().messages({
        'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
    }),

    time: Joi.string().pattern(timePattern).required().messages({
        'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
    }),

    // Light state enum
    lightState: Joi.string().valid('ON', 'OFF', '').optional(),

    // Scale Control schema
    scaleControl: Joi.object({
        baseline_value: Joi.number().required(),
        factor: Joi.number().min(0).max(1).required(),
        range: Joi.number().required()
    }).optional(),

    // Weather Control schema
    weatherControl: Joi.object({
        rain_control: Joi.object({
            baseline_value: Joi.number().required(),
            factor: Joi.number().min(0).max(1).required(),
            range: Joi.number().required()
        }).optional(),
        temperature_control: Joi.object({
            baseline_value: Joi.number().required(),
            factor: Joi.number().min(0).max(1).required(),
            range: Joi.number().required()
        }).optional()
    }).optional(),

    // Garden Actions
    lightAction: Joi.object({
        state: Joi.string().valid('ON', 'OFF', '').optional(),
        for_duration: Joi.string().pattern(durationPattern).when('state', {
            is: 'OFF',
            then: Joi.optional(),
            otherwise: Joi.forbidden().messages({
                'any.unknown': 'for_duration can only be used with state=OFF'
            })
        }).messages({
            'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
        })
    }).optional(),

    stopAction: Joi.object({
        all: Joi.boolean().optional()
    }).optional(),

    gardenAction: Joi.object({
        light: Joi.object({
            state: Joi.string().valid('ON', 'OFF', '').optional(),
            // for_duration: Joi.string().pattern(durationPattern).when('state', {
            //     is: 'OFF',
            //     then: Joi.optional(),
            //     otherwise: Joi.forbidden().messages({
            //         'any.unknown': 'for_duration can only be used with state=OFF'
            //     })
            // }).messages({
            //     'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
            // })
        }).optional(),
        stop: Joi.object({
            all: Joi.boolean().optional()
        }).optional(),
        update: Joi.object({
            config: Joi.boolean().required(),
            controller_config: Joi.object({
                max_zones: Joi.number().integer().min(1).required(),
                valvePins: Joi.array().items(Joi.number().integer().min(0).required()).required().when('max_zones', {
                    is: Joi.number().integer().min(1),
                    then: Joi.array().min(Joi.ref('max_zones')).max(Joi.ref('max_zones')).messages({
                        'array.min': 'valvePins must have at least as many pins as max_zones',
                        'array.max': 'valvePins cannot have more pins than max_zones'
                    }),
                    otherwise: Joi.forbidden()
                }),
                pumpPins: Joi.array().items(Joi.number().integer().min(0).required()).required().when('max_zones', {
                    is: Joi.number().integer().min(1),
                    then: Joi.array().min(Joi.ref('max_zones')).max(Joi.ref('max_zones')).messages({
                        'array.min': 'pumpPins must have at least as many pins as max_zones',
                        'array.max': 'pumpPins cannot have more pins than max_zones'
                    }),
                    otherwise: Joi.forbidden()
                }),
                lightPin: Joi.number().integer().min(0).optional(),
                tempHumidityPin: Joi.number().integer().min(0).optional(),
                tempHumidityInterval: Joi.number().integer().min(0).optional()
            }).required()
        }).optional()
    }).or('light', 'stop', 'update').messages({
        'object.missing': 'Either light, stop or update action must be provided'
    }),

    // Zone Actions
    waterAction: Joi.object({
        duration: Joi.string().pattern(durationPattern).required().messages({
            'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
        })
    }).required(),

    zoneAction: Joi.object({
        water: Joi.object({
            duration: Joi.string().pattern(durationPattern).required().messages({
                'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
            })
        }).required()
    }).required(),

    // Plant Details
    plantDetails: Joi.object({
        description: Joi.string().optional(),
        notes: Joi.string().optional(),
        time_to_harvest: Joi.string().optional(),
        count: Joi.number().integer().min(0).optional()
    }).optional(),

    // Zone Details
    zoneDetails: Joi.object({
        description: Joi.string().optional(),
        notes: Joi.string().optional()
    }).optional(),

    // Light Schedule
    lightSchedule: Joi.object({
        duration: Joi.string().pattern(durationPattern).required().messages({
            'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
        }),
        start_time: Joi.string().pattern(timePattern).required().messages({
            'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
        }),
        adhoc_on_time: Joi.string().isoDate().optional(),
        temperature_humidity_sensor: Joi.boolean().optional()
    }).optional(),

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
            duration: Joi.string().pattern(durationPattern).required().messages({
                'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
            }),
            start_time: Joi.string().pattern(timePattern).required().messages({
                'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
            }),
            // adhoc_on_time: Joi.string().isoDate().optional(),
        }).optional(),
        // temperature_humidity_sensor: Joi.boolean().optional(),
        controller_config: Joi.object({
            valvePins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            pumpPins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            lightPin: Joi.number().integer().min(0).optional(),
            tempHumidityPin: Joi.number().integer().min(0).optional(),
            tempHumidityInterval: Joi.number().integer().min(0).optional()
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
            duration: Joi.string().pattern(durationPattern).required().messages({
                'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
            }),
            start_time: Joi.string().pattern(timePattern).required().messages({
                'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
            }),
            // adhoc_on_time: Joi.string().isoDate().optional(),
        }).optional(),
        // temperature_humidity_sensor: Joi.boolean().optional(),
        controller_config: Joi.object({
            valvePins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            pumpPins: Joi.array().items(Joi.number().integer().min(0).required()).required(),
            lightPin: Joi.number().integer().min(0).optional(),
            tempHumidityPin: Joi.number().integer().min(0).optional(),
            tempHumidityInterval: Joi.number().integer().min(0).optional()
        }).optional()
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
        }).optional(),
        created_at: Joi.string().isoDate().optional()
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
            description: Joi.string().optional(),
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
        }).optional(),
        position: Joi.number().integer().min(0).optional().messages({
            'number.min': 'Position must be 0 or greater'
        }),
        skip_count: Joi.number().integer().min(0).optional(),
        water_schedule_ids: Joi.array().items(
            Joi.string().pattern(xidPattern).messages({
                'string.pattern.base': 'Water Schedule ID must be a 24 character XID format'
            })
        ).optional(),
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update'
    }),

    // Water Schedule requests
    createWaterScheduleRequest: Joi.object({
        duration: Joi.string().pattern(durationPattern).required().messages({
            'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
        }),
        interval: Joi.string().pattern(durationPattern).required().messages({
            'string.pattern.base': 'Interval must be in valid format (e.g., "14h", "30m", "15s")'
        }),
        start_time: Joi.string().pattern(timePattern).required().messages({
            'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
        }),
        weather_control: Joi.object({
            rain_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().required()
            }).optional(),
            temperature_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().required()
            }).optional()
        }).optional(),
        name: Joi.string().optional(),
        description: Joi.string().optional()
    }),

    updateWaterScheduleRequest: Joi.object({
        duration: Joi.string().pattern(durationPattern).optional().messages({
            'string.pattern.base': 'Duration must be in valid format (e.g., "14h", "30m", "15s")'
        }),
        interval: Joi.string().pattern(durationPattern).optional().messages({
            'string.pattern.base': 'Interval must be in valid format (e.g., "14h", "30m", "15s")'
        }),
        start_time: Joi.string().pattern(timePattern).optional().messages({
            'string.pattern.base': 'Time must be in HH:MM:SS format with optional timezone offset'
        }),
        weather_control: Joi.object({
            rain_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().required()
            }).optional(),
            temperature_control: Joi.object({
                baseline_value: Joi.number().required(),
                factor: Joi.number().min(0).max(1).required(),
                range: Joi.number().required()
            }).optional()
        }).optional(),
        name: Joi.string().optional(),
        description: Joi.string().optional()
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
        gardenID: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'Garden ID must be a 24 character XID format'
        }),
        plantID: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'Plant ID must be a 24 character XID format'
        }),
        zoneID: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'Zone ID must be a 24 character XID format'
        }),
        waterScheduleID: Joi.string().pattern(xidPattern).required().messages({
            'string.pattern.base': 'Water Schedule ID must be a 24 character XID format'
        })
    }
};

// Validation middleware factory
const createValidationMiddleware = (schema, source = 'body') => {
    return (req, res, next) => {
        let dataToValidate;

        switch (source) {
            case 'body':
                dataToValidate = req.body;
                break;
            case 'params':
                dataToValidate = req.params;
                break;
            case 'query':
                dataToValidate = req.query;
                break;
            default:
                return res.status(500).json({ error: 'Invalid validation source' });
        }

        const { error, value } = schema.validate(dataToValidate, {
            abortEarly: false, // Return all errors, not just the first one
            stripUnknown: true, // Remove unknown fields
            convert: true // Convert strings to numbers/booleans when appropriate
        });

        if (error) {
            const errorMessage = error.details.map(detail => detail.message).join(', ');
            return res.status(400).json({
                error: 'Validation failed',
                message: errorMessage,
                details: error.details
            });
        }

        // Replace the original data with the validated/converted data
        switch (source) {
            case 'body':
                req.body = value;
                break;
            case 'params':
                req.params = value;
                break;
            case 'query':
                req.query = value;
                break;
        }

        next();
    };
};

// Convenience middleware creators
const validateBody = (schema) => createValidationMiddleware(schema, 'body');
const validateParams = (schema) => createValidationMiddleware(schema, 'params');
const validateQuery = (schema) => createValidationMiddleware(schema, 'query');

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
    validateBody,
    validateParams,
    validateQuery,
    validateEndpoint,
    createValidationMiddleware
};