import { supabase } from '../config/supabase.js';

export const OfertaModel = {
    // Obtener todas las ofertas
    async getAll() {
        const { data, error } = await supabase
            .from('ofertas')
            .select('*');

        if (error) throw error;
        return data;
    },

    // Crear una nueva oferta
    async create(ofertaData) {
        const { titulo, descuento, etiqueta, descripcion, imagen } = ofertaData;

        const { data, error } = await supabase
            .from('ofertas')
            .insert([{ titulo, descuento, etiqueta, descripcion, imagen }])
            .select();

        if (error) throw error;
        return data[0];
    }
};