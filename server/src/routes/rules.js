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
    if (!body.node_id || !body.type || !body.action) {
      return res.status(400).json({ error: "node_id, type, action required" });
    }
    const rule = await AutomationRule.create(body);
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
