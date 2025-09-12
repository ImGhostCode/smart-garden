import express from "express";
import Joi from "joi";
import SensorReading from "../models/SensorReading.js";
import CommandLog from "../models/CommandLog.js";
import NodeMeta from "../models/NodeMeta.js";
import { publish } from "../services/mqttClient.js";
import { setPumpOnManual, setPumpOff, getPumpState } from "../services/pumpStateService.js";


const router = express.Router();

// Health check
router.get("/health", (req, res) => res.json({ status: "ok" }));

// List known nodes + last seen
router.get("/nodes", async (req, res, next) => {
  try {
    const nodes = await NodeMeta.find().sort({ node_id: 1 }).lean();
    res.json(nodes);
  } catch (e) { next(e); }
});

// Get latest reading for a node
router.get("/nodes/:nodeId/latest", async (req, res, next) => {
  try {
    const nodeId = Number(req.params.nodeId);
    const latest = await SensorReading.findOne({ node_id: nodeId }).sort({ createdAt: -1 }).lean();
    res.json(latest || {});
  } catch (e) { next(e); }
});

// Query readings with time range & limit
router.get("/readings", async (req, res, next) => {
  try {
    const schema = Joi.object({
      nodeId: Joi.number().integer().required(),
      from: Joi.date().optional(),
      to: Joi.date().optional(),
      limit: Joi.number().integer().min(1).max(10000).default(500)
    });
    const { value, error } = schema.validate(req.query);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const { nodeId, from, to, limit } = value;
    const query = { node_id: nodeId };
    if (from || to) {
      query.createdAt = {};
      if (from) query.createdAt.$gte = new Date(from);
      if (to) query.createdAt.$lte = new Date(to);
    }

    const rows = await SensorReading.find(query).sort({ createdAt: -1 }).limit(limit).lean();
    res.json(rows);
  } catch (e) { next(e); }
});

// Publish pump command
// Body: { command: 'ON', lock?: boolean, expireSec?: number }
router.post("/pump/:nodeId", async (req, res, next) => {
  try {
    const nodeId = Number(req.params.nodeId);
    const schema = Joi.object({
      command: Joi.string().valid("ON", "OFF").required(),
      lock: Joi.boolean().optional(),
      expireSec: Joi.number().integer().min(1).max(3600).optional()
    });
    const { value, error } = schema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const topic = `smartgarden/area1/node/${nodeId}/pump`;
    let status = "sent", errMsg = "";
    try {
      if (value.command === "ON") {
        // publish MQTT "ON" như cũ ...
        await publish(topic, value.command);
        await setPumpOnManual({ app: req.app, pumpTopic: topic, nodeId, lock: value.lock === true, expireSec: value.expireSec });
      } else {
        // publish MQTT "OFF" như cũ ...
        await setPumpOff({ app: req.app, pumpTopic: topic, nodeId, source: "manual" });
      }
    } catch (err) {
      status = "failed";
      errMsg = err.message;
    }

    const log = await CommandLog.create({
      node_id: nodeId,
      command: value.command,
      topic,
      status,
      error: errMsg
    });

    // Emit socket.io event
    req.app.get("io").emit("command", log);

    res.json({ ok: true, state: await getPumpState(nodeId) });
    // res.json({ ok: status === "sent", log });
  } catch (e) { next(e); }
});

// List command logs
router.get("/commands", async (req, res, next) => {
  try {
    const { nodeId, limit = 100 } = req.query;
    const query = {};
    if (nodeId) query.node_id = Number(nodeId);
    const logs = await CommandLog.find(query).sort({ createdAt: -1 }).limit(Number(limit)).lean();
    res.json(logs);
  } catch (e) { next(e); }
});

export default router;
