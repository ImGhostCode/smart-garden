import PumpState from "../models/PumpState.js";
import { publish } from "./mqttClient.js";

const timers = new Map(); // nodeId -> timeoutId

export async function getPumpState(nodeId) {
    let doc = await PumpState.findOne({ node_id: nodeId });
    if (!doc) doc = await PumpState.create({ node_id: nodeId, state: "OFF", source: "manual" });
    return doc;
}

export function clearTimer(nodeId) {
    const t = timers.get(nodeId);
    if (t) {
        console.log(`[PumpStateService] Clear timer for node ${nodeId}`);
        clearTimeout(t);
        timers.delete(nodeId);
    }
}

export async function setPumpOnAuto({ app, pumpTopic, nodeId, durationSec }) {
    clearTimer(nodeId);
    const expiresAt = new Date(Date.now() + (durationSec || 20) * 1000);

    const doc = await PumpState.findOneAndUpdate(
        { node_id: nodeId },
        { state: "ON", source: "auto", expiresAt, updatedAt: new Date() },
        { upsert: true, new: true }
    );

    app.get("io")?.emit("pump_state", {
        node_id: nodeId, state: "ON", source: "auto", expiresAt
    });

    // auto OFF
    const tid = setTimeout(async () => {
        try {
            await setPumpOff({ app, pumpTopic, nodeId, source: "auto" });
        } catch (e) { }
    }, (durationSec || 20) * 1000);

    timers.set(nodeId, tid);
    return doc;
}

export async function setPumpOnManual({ app, pumpTopic, nodeId, lock = false, expireSec }) {
    clearTimer(nodeId);
    const expiresAt = expireSec ? new Date(Date.now() + expireSec * 1000) : undefined;

    const doc = await PumpState.findOneAndUpdate(
        { node_id: nodeId },
        { state: "ON", source: "manual", manualLock: !!lock, expiresAt, updatedAt: new Date() },
        { upsert: true, new: true }
    );

    app.get("io")?.emit("pump_state", {
        node_id: nodeId, state: "ON", source: "manual", expiresAt, manualLock: !!lock
    });

    if (expireSec) {
        const tid = setTimeout(async () => {
            try {
                await setPumpOff({
                    app, pumpTopic,
                    nodeId, source: "manual"
                });
            } catch (e) { }
        }, expireSec * 1000);
        timers.set(nodeId, tid);
    }
    return doc;
}

export async function setPumpOff({ app, pumpTopic, nodeId, source }) {
    clearTimer(nodeId);
    const doc = await PumpState.findOneAndUpdate(
        { node_id: nodeId },
        { state: "OFF", source: source || "manual", manualLock: false, expiresAt: undefined, updatedAt: new Date() },
        { upsert: true, new: true }
    );
    publish(pumpTopic, "OFF", { qos: 1 });
    console.log(`[PumpStateService] Pump OFF for node ${nodeId} by ${source || "manual"}`);
    app.get("io")?.emit("pump_state", {
        node_id: nodeId, state: "OFF", source: source || "manual"
    });
    return doc;
}
