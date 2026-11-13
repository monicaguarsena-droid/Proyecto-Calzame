import { supabase } from '../config/supabase.js';

const TAMANO_PAGINA = 1000;
const TAMANO_LOTE_PEDIDOS = 250;

export const obtenerPedidosEntregadosPorRango = async (desde, hasta) => {
    const pedidos = [];
    let inicioPagina = 0;

    while (true) {
        const { data, error } = await supabase
            .from('Pedidos')
            .select('id, created_at, Total')
            .eq('Estado', 'Entregado')
            .gte('created_at', desde)
            .lt('created_at', hasta)
            .order('created_at', { ascending: true })
            .order('id', { ascending: true })
            .range(inicioPagina, inicioPagina + TAMANO_PAGINA - 1);

        if (error) return { data: null, error };

        pedidos.push(...(data ?? []));
        if (!data || data.length < TAMANO_PAGINA) break;
        inicioPagina += TAMANO_PAGINA;
    }

    return { data: pedidos, error: null };
};

export const obtenerDetallesDePedidos = async (pedidoIds) => {
    const detalles = [];

    for (let indice = 0; indice < pedidoIds.length; indice += TAMANO_LOTE_PEDIDOS) {
        const lote = pedidoIds.slice(indice, indice + TAMANO_LOTE_PEDIDOS);
        let inicioPagina = 0;

        while (true) {
            const { data, error } = await supabase
                .from('detalle_pedido')
                .select('id, Pedido_Id, Producto_Id, Cantidad, Subtotal')
                .in('Pedido_Id', lote)
                .order('id', { ascending: true })
                .range(inicioPagina, inicioPagina + TAMANO_PAGINA - 1);

            if (error) return { data: null, error };

            detalles.push(...(data ?? []));
            if (!data || data.length < TAMANO_PAGINA) break;
            inicioPagina += TAMANO_PAGINA;
        }
    }

    return { data: detalles, error: null };
};

export const obtenerProductosPorIds = async (productoIds) => {
    const productos = [];

    for (let indice = 0; indice < productoIds.length; indice += TAMANO_LOTE_PEDIDOS) {
        const lote = productoIds.slice(indice, indice + TAMANO_LOTE_PEDIDOS);
        const { data, error } = await supabase
            .from('Productos')
            .select('id, Nombre')
            .in('id', lote);

        if (error) return { data: null, error };
        productos.push(...(data ?? []));
    }

    return { data: productos, error: null };
};

export const obtenerConteoPedidosPendientes = async () => {
    const { count, error } = await supabase
        .from('Pedidos')
        .select('id', { count: 'exact', head: true })
        .eq('Estado', 'Pendiente');

    return { data: count, error };
};

export const obtenerConteoProductos = async () => {
    const { count, error } = await supabase
        .from('Productos')
        .select('id', { count: 'exact', head: true });

    return { data: count, error };
};
