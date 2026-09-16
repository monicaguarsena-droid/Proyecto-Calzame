import { supabase } from "../config/supabase.js";

export const Direccion = {
    getAll: async () => {
        const { data, error } = await supabase.from("direcciones").select("*");
        if (error) throw new Error(error.message);
        return data;
    },

    getByUserId: async (usuarioId) => {
        const { data, error } = await supabase
            .from("direcciones")
            .select("*")
            .eq("usuario_id", usuarioId);
        if (error) throw new Error(error.message);
        return data;
    },

    create: async (direccionData) => {
       
        const { usuario_id, calle, ciudad, codigo_postal, referencia } = direccionData;

        const { data, error } = await supabase
            .from("direcciones")
            .insert([{ usuario_id, calle, ciudad, codigo_postal, referencia }])
            .select();

        if (error) throw new Error(error.message);
        return data[0];
    },

    update: async (id, direccionData) => {
        const { calle, ciudad, codigo_postal, referencia } = direccionData;

        const { data, error } = await supabase
            .from("direcciones")
            .update({ calle, ciudad, codigo_postal, referencia })
            .eq("id", id)
            .select();

        if (error) throw new Error(error.message);
        return data[0];
    },

    delete: async (id) => {
        const { data, error } = await supabase
            .from("direcciones")
            .delete()
            .eq("id", id)
            .select();

        if (error) throw new Error(error.message);
        return data;
    }
};