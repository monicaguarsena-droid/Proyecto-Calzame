import { OfertaModel } from '../modelos/ofertas.js';
import { parsearDescuento } from '../utils/descuentos.js';

const responderErrorOferta = (res, error) => {
    const mensaje = error?.message ?? 'Error al guardar la oferta';
    const campoSinMigrar = ['producto_id', 'tag'].some((campo) =>
        mensaje.includes(campo)
    );
    if (
        campoSinMigrar &&
        ['PGRST204', '42703'].includes(error?.code)
    ) {
        return res.status(503).json({
            message: 'La base de datos necesita la migración BACKEND/migrations/20261114_ofertas_producto.sql antes de guardar ofertas.'
        });
    }
    return res.status(500).json({ message: mensaje });
};

export const OfertaController = {
    async obtenerOfertas(req, res) {
        try {
            const ofertas = await OfertaModel.getAll();
            return res.status(200).json(ofertas);
        } catch (error) {
            return res.status(500).json({ message: error.message });
        }
    },

    async crearOferta(req, res) {
        try {
            if (!req.file) {
                return res.status(400).json({ message: 'La foto es obligatoria' });
            }
            if (!req.body.titulo?.trim()) {
                return res.status(400).json({ message: 'El título es obligatorio' });
            }
            const productoId = Number(req.body.producto_id);
            if (!Number.isInteger(productoId) || productoId < 1) {
                return res.status(400).json({ message: 'Selecciona un calzado para la oferta' });
            }
            const descuento = parsearDescuento(req.body.descuento);
            if (descuento === null) {
                return res.status(400).json({ message: 'El descuento debe ser un número entre 1 y 100' });
            }

            const oferta = await OfertaModel.create({
                titulo: req.body.titulo.trim(),
                producto_id: productoId,
                descuento: String(descuento),
                tag: req.body.tag?.trim() || 'OFERTA',
                descripcion: req.body.descripcion?.trim() ?? '',
                imagen_url: req.file.path, // 👈 Sincronizado correctamente con Cloudinary y Supabase
                estado: 'Activo'
            });
            return res.status(201).json(oferta);
        } catch (error) {
            return responderErrorOferta(res, error);
        }
    },

    async actualizarOferta(req, res) {
        try {
            if (req.body.titulo !== undefined && !req.body.titulo.trim()) {
                return res.status(400).json({ message: 'El título es obligatorio' });
            }

            const cambios = {};
            if (req.body.titulo !== undefined) cambios.titulo = req.body.titulo.trim();
            if (req.body.descuento !== undefined) {
                const descuento = parsearDescuento(req.body.descuento);
                if (descuento === null) {
                    return res.status(400).json({ message: 'El descuento debe ser un número entre 1 y 100' });
                }
                cambios.descuento = String(descuento);
            }
            if (req.body.producto_id !== undefined) {
                const productoId = Number(req.body.producto_id);
                if (!Number.isInteger(productoId) || productoId < 1) {
                    return res.status(400).json({ message: 'Selecciona un calzado para la oferta' });
                }
                cambios.producto_id = productoId;
            }
            if (req.body.descripcion !== undefined) cambios.descripcion = req.body.descripcion.trim();
            
            // 👇 Mapeo correcto del campo 'tag' que envía Flutter hacia la BD
            if (req.body.tag !== undefined) {
                cambios.tag = req.body.tag.trim() || 'OFERTA';
            }

            if (req.file) {
                cambios.imagen_url = req.file.path;
            }

            if (Object.keys(cambios).length === 0) {
                return res.status(400).json({ message: 'No hay cambios para guardar' });
            }

            const oferta = await OfertaModel.update(req.params.id, cambios);
            return res.status(200).json(oferta);
        } catch (error) {
            return responderErrorOferta(res, error);
        }
    },

    async eliminarOferta(req, res) {
        try {
            await OfertaModel.delete(req.params.id);
            return res.status(200).json({ message: 'Oferta eliminada' });
        } catch (error) {
            return res.status(500).json({ message: error.message });
        }
    }
};