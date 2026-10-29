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
import carritoRouter from "./routers/carrito.js";
import adminRouter from "./routers/admin.js";
import chatRoutes from './routers/chatRouters.js';
import catalogoVisualRouter from "./routers/catalogo_visual.js";
import ofertasRouter from "./routers/ofertas.js";

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

//montando las rutas de la API
app.get('/health', (req, res) => {
    res.status(200).send('ok');
});

app.use('/api/auth', authRoutes); // Cambiado de '/auth' a '/api/auth'
app.use('/api/usuarios', userRouter);
app.use('/api/productos', productosRouter);
app.use('/api/pedidos', pedidosRouter);
app.use('/api/favoritos', favoritosRouter);
app.use('/api/categorias', categoriasRouter);
app.use('/api/direcciones', direccionesRouter);
app.use('/api/carrito', carritoRouter);
app.use('/api/admin', adminRouter);
app.use('/api/chat', chatRoutes);
app.use('/api/catalogo', catalogoVisualRouter);
app.use('/api/ofertas', ofertasRouter);



const PORT = 3000;

app.listen(PORT, () => {
    console.log(`Servidor corriendo en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});