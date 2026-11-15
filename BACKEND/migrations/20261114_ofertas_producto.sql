alter table public.ofertas
    add column if not exists tag text not null default 'OFERTA',
    add column if not exists producto_id bigint
    references public."Productos"(id)
    on delete set null;

do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'ofertas'
          and column_name = 'etiqueta'
    ) then
        execute 'update public.ofertas set tag = etiqueta where etiqueta is not null';
    end if;
end
$$;

create index if not exists ofertas_producto_activo_idx
    on public.ofertas (producto_id)
    where estado = 'Activo';
