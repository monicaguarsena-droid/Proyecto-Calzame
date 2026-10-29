import { supabase } from '../config/supabase.js';

export const OfertaModel = {
    async getAll() {
        const { data, error } = await supabase
            .from('ofertas')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    },

    async create(ofertaData) {
        const { data, error } = await supabase
            .from('ofertas')
            .insert([ofertaData])
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async update(id, cambios) {
        const { data, error } = await supabase
            .from('ofertas')
            .update(cambios)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async delete(id) {
        const { data, error } = await supabase
            .from('ofertas')
            .delete()
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }
};