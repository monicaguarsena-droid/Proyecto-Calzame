import express from "express";
import dotenv from "dotenv";
import { supabase, conectaDB } from "./config/supabase.js";
import authRoutes from "./routers/auth.js"
import userRouter from "./routers/user.js";

dotenv.config();
conectaDB();

const app = express();
app.use(express.json());

app.get('/',(req, res) => {
    res.json({ message: 'Bienvenido al backend de proyecto-Calzame',
        estado: 'En línea',
        version: '1.0.0',
     });
});

app.use('/auth',authRoutes);

app.use('/usuarios',userRouter);




const PORT = 3000;

app.listen(PORT, ()=> {
    console.log(`Servidor corriendo en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`)
})