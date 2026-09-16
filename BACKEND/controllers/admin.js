import { supabase } from '../config/supabase.js';

// Estadísticas para el Tablero
export const obtenerEstadisticasAdmin = async (req, res) => {
    try {
        const { count: totalUsuarios } = await supabase
            .from('usuarios')
            .select('*', { count: 'exact', head: true });

        const { data: productos } = await supabase
            .from('Productos')
            .select('Stock');

        const stockTotal = productos ? productos.reduce((acc, p) => acc + (p.Stock || 0), 0) : 0;

        const { count: pedidosPendientesCount } = await supabase
            .from('Pedidos')
            .select('*', { count: 'exact', head: true })
            .eq('Estado', 'Pendiente');

        const { data: ultimosPedidos } = await supabase
            .from('Pedidos')
            .select('*, usuarios(nombre), Productos(Nombre)')
            .order('created_at', { ascending: false })
            .limit(5);

        return res.status(200).json({
            ventasHoy: 0,
            pedidosPendientes: pedidosPendientesCount || 0,
            productosEnStock: stockTotal,
            usuariosActivos: totalUsuarios || 0,
            ultimosPedidos: ultimosPedidos || []
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Crear Producto
export const crearProductoAdmin = async (req, res) => {
    try {
        const { nombre, precio, descripcion, stock, imagen_url, Talla, Categoria } = req.body;

        const { data, error } = await supabase
            .from('Productos')
            .insert([{
                Nombre: nombre,
                Precio: precio,
                Descripcion: descripcion,
                Stock: stock,
                Imagen: imagen_url, 
                Talla: Talla,
                Categoria: Categoria
            }])
            .select();

        if (error) return res.status(400).json({ error: error.message });
        return res.status(201).json({ mensaje: 'Producto creado exitosamente', producto: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Modificar Producto
export const actualizarProductoAdmin = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, precio, descripcion, stock, imagen_url, Talla, Categoria } = req.body;

        const { data, error } = await supabase
            .from('Productos')
            .update({
                Nombre: nombre,
                Precio: precio,
                Descripcion: descripcion,
                Stock: stock,
                Imagen: imagen_url,
                Talla: Talla,
                Categoria: Categoria
            })
            .eq('id', id)
            .select();

        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json({ mensaje: 'Producto actualizado exitosamente', producto: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Listar Clientes
export const obtenerClientesAdmin = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('usuarios')
            .select('id, cedula, nombre, email, Pedidos(*)');

        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Listar Pedidos
export const obtenerPedidosAdmin = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('Pedidos')
            .select('*, usuarios!Pedidos_Usuario_Cc_fkey(nombre, email)')
            .order('created_at', { ascending: false });

        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Actualizar Estado de Pedido
export const actualizarEstadoPedidoAdmin = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body;

        const { data, error } = await supabase
            .from('Pedidos')
            .update({ Estado: estado })
            .eq('id', id)
            .select();

        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json({ mensaje: 'Estado del pedido actualizado exitosamente', pedido: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};