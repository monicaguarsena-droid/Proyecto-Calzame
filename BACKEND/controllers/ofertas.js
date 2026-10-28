import { OfertaModel } from '../modelos/ofertas.js';

export const OfertaController = {
    // Obtener ofertas
    async obtenerOfertas(req, res) {
        try {
            const ofertas = await OfertaModel.getAll();
            return res.status(200).json(ofertas);
        } catch (error) {
            return res.status(500).json({ 
                success: false, 
                message: error.message 
            });
        }
    },

    // Guardar/Crear oferta
    async crearOferta(req, res) {
        try {
            const nuevaOferta = await OfertaModel.create(req.body);
            
            return res.status(201).json({
                success: true,
                message: 'Oferta creada exitosamente',
                data: nuevaOferta
            });
        } catch (error) {
            return res.status(500).json({ 
                success: false, 
                message: error.message 
            });
        }
    }
};