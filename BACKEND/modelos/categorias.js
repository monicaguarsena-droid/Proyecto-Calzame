import { supabase } from "../config/supabase.js";

export const Categoria = {
    getAll: async () => {
        const { data, error } = await supabase.from("categorias").select("*");
        if (error) throw error;
        return data;
    },

    getById: async (id) => {
        const { data, error } = await supabase.from("categorias").select("*").eq("id", id).single();
        if (error) throw error;
        return data;
    },

    create: async (categoriaData) => {
        const { data, error } = await supabase
            .from("categorias")
            .insert([categoriaData])
            .select();
        if (error) throw error;
        return data;
    },

    update: async (id, categoriaData) => {
        const { data, error } = await supabase
            .from("categorias")
            .update(categoriaData)
            .eq("id", id)
            .select();
        if (error) throw error;
        return data;
    },

    delete: async (id) => {
        const { data, error } = await supabase
            .from("categorias")
            .delete()
            .eq("id", id)
            .select();
        if (error) throw error;
        return data;
    }
};