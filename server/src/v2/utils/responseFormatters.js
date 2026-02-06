const { millisToDuration, durationToSeconds } = require("./helpers");

/**
 * Format a Garden document for GardenResponse
 */
function formatGardenResponse(garden, req) {
    // const baseUrl = `${req.protocol}://${req.get('Host')}`;

    return {
        id: garden.id,
        name: garden.name,
        topic_prefix: garden.topic_prefix,
        max_zones: garden.max_zones,
        light_schedule: garden.light_schedule,
        created_at: garden.created_at,
        end_date: garden.end_date,
        controller_config: garden.controller_config,
        notification_client: garden.notification_client_id ? {
            id: garden.notification_client_id._id,
            name: garden.notification_client_id.name,
            type: garden.notification_client_id.type
        } : null,
        notification_settings: garden.notification_settings,
        next_light_action: garden.next_light_action,
        health: null,
        temperature_humidity_data: null,
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
 * Format WaterHistory documents for WaterHistoryResponse
 */
function formatWaterHistoryResponse(historyItems, totalCount) {
    // Calculate aggregate data
    const durations = historyItems.map(item => durationToSeconds(item.duration));
    const totalSeconds = durations.reduce((sum, duration) => sum + duration, 0);
    const averageSeconds = durations.length > 0 ? totalSeconds / durations.length : 0;

    return {
        history: historyItems.map(item => ({
            duration: item.duration,
            record_time: item.record_time
        })),
        count: totalCount || historyItems.length,
        average: millisToDuration(averageSeconds),
        total: millisToDuration(totalSeconds)
    };
}

module.exports = {
    formatGardenResponse,
    formatWaterHistoryResponse,
};