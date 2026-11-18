CREATE OR REPLACE FUNCTION public.descontar_stock_pedido(p_items jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    v_faltante record;
    v_productos jsonb;
BEGIN
    IF jsonb_typeof(p_items) IS DISTINCT FROM 'array' THEN
        RAISE EXCEPTION 'La lista de productos no es válida';
    END IF;

    IF jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'El pedido no contiene productos';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(p_items) AS item(producto_id bigint, cantidad integer)
        WHERE item.producto_id IS NULL
            OR item.cantidad IS NULL
            OR item.cantidad < 1
    ) THEN
        RAISE EXCEPTION 'El producto y la cantidad deben ser válidos';
    END IF;

    PERFORM producto.id
    FROM public."Productos" AS producto
    JOIN (
        SELECT item.producto_id, SUM(item.cantidad)::integer AS cantidad
        FROM jsonb_to_recordset(p_items) AS item(producto_id bigint, cantidad integer)
        GROUP BY item.producto_id
    ) AS cantidades ON cantidades.producto_id = producto.id
    ORDER BY producto.id
    FOR UPDATE OF producto;

    SELECT
        cantidades.producto_id,
        cantidades.cantidad,
        producto."Nombre" AS nombre,
        producto."Stock" AS stock_disponible
    INTO v_faltante
    FROM (
        SELECT item.producto_id, SUM(item.cantidad)::integer AS cantidad
        FROM jsonb_to_recordset(p_items) AS item(producto_id bigint, cantidad integer)
        GROUP BY item.producto_id
    ) AS cantidades
    LEFT JOIN public."Productos" AS producto
        ON producto.id = cantidades.producto_id
    WHERE producto.id IS NULL
        OR COALESCE(producto."Stock", 0) < cantidades.cantidad
    ORDER BY cantidades.producto_id
    LIMIT 1;

    IF FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'producto_id', v_faltante.producto_id,
            'producto_nombre', COALESCE(v_faltante.nombre, 'Producto'),
            'stock_disponible', COALESCE(v_faltante.stock_disponible, 0),
            'cantidad_solicitada', v_faltante.cantidad
        );
    END IF;

    WITH cantidades AS MATERIALIZED (
        SELECT item.producto_id, SUM(item.cantidad)::integer AS cantidad
        FROM jsonb_to_recordset(p_items) AS item(producto_id bigint, cantidad integer)
        GROUP BY item.producto_id
    ),
    anteriores AS MATERIALIZED (
        SELECT
            producto.id,
            producto."Nombre" AS nombre,
            producto."Stock" AS stock_anterior,
            cantidades.cantidad
        FROM public."Productos" AS producto
        JOIN cantidades ON cantidades.producto_id = producto.id
    ),
    actualizados AS (
        UPDATE public."Productos" AS producto
        SET "Stock" = anteriores.stock_anterior - anteriores.cantidad
        FROM anteriores
        WHERE producto.id = anteriores.id
        RETURNING producto.id, producto."Nombre" AS nombre, producto."Stock" AS stock
    )
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id', actualizados.id,
                'nombre', actualizados.nombre,
                'stockAnterior', anteriores.stock_anterior,
                'stock', actualizados.stock
            )
            ORDER BY actualizados.id
        ),
        '[]'::jsonb
    )
    INTO v_productos
    FROM actualizados
    JOIN anteriores ON anteriores.id = actualizados.id;

    RETURN jsonb_build_object('success', true, 'productos', v_productos);
END;
$$;

REVOKE ALL ON FUNCTION public.descontar_stock_pedido(jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.descontar_stock_pedido(jsonb) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.descontar_stock_pedido(jsonb) TO service_role;
