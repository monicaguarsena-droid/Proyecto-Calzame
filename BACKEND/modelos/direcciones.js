import { supabase } from "../config/supabase.js";

export const Direccion = {
    getAll: async () => {
        const { data, error } = await supabase.from("direcciones").select("*");
        if (error) throw error;
        return data;
    },

    getByUserId: async (usuarioId) => {
        const { data, error } = await supabase.from("direcciones").select("*").eq("usuario_id", usuarioId);
        if (error) throw error;
        return data;
    },

    create: async (direccionData) => {
        const { data, error } = await supabase
            .from("direcciones")
            .insert([direccionData])
            .select();
        if (error) throw error;
        return data;
    },

    update: async (id, direccionData) => {
        const { data, error } = await supabase
            .from("direcciones")
            .update(direccionData)
            .eq("id", id)
            .select();
        if (error) throw error;
        return data;
    },

    delete: async (id) => {
        const { data, error } = await supabase
            .from("direcciones")
            .delete()
            .eq("id", id)
            .select();
        if (error) throw error;
        return data;
    }
};