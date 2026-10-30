import { OfertaModel } from '../modelos/ofertas.js';

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

            const oferta = await OfertaModel.create({
                titulo: req.body.titulo.trim(),
                descuento: req.body.descuento?.trim() ?? '',
                etiqueta: req.body.tag?.trim() || 'OFERTA',
                descripcion: req.body.descripcion?.trim() ?? '',
                imagen_url: req.file.path, // 👈 Sincronizado correctamente con Cloudinary y Supabase
                estado: 'Activo'
            });
            return res.status(201).json(oferta);
        } catch (error) {
            return res.status(500).json({ message: error.message });
        }
    },

    async actualizarOferta(req, res) {
        try {
            if (req.body.titulo !== undefined && !req.body.titulo.trim()) {
                return res.status(400).json({ message: 'El título es obligatorio' });
            }

            const cambios = {};
            if (req.body.titulo !== undefined) cambios.titulo = req.body.titulo.trim();
            if (req.body.descuento !== undefined) cambios.descuento = req.body.descuento.trim();
            if (req.body.descripcion !== undefined) cambios.descripcion = req.body.descripcion.trim();
            
            // 👇 Mapeo correcto del campo 'tag' que envía Flutter hacia la BD
            if (req.body.tag !== undefined) {
                cambios.etiqueta = req.body.tag.trim() || 'OFERTA';
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
            return res.status(500).json({ message: error.message });
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