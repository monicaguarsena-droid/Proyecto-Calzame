import Grop from 'groq-sdk';
import { supabase } from '../config/supabase.js';

const groq = new Grop({ apiKey: process.env.GROQ_API_KEY });

const formatearLista = (valor) => {
    if (Array.isArray(valor)) {
        const elementos = valor
            .map((item) => {
                if (typeof item === 'string' || typeof item === 'number') return item;
                return item?.color ?? item?.nombre ?? item?.talla ?? '';
            })
            .filter(Boolean);
        return elementos.length ? elementos.join(', ') : 'No especificados';
    }

    if (typeof valor === 'string' && valor.trim()) {
        try {
            const lista = JSON.parse(valor);
            if (Array.isArray(lista)) return formatearLista(lista);
        } catch {
            return valor;
        }
        return valor;
    }

    return 'No especificados';
};

export const chatearConCalzame = async (req, res) => {
    try {
        const { mensaje, sesionId, usuarioId } = req.body;

        if (!mensaje || !mensaje.trim()){
            return res.status(400).json({ message: 'Debes enviar un mensaje.'});
        }

        //si el cliente no manda sesion, creamos un identificador temporal
        const idSesionValido = sesionId || `calzame_sesion_${Date.now()}`;

        //1. Obtener el catálogo y sus ofertas activas desde Supabase
        const {data: Productos, error:errorProductos}=await supabase
            .from('Productos')
            .select('*')
            .gt('Stock', 0);

        if (errorProductos) {
            console.error('Error al consultar Supabase:', errorProductos.message);
            return res.status(500).json({
                message: 'Error al consultar los productos disponibles.',
                error: errorProductos.message
            });
        }

        const productosDisponibles = Productos || [];
        const { data: ofertasActivas, error: errorOfertas } = productosDisponibles.length
            ? await supabase
                .from('ofertas')
                .select('producto_id, titulo, descuento, tag')
                .eq('estado', 'Activo')
                .in('producto_id', productosDisponibles.map((producto) => producto.id))
            : { data: [], error: null };

        if (errorOfertas) {
            console.error('Error al consultar ofertas activas:', errorOfertas.message);
            return res.status(500).json({
                message: 'Error al consultar las ofertas de los productos.',
                error: errorOfertas.message
            });
        }

        const ofertasPorProducto = new Map(
            (ofertasActivas || []).map((oferta) => [String(oferta.producto_id), oferta])
        );
        const catalogoTexto = productosDisponibles.length
            ? productosDisponibles.map((producto) => {
                const oferta = ofertasPorProducto.get(String(producto.id));
                const precio = Number(producto.Precio);
                const imagen = producto.Imagen || producto.Imagenes?.[0];
                const ofertaTexto = oferta
                    ? `${oferta.tag || 'OFERTA'}: ${oferta.titulo || 'Descuento'} (${oferta.descuento})` +
                        (Number.isFinite(precio) && Number.isFinite(parseFloat(oferta.descuento))
                            ? `; precio con descuento: $${Math.round(precio * (1 - parseFloat(oferta.descuento) / 100)).toLocaleString('es-CO')} COP`
                            : '')
                    : 'No tiene oferta activa';

                return [
                    `- **${producto.Nombre || 'Producto'}**`,
                    imagen ? `  ![${producto.Nombre || 'Producto'}](${imagen})` : '  Imagen: No disponible',
                    `  Categoría: ${producto.Categoria || 'No especificada'} | Tipo: ${producto.TipoCalzado || 'No especificado'}`,
                    `  Precio: $${Number.isFinite(precio) ? precio.toLocaleString('es-CO') : 'No disponible'} COP`,
                    `  Tallas disponibles: ${formatearLista(producto.Tallas ?? producto.Talla)}`,
                    `  Colores disponibles: ${formatearLista(producto.Colores)}`,
                    `  Stock: ${producto.Stock ?? 0}`,
                    `  Descripción: ${producto.Descripcion || 'Sin descripción'}`,
                    `  Oferta: ${ofertaTexto}`
                ].join('\n');
            }).join('\n')
            : 'No hay productos disponibles actualmente.';

    const systemPrompt =`
    Eres el asesor virtual y anfitrion de la tienda de calzados "Calzado Mar&Paz".
    Tu tarea es ayudar a los clientes a encontrar el calzado perfecto según sus necesidades y preferencias.
    Eres alegre,amable, refrestante, educado y muy servicial.
    
    CATALOGO ACTUAL EN TIENDA:
    ${catalogoTexto}

    GUÍA DE TALLAS (talla: longitud del pie):
    Dama, tenis y deportivos: 35 = 22.5 cm, 36 = 23.0 cm, 37 = 24.0 cm, 38 = 24.5 cm, 39 = 25.0 cm.
    Dama, sandalias, tacones y zapatillas: 34 = 22.0 cm, 35 = 22.8 cm, 36 = 23.5 cm, 37 = 24.2 cm, 38 = 25.0 cm.
    Caballero, tenis y deportivos: 39 = 25.0 cm, 40 = 25.5 cm, 41 = 26.5 cm, 42 = 27.0 cm, 43 = 28.0 cm.
    Caballero, casual y formal: 38 = 24.5 cm, 39 = 25.0 cm, 40 = 25.8 cm, 41 = 26.8 cm, 42 = 27.5 cm.
    Infantil: 28 = 17.5 cm, 29 = 18.0 cm, 30 = 19.0 cm, 31 = 19.5 cm, 32 = 20.5 cm.

    REGLAS DE ATENCION:

    1. Si el cliente solo saluda (ej: 'Hola','¿como estas?'), responde con cortesia y cercania sin dar el catalogo de los productos ni los precios:
    'Hola! Bienvenido a Calzado Mar&Paz, la tienda de calzados que te hace sentir cómodo y elegante. ¿En qué puedo ayudarte hoy?'
    2. Si preguntan por productos, catálogo, disponibilidad o precios, usa únicamente los productos del catálogo actual y muestra para cada uno la imagen con el formato markdown ![nombre](URL), precio, tallas, colores y si tiene una oferta activa.
    3. Conserva exactamente las URL de imágenes; escribe cada imagen markdown en una línea separada para que se muestre en el chat.
    4. Si preguntan por la guía de tallas o equivalencias, muestra las equivalencias de la categoría y tipo de calzado indicados arriba.
    5. No inventes productos, tallas, colores, ofertas ni equivalencias. Especifica los precios siempre en pesos colombianos ($ COP).
    6. Sé conciso y completa tus oraciones.

    `;
    //3. inferencia con grop
    const completion = await groq.chat.completions.create({
        model: 'openai/gpt-oss-20b',
        messages: [
            {role: 'system', content: systemPrompt},
            {role: 'user', content: mensaje}
        ],
        temperature: 0.3,
        max_completion_tokens: 1500,
    });

    const respuestaTexto = completion.choices[0].message.content || 'No pude generar una respuesta ';

    //4. guardar ambos mensaje (pregunta y respuesta) en la tabla 'chat_calzame' en supabase
    const  registrosAInsertar = [
        {
            sesion_id: idSesionValido,
            usuario_id: usuarioId || null,
            emisor: 'usuario',
            mensaje: mensaje.trim()
        },
        {
            sesion_id: idSesionValido,
            usuario_id: usuarioId || null,
            emisor: 'chat',
            mensaje: respuestaTexto
        }
    ];
    const {error: errorInsert} = await supabase
        .from('mensaje_chat')
        .insert(registrosAInsertar);

    if (errorInsert){
        console.error('Error guardando el historial en supabase:', errorInsert.message);
        //No frenamos la  respuesta al cliente aunque falle el guardado en BD
    }
    return res.status(200).json({
        respuesta: respuestaTexto,
        sesionId: idSesionValido
    });
    } catch (error){
        console.error('Error en groq Chat Calzame:', error);
        return res.status(500).json({
            message:'Error al procesar la respuesta',
            error: error.message
        });
    }
};

//Endpoint extra para recuperar la conversacion si el usuario vuelve a abrir la app 
export const obtenerHistorialCalzame = async (req, res) => {
    try{
        const { sesionId }=req.params;

        const { data: historial, error } = await supabase
            .from('mensajes_chat')
            .select('emisor,mensaje,created_at')
            .eq('sesion_id', sesionId)
            .order('created_at', { ascending: true});
    
        if (error){
            return res.status(500).json({
                message: 'Error al consultar historial', error:error.message
            });
        }
        return res.status(200).json({ historial: historial || [] });
    }catch{
        return res.status(500).json({ message: 'Error interno', error:error.message});
    }
};