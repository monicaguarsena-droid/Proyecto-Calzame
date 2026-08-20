import jwt from 'jsonwebtoken';

//verificamos que exita un token valido (usuario autenticado)
export const verificarToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado, por favor inicie sesión.' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Token inválido o expirado.' });
        }
        req.usuario = decoded;
        next();
    });
};

//solo deja pasar si el usuario tiene rol de admin(panel de administrador)
export const verificarAdmin = (req, res, next) => {
    if (req.usuario?.rol !== 'admin') {
        return res.status(403).json({ error: 'No tienes permisos de administrador.' });
    }
    next();
};