import { Direccion } from "../modelos/direcciones.js";

export const obtenerDirecciones = async (req, res) => {
    try {
        const direcciones = await Direccion.getAll();
        return res.status(200).json(direcciones);
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};

export const obtenerDireccionesPorUsuario = async (req, res) => {
    try {
        const direcciones = await Direccion.getByUserId(req.params.usuarioId);
        return res.status(200).json(direcciones);
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};

export const crearDireccion = async (req, res) => {
    try {
        const nuevaDireccion = await Direccion.create(req.body);
        return res.status(201).json({
            mensaje: "Dirección creada con éxito",
            direccion: nuevaDireccion
        });
    } catch (err) {
        return res.status(400).json({ error: err.message });
    }
};

export const actualizarDireccion = async (req, res) => {
    try {
        const direccionActualizada = await Direccion.update(req.params.id, req.body);
        return res.status(200).json({
            mensaje: "Dirección actualizada con éxito",
            direccion: direccionActualizada
        });
    } catch (err) {
        return res.status(400).json({ error: err.message });
    }
};

export const eliminarDireccion = async (req, res) => {
    try {
        await Direccion.delete(req.params.id);
        return res.status(200).json({ mensaje: "Dirección eliminada con éxito" });
    } catch (err) {
        return res.status(400).json({ error: err.message });
    }
};