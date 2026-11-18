ALTER TABLE public."Pedidos"
    ALTER COLUMN "Usuario_Cc" DROP NOT NULL,
    ALTER COLUMN "Celular" DROP NOT NULL;

CREATE OR REPLACE FUNCTION public.eliminar_cuenta_usuario_anonimizando_pedidos(
    p_usuario_id text
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_cedula text;
BEGIN
    SELECT usuario.cedula::text
    INTO v_cedula
    FROM public.usuarios AS usuario
    WHERE usuario.id::text = p_usuario_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN false;
    END IF;

    IF v_cedula IS NOT NULL THEN
        UPDATE public."Pedidos"
        SET
            "Usuario_Cc" = NULL,
            "Nombre_Contacto" = 'Cliente eliminado',
            "Celular" = NULL
        WHERE "Usuario_Cc"::text = v_cedula;
    END IF;

    DELETE FROM public.carrito
    WHERE usuario_id::text = p_usuario_id;

    DELETE FROM public.favoritos
    WHERE usuario_id::text = p_usuario_id;

    DELETE FROM public.direcciones
    WHERE usuario_id::text = p_usuario_id;

    DELETE FROM public.recovery_code
    WHERE "Usuario_Id"::text = p_usuario_id;

    DELETE FROM public.mensaje_chat
    WHERE usuario_id::text = p_usuario_id;

    DELETE FROM public.usuarios
    WHERE id::text = p_usuario_id;

    RETURN FOUND;
END;
$$;

REVOKE ALL ON FUNCTION public.eliminar_cuenta_usuario_anonimizando_pedidos(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.eliminar_cuenta_usuario_anonimizando_pedidos(text) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.eliminar_cuenta_usuario_anonimizando_pedidos(text) TO service_role;
