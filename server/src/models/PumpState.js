import mongoose from "mongoose";

const PumpStateSchema = new mongoose.Schema(
    {
        node_id: { type: Number, index: true, required: true, unique: true },
        state: { type: String, enum: ["ON", "OFF"], default: "OFF" },
        source: { type: String, enum: ["manual", "auto"], default: "manual" },
        // Khi source=auto và có thời hạn
        expiresAt: { type: Date },
        // Manual lock: khi true thì automation KHÔNG được override cho tới khi user tắt manual
        manualLock: { type: Boolean, default: false },
        updatedAt: { type: Date, default: Date.now },
    },
    { timestamps: true }
);

export default mongoose.model("PumpState", PumpStateSchema);
