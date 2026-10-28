import { supabase } from "../config/supabase.js";

const tablas = {
    ofertas: "ofertas",
    tipos: "tipos_calzado"
};

const crearControlador = (tabla, campos) => ({
    listar: async (req, res) => {
        try {
            const { data, error } = await supabase
                .from(tabla)
                .select("*")
                .order("created_at", { ascending: false });
            if (error) return res.status(500).json({ error: error.message });
            return res.status(200).json(data);
        } catch (error) {
            return res.status(500).json({ error: error.message });
        }
    },

    crear: async (req, res) => {
        try {
            if (!req.file) {
                return res.status(400).json({ error: "La foto es obligatoria" });
            }
            const primerCampo = campos[0];
            if (!req.body[primerCampo]?.trim()) {
                return res.status(400).json({ error: `El campo ${primerCampo} es obligatorio` });
            }
            const registro = Object.fromEntries(
                campos.map((campo) => [campo, req.body[campo] ?? ""])
            );
            registro.imagen_url = req.file.path;

            const { data, error } = await supabase
                .from(tabla)
                .insert([registro])
                .select()
                .single();
            if (error) return res.status(400).json({ error: error.message });
            return res.status(201).json(data);
        } catch (error) {
            return res.status(500).json({ error: error.message });
        }
    },

    actualizar: async (req, res) => {
        try {
            const primerCampo = campos[0];
            if (req.body[primerCampo] !== undefined && !req.body[primerCampo].trim()) {
                return res.status(400).json({ error: `El campo ${primerCampo} es obligatorio` });
            }
            const cambios = Object.fromEntries(
                campos
                    .filter((campo) => req.body[campo] !== undefined)
                    .map((campo) => [campo, req.body[campo]])
            );
            if (req.file) cambios.imagen_url = req.file.path;

            const { data, error } = await supabase
                .from(tabla)
                .update(cambios)
                .eq("id", req.params.id)
                .select()
                .single();
            if (error) return res.status(400).json({ error: error.message });
            return res.status(200).json(data);
        } catch (error) {
            return res.status(500).json({ error: error.message });
        }
    },

    eliminar: async (req, res) => {
        try {
            const { error } = await supabase
                .from(tabla)
                .delete()
                .eq("id", req.params.id);
            if (error) return res.status(400).json({ error: error.message });
            return res.status(200).json({ mensaje: "Registro eliminado" });
        } catch (error) {
            return res.status(500).json({ error: error.message });
        }
    }
});

export const ofertasController = crearControlador(tablas.ofertas, [
    "titulo",
    "descuento",
    "descripcion",
    "tag"
]);

export const tiposCalzadoController = crearControlador(tablas.tipos, [
    "nombre",
    "descripcion"
]);
