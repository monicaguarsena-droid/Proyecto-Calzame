import { supabase } from '../config/supabase.js';

const TAMANO_PAGINA = 1000;

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
