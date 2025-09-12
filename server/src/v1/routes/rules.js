import { Router } from "express";
import AutomationRule from "../models/AutomationRule.js";

const router = Router();

router.get("/", async (req, res) => {
  const q = {};
  if (req.query.nodeId) q.node_id = Number(req.query.nodeId);
  const rules = await AutomationRule.find(q).sort({ createdAt: -1 });
  res.json(rules);
});

router.post("/", async (req, res) => {
  try {
    const body = req.body || {};
    const schema = Joi.object({
      node_id: Joi.number().integer().required(),
      type: Joi.string().valid("soil_threshold", "humidity_threshold", "temperature_threshold").required(),
      action: Joi.string().valid("pump_on").required(),
      min: Joi.number().optional(),
      max: Joi.number().optional(),
      durationSec: Joi.number().integer().min(1).max(3600).optional(),
      cooldownSec: Joi.number().integer().min(0).max(86400).optional(),
      enabled: Joi.boolean().default(true),
      timeWindows: Joi.array().items(
        Joi.object({
          start: Joi.string().pattern(/^\d{2}:\d{2}$/).required(),
          end: Joi.string().pattern(/^\d{2}:\d{2}$/).required()
        })
      ).optional()
    });
    const { value, error } = schema.validate(body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    const rule = await AutomationRule.create(value);
    res.json(rule);
  } catch (e) { res.status(400).json({ error: e.message }); }
});

router.put("/:id", async (req, res) => {
  try {
    const updated = await AutomationRule.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (e) { res.status(400).json({ error: e.message }); }
});

router.delete("/:id", async (req, res) => {
  try {
    await AutomationRule.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

export default router;
