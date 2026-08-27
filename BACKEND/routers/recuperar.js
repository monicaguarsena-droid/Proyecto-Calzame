import express from "express";

const router = express.Router();


router.post("/", (req, res) => {
    res.json({ message: "Ruta de recuperación lista" });
});

export default router;