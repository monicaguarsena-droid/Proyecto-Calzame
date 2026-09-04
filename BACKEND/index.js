import express from "express";
import dotenv from "dotenv";
import { supabase, conectaDB } from "./config/supabase.js";
import authRoutes from "./routers/auth.js";
import userRouter from "./routers/user.js";
import productosRouter from "./routers/productos.js";
import pedidosRouter from "./routers/pedidos.js";
import favoritosRouter from "./routers/favoritos.js";
import categoriasRouter from "./routers/categorias.js";
import direccionesRouter from "./routers/direcciones.js";
import recuperarRouter from "./routers/recuperar.js";
import carritoRouter from "./routers/carrito.js";
import adminRouter from "./routers/admin.js";
import chatRoutes from "./routers/chatBot.js";

dotenv.config();
conectaDB();

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
    res.json({ 
        message: 'Bienvenido al backend de proyecto-Calzame',
        estado: 'En línea',
        version: '1.0.0',
    });
});

app.use('/auth', authRoutes);
app.use('/usuarios', userRouter);
app.use('/productos', productosRouter);
app.use('/pedidos', pedidosRouter);
app.use('/favoritos', favoritosRouter);
app.use('/categorias', categoriasRouter);
app.use('/direcciones', direccionesRouter);
app.use('/recuperar', recuperarRouter);
app.use('/carrito', carritoRouter);
app.use('/admin', adminRouter);
app.use("/api/chat", chatRoutes);

const PORT = 3000;

app.listen(PORT, () => {
    console.log(`Servidor corriendo en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});