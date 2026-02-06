const db = require('../models/database');
const { millisToRelativeTime } = require('../utils/helpers');
const gardenService = require('./gardenService');

const downTimers = new Map();

class NotificationService {

    async handleHealthMessage(garden, message) {
        const downtime = garden.notification_settings.downtime_ms;
        if (!downtime || downtime <= 0) {
            return;
        }

        let timer = downTimers.get(garden.topic_prefix);
        const title = `${garden.name} is down`;
        const msg = `Garden has been down for > ${millisToRelativeTime(downtime)} ago`;
        if (!timer) {
            timer = setTimeout(async () => {
                await this.sendNotificationForGarden(garden, title, msg);
            }, downtime);
            downTimers.set(garden.topic_prefix, timer);
            console.log("Created new timer");
        } else {
            clearTimeout(timer);
            timer = setTimeout(async () => {
                await this.sendNotificationForGarden(garden, title, msg);
            }, downtime);
            downTimers.set(garden.topic_prefix, timer);
            console.log("Reset timer");
        }
    }

    async handleGardenStartupMessage(garden, msg) {
        await this.sendGardenStartupNotification(garden, msg);
    }

    async sendLightActionNotification(garden, state) {
        if (!garden.notification_client_id) {
            return;
        }
        if (!garden.notification_settings || !garden.notification_settings.light_schedule) {
            console.log("Garden does not have light_schedule notification enabled");
            return;
        }
        const title = `${garden.name}: Light ${state}`;
        await this.sendNotification(garden.notification_client_id, title, "Successfully executed LightAction");
    }

    async sendDownNotification(garden, clientID, actionName) {
        const health = await gardenService.getGardenHealth(garden);
        if (health.status !== 'UP') {
            const title = `${garden.name}: ${health.status}`;
            let msg = `Attempting to execute ${actionName} Action`;
            if (health.last_contact) {
                msg += `, but last contact was ${new Date(health.last_contact).toISOString()}.`;
            }
            msg += `\nDetails: ${health.details}`;
            await this.sendNotification(
                clientID,
                title,
                msg
            );
        }
    }

    async sendNotification(clientID, title, msg) {
        const notificationClient = await db.notificationClients.getById(clientID);
        if (!notificationClient) {
            console.error(`Error getting notification client with ID: ${clientID}`);
            return;
        }
        await notificationClient.sendMessage(title, msg);
    }

    async sendNotificationForGarden(garden, title, message) {
        if (!garden.notification_client_id) {
            throw new Error("Garden does not have notification client");
        }
        const notificationClient = await db.notificationClients.getById(garden.notification_client_id);
        if (!notificationClient) {
            throw new Error("Error getting notification client");
        }
        await notificationClient.sendMessage(title, message);
    }

    async sendGardenStartupNotification(garden, msg) {
        if (!garden.notification_settings || !garden.notification_settings.controller_startup) {
            console.log("Garden does not have controller_startup notification enabled", garden.id);
            return;
        }

        const title = `${garden.name} connected`;
        const msgContent = msg.replace(/^logs message="/, '').replace(/"$/, '');
        await this.sendNotificationForGarden(garden, title, msgContent || msg);
    }

    async handleWaterMessage(garden, waterMessage) {
        console.log("Parsed water message:", waterMessage);

        if (!garden.notification_client_id) {
            console.log("Garden does not have notification client", garden.id);
            return;
        }

        if (waterMessage.start) {
            if (!garden.notification_settings.watering_started) {
                console.log("Skipping start message since notification is not enabled for the start");
                return;
            }
            const title = `${garden.name} started watering`;
            const msg = `Garden: ${garden.name}`;
            await this.sendNotification(garden.notification_client_id, title, msg);
        } else {
            if (!garden.notification_settings.watering_completed) {
                console.log("Skipping completed message since notification is not enabled for the completed");
                return;
            }
            const title = `${garden.name} finished watering`;
            const durMs = waterMessage.duration || 0;
            const durStr = millisToRelativeTime(durMs);
            const msg = `Watered for ${durStr}\nGarden: ${garden.name}`;
            await this.sendNotification(garden.notification_client_id, title, msg);
        }
    }
}

module.exports = new NotificationService();