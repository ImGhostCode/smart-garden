import AutomationRule from "../models/AutomationRule.js";
import CommandLog from "../models/CommandLog.js";
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc.js";
import timezone from "dayjs/plugin/timezone.js";
import PumpState from "../models/PumpState.js";
import { setPumpOnAuto } from "./pumpStateService.js";
dayjs.extend(utc);
dayjs.extend(timezone);

export class AutomationEngine {
  constructor({ app, mqttClient, mqttTopicPumpBase = "smartgarden/area1/node" }) {
    this.app = app;
    this.mqttClient = mqttClient;
    this.mqttTopicPumpBase = mqttTopicPumpBase;
    this._lastDailyReset = dayjs().startOf("day");
  }

  async onNewReading(reading) {
    const ps = await PumpState.findOne({ node_id: reading.node_id });
    if (ps?.manualLock) {
      // manual đang lock → bỏ qua automation
      console.log(`[Automation] Skipping automation for node ${reading.node_id} due to manual lock`);
      return;
    }
    const rules = await AutomationRule.find({ node_id: reading.node_id, enabled: true }).lean();
    for (const rule of rules) {
      if (!this._isWithinWindows(rule.timeWindows)) continue;
      const val = this._pickValue(rule.type, reading);
      if (val == null) continue;

      const now = dayjs();
      const shouldTrigger = rule.min != null && val < rule.min;
      const shouldStop = rule.max != null && val > rule.max;

      if (rule.lastTriggeredAt) {
        const nextAllowed = dayjs(rule.lastTriggeredAt).add(rule.cooldownSec || 0, "second");
        if (now.isBefore(nextAllowed)) continue;
      }
      if ((rule.todayRuntimeSec || 0) >= (rule.maxDailyRuntimeSec || 0)) continue;

      if (shouldTrigger) await this._executePump(rule, reading.node_id);
      else if (shouldStop) { /* no-op; duration based auto-off */ }
    }
  }

  async _executePump(rule, nodeId) {
    const topic = `${this.mqttTopicPumpBase}/${nodeId}/pump`;
    try {
      this.mqttClient.publish(topic, "ON", { qos: 1 });
      console.log(`[Automation] Executing pump ON for node ${nodeId} with rule ${rule._id}`);
      await setPumpOnAuto({ app: this.app, mqttClient: this.mqttClient, pumpTopic: topic, nodeId, durationSec: rule.durationSec });
      // (không cần setTimeout OFF ở engine nữa, vì pumpStateService đã làm + emit)
      const log = await CommandLog.create({ node_id: nodeId, command: "ON", status: "sent", topic });
      this.app.get("io")?.emit("automation_action", {
        node_id: nodeId, ruleId: String(rule._id), ruleName: rule.name || rule.type,
        command: "ON", durationSec: rule.durationSec, createdAt: new Date()
      });
      this.app.get("io")?.emit("command", log);
      await AutomationRule.updateOne(
        { _id: rule._id },
        { $set: { lastTriggeredAt: new Date() }, $inc: { todayRuntimeSec: rule.durationSec || 0 } }
      );
    } catch (e) { console.error("[Automation] executePump error:", e.message); }
  }

  _pickValue(type, r) {
    if (type === "soil_threshold") return r.soil;
    if (type === "humidity_threshold") return r.humidity;
    if (type === "temperature_threshold") return r.temperature;
    return null;
  }

  _isWithinWindows(windows) {
    if (!windows || !windows.length) return true;
    const now = new Date();
    const hh = str => parseInt(str.split(":")[0]);
    const mm = str => parseInt(str.split(":")[1]);
    const cur = now.getHours() * 60 + now.getMinutes();
    return windows.some(w => {
      if (!w.start || !w.end) return false;
      const s = hh(w.start) * 60 + mm(w.start);
      const e = hh(w.end) * 60 + mm(w.end);
      return cur >= s && cur <= e
    });
  }

  async tick() {
    const todayStart = new Date(); todayStart.setHours(0, 0, 0, 0);
    if (this._lastDailyReset.valueOf() < todayStart.valueOf()) {
      await AutomationRule.updateMany({}, { $set: { todayRuntimeSec: 0 } });
      this._lastDailyReset = todayStart;
      console.log("[Automation] daily counters reset");
    }
  }
}
