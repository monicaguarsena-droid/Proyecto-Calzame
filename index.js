import express from "express";
import dotenv from "dotenv";
import { supabase, conectaDB } from "./config/supabase.js";
import authRoutes from "./routes/authRoutes.js";

dotenv.config();
conectaDB();

const app = express();
app.use.use(express.json());

app.get('/',(req, res) => {
    res.json({ message: 'Bienvenido al backend de proyecto-Calzame',
        estado: 'En línea',
        version: '1.0.0',
     });
});

app.use('/auth',authRoutes);