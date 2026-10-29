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
                tag: req.body.tag?.trim() || 'OFERTA',
                descripcion: req.body.descripcion?.trim() ?? '',
                imagen_url: req.file.path,
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
            for (const campo of ['titulo', 'descuento', 'tag', 'descripcion']) {
                if (req.body[campo] !== undefined) {
                    cambios[campo] = req.body[campo].trim();
                }
            }
            if (req.file) cambios.imagen_url = req.file.path;
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