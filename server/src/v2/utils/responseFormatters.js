const { generateXid } = require('../utils/helpers');

// Helper functions to format responses according to OpenAPI spec

/**
 * Format a Garden document for GardenResponse
 */
function formatGardenResponse(garden, req) {
    const baseUrl = `${req.protocol}://${req.get('Host')}`;

    return {
        id: garden.id,
        name: garden.name,
        topic_prefix: garden.topic_prefix,
        max_zones: garden.max_zones,
        light_schedule: garden.light_schedule || {},
        created_at: garden.created_at,
        end_date: garden.end_date,
        next_light_action: garden.next_light_action || {},
        health: garden.health || {
            status: 'N/A',
            details: 'No recent health data from garden controller',
            last_contact: null
        },
        temperature_humidity_data: garden.temperature_humidity_data || {
            temperature_celsius: null,
            humidity_percentage: null
        },
        num_plants: 0, // Will be populated by controller
        num_zones: 0,  // Will be populated by controller
        plants: {
            rel: 'collection',
            href: `/gardens/${garden.id}/plants`
        },
        zones: {
            rel: 'collection',
            href: `/gardens/${garden.id}/zones`
        },
        links: [
            { rel: 'self', href: `/gardens/${garden.id}` },
            { rel: 'health', href: `/gardens/${garden.id}/health` },
            { rel: 'plants', href: `/gardens/${garden.id}/plants` },
            { rel: 'zones', href: `/gardens/${garden.id}/zones` },
            { rel: 'action', href: `/gardens/${garden.id}/action` }
        ]
    };
}

/**
 * Format a Plant document for PlantResponse
 */
function formatPlantResponse(plant, req) {
    return {
        id: plant.id,
        name: plant.name,
        zone_id: plant.zone_id,
        details: plant.details || {},
        created_at: plant.created_at,
        end_date: plant.end_date,
        next_water_time: null, // Will be calculated by controller
        links: [
            { rel: 'self', href: `/gardens/${plant.garden_id}/plants/${plant.id}` },
            { rel: 'garden', href: `/gardens/${plant.garden_id}` },
            { rel: 'zone', href: `/gardens/${plant.garden_id}/zones/${plant.zone_id}` }
        ]
    };
}

/**
 * Format a Zone document for ZoneResponse
 */
function formatZoneResponse(zone, req, includeWeatherData = true) {
    const response = {
        id: zone.id,
        name: zone.name,
        details: zone.details || {},
        position: zone.position,
        skip_count: zone.skip_count || 0,
        water_schedule_ids: zone.water_schedule_ids || [],
        created_at: zone.created_at,
        end_date: zone.end_date,
        next_water: {
            time: null, // Will be calculated by controller
            duration: null,
            water_schedule_id: null,
            message: 'No scheduled watering'
        },
        links: [
            { rel: 'self', href: `/gardens/${zone.garden_id}/zones/${zone.id}` },
            { rel: 'garden', href: `/gardens/${zone.garden_id}` },
            { rel: 'action', href: `/gardens/${zone.garden_id}/zones/${zone.id}/action` },
            { rel: 'history', href: `/gardens/${zone.garden_id}/zones/${zone.id}/history` }
        ]
    };

    // Add weather data if requested
    if (includeWeatherData) {
        response.weather_data = {
            rain: {
                mm: 0,
                scale_factor: 1.0
            },
            average_temperature: {
                celsius: 20,
                scale_factor: 1.0
            }
        };
    }

    return response;
}

/**
 * Format a WaterSchedule document for WaterScheduleResponse
 */
function formatWaterScheduleResponse(waterSchedule, req, includeWeatherData = true) {
    const response = {
        id: waterSchedule.id,
        name: waterSchedule.name,
        description: waterSchedule.description,
        duration: waterSchedule.duration,
        interval: waterSchedule.interval,
        start_time: waterSchedule.start_time,
        weather_control: waterSchedule.weather_control || {},
        end_date: waterSchedule.end_date,
        next_water: {
            time: null, // Will be calculated by controller
            duration: waterSchedule.duration,
            water_schedule_id: waterSchedule.id,
            message: 'Next scheduled watering'
        },
        links: [
            { rel: 'self', href: `/water_schedules/${waterSchedule.id}` }
        ]
    };

    // Add weather data if requested
    if (includeWeatherData) {
        response.weather_data = {
            rain: {
                mm: 0,
                scale_factor: 1.0
            },
            average_temperature: {
                celsius: 20,
                scale_factor: 1.0
            }
        };
    }

    return response;
}

/**
 * Format WaterHistory documents for WaterHistoryResponse
 */
function formatWaterHistoryResponse(historyItems, totalCount) {
    // Calculate aggregate data
    const durations = historyItems.map(item => parseDurationToSeconds(item.duration));
    const totalSeconds = durations.reduce((sum, duration) => sum + duration, 0);
    const averageSeconds = durations.length > 0 ? totalSeconds / durations.length : 0;

    return {
        history: historyItems.map(item => ({
            duration: item.duration,
            record_time: item.record_time
        })),
        count: totalCount || historyItems.length,
        average: formatDuration(averageSeconds),
        total: formatDuration(totalSeconds)
    };
}

/**
 * Helper function to parse duration string to seconds
 */
function parseDurationToSeconds(durationStr) {
    if (!durationStr) return 0;

    const match = durationStr.match(/^(\d+)(ms|s|m|h)$/);
    if (!match) return 0;

    const value = parseInt(match[1]);
    const unit = match[2];

    switch (unit) {
        case 'ms': return value / 1000;
        case 's': return value;
        case 'm': return value * 60;
        case 'h': return value * 3600;
        default: return 0;
    }
}

/**
 * Helper function to format seconds as duration string
 */
function formatDuration(seconds) {
    if (seconds < 1) return `${Math.round(seconds * 1000)}ms`;
    if (seconds < 60) return `${Math.round(seconds)}s`;
    if (seconds < 3600) return `${Math.round(seconds / 60)}m`;
    return `${Math.round(seconds / 3600)}h`;
}

/**
 * Validation helpers for OpenAPI types
 */
const validators = {
    xid: (value) => /^[0-9a-v]{20}$/.test(value),

    duration: (value) => /^\d+(ms|s|m|h)$/.test(value),

    timeWithTimezone: (value) => /^\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/.test(value),

    topicPrefix: (value) => !/[\s$#*>+/]/.test(value)
};

/**
 * Generate mock weather data for testing
 */
function getMockWeatherData() {
    return {
        rain: {
            mm: Math.random() * 10,
            scale_factor: 0.8 + Math.random() * 0.4
        },
        average_temperature: {
            celsius: 18 + Math.random() * 15,
            scale_factor: 0.9 + Math.random() * 0.2
        }
    };
}

/**
 * Calculate next water time based on schedule
 */
function calculateNextWaterTime(waterSchedule) {
    if (!waterSchedule || !waterSchedule.start_time || !waterSchedule.interval) {
        return null;
    }

    // Simple implementation - in real app would parse start_time and interval properly
    const now = new Date();
    const nextWater = new Date(now.getTime() + 24 * 60 * 60 * 1000); // Next day

    return nextWater;
}

module.exports = {
    formatGardenResponse,
    formatPlantResponse,
    formatZoneResponse,
    formatWaterScheduleResponse,
    formatWaterHistoryResponse,
    validators,
    getMockWeatherData,
    calculateNextWaterTime,
    parseDurationToSeconds,
    formatDuration
};