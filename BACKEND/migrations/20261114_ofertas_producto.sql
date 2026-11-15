alter table public.ofertas
    add column if not exists producto_id bigint
    references public."Productos"(id)
    on delete set null;

create index if not exists ofertas_producto_activo_idx
    on public.ofertas (producto_id)
    where estado = 'Activo';
