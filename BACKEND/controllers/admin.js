import { supabase } from '../config/supabase.js';

// Estadísticas para el Tablero de Ventas
export const obtenerEstadisticasAdmin = async (req, res) => {
    try {
        const { count: totalUsuarios } = await supabase.from('usuarios').select('*', { count: 'exact', head: true });
        const { data: productos } = await supabase.from('Productos').select('stock');
        const stockTotal = productos ? productos.reduce((acc, p) => acc + (p.stock || 0), 0) : 0;

        const { data: ultimosPedidos } = await supabase
            .from('Pedidos')
            .select('*, usuarios(nombre), Productos(nombre)')
            .order('created_at', { ascending: false })
            .limit(5);

        res.json({
            ventasHoy: 0,
            pedidosPendientes: 12, 
            productosEnStock: stockTotal,
            usuariosActivos: totalUsuarios || 0,
            ultimosPedidos: ultimosPedidos || []
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Crear un nuevo producto
export const crearProductoAdmin = async (req, res) => {
    const { nombre, precio, descripcion, stock, imagen_url, categoria_id } = req.body;
    const { data, error } = await supabase
        .from('Productos')
        .insert([{ nombre, precio, descripcion, stock, imagen_url, categoria_id }])
        .select();

    if (error) return res.status(400).json({ error: error.message });
    res.status(201).json({ mensaje: 'Producto creado exitosamente', producto: data });
};

// Modificar un producto
export const actualizarProductoAdmin = async (req, res) => {
    const { id } = req.params;
    const { nombre, precio, descripcion, stock, imagen_url } = req.body;
    const { data, error } = await supabase
        .from('Productos')
        .update({ nombre, precio, descripcion, stock, imagen_url })
        .eq('id', id)
        .select();

    if (error) return res.status(400).json({ error: error.message });
    res.json({ mensaje: 'Producto actualizado exitosamente', producto: data });
};

// Listar clientes
export const obtenerClientesAdmin = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('usuarios')
            .select('id, nombre, correo, telefono, Pedidos(*)');

        if (error) return res.status(400).json({ error: error.message });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Listar todos los pedidos de los clientes
export const obtenerPedidosAdmin = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('Pedidos')
            .select('*, usuarios(nombre, correo), Productos(nombre, precio)')
            .order('created_at', { ascending: false });

        if (error) return res.status(400).json({ error: error.message });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Cambiar el estado de un pedido (Ej: Pendiente, Enviado, Entregado)
export const actualizarEstadoPedidoAdmin = async (req, res) => {
    const { id } = req.params;
    const { estado } = req.body;

    try {
        const { data, error } = await supabase
            .from('Pedidos')
            .update({ estado })
            .eq('id', id)
            .select();

        if (error) return res.status(400).json({ error: error.message });
        res.json({ mensaje: 'Estado del pedido actualizado exitosamente', pedido: data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};