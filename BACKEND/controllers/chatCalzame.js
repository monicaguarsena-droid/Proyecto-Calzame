import Grop from 'groq-sdk';
import { supabase } from '../config/supabase';

const groq = new Grop({ apiKey: process.env.GROQ_API_KEY });

export const chatearConCalzame = async (req, res) => {
    try {
        const { mensaje, sesionId, usuarioId } = req.body;

        if (!mensaje || !mensaje.trim()){
            return res.status(400).json({ message: 'Debes enviar un mensaje.'});
        }

        //si el cliente no manda sesion, creamos un identificador temporal
        const idSesionValido = sesionId || `calzame_sesion_${Date.now()}`;

        //1. Obtener la carta desde tu tabla 'productos' en supabase
        const {data: productos, error:errorProductos}=await supabase
            .from('productos')
            .select('nombre, categoria, descripcion, precio, talla');

        if (errorProductos) {
            console.error('Error al consultar Supabase:', errorProductos.message);
            return res.status(200).json({
                respuesta:'!Hola! En este momento no tenemos el cazado registrado en el local.'
            });
    }
    const catalogoTexto=productos.map(p=>`-**${p.nombre}**: $${ Number(p.precio).toLocaleString('es-CO')} COP | Descripcion: ${p.descripcion}`).join('\n');

    const systemPrompt =`
    Eres el asesor virtual y anfitrion de la tienda de calzados "Calzame".
    Tu tarea es ayudar a los clientes a encontrar el calzado perfecto según sus necesidades y preferencias.
    Eres alegre,amable refrestante, educado y muy servicial.
    
    CATALOGO ACTUAL EN TIENDA:
    ${catalogoTexto}

    REGLAS DE ATENCION:

    1. Si el cliente solo saluuda (ej: 'Hola','¿como estas?'), responde con cortesia y cercania sin dar el catalogo de los productos ni los precios:
    'Hola! Bienvenido a Calzame, la tienda de calzados que te hace sentir cómodo y elegante. ¿En qué puedo ayudarte hoy?'
    2. Da el catalogo, los productos, el precio y la talla UNICAMENTE cuando el cliente pregunte por el catalogo, los productos o cuanto cuesta los productos.
    3. Especifica los valores siempre en pesos colombianos ($ COP).
    4. Se conciso y completa tus oraciones.

    `;
    //3. inferencia con grop
    const completion = await groq.completions.create({
        model: 'openai/gpt-oss-20b',
        messages: [
            {role: 'sistem', content: systemPrompt},
            {role: 'user', content: mensaje}
        ],
        temperature: 0.3,
        max_tokens: 500,
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