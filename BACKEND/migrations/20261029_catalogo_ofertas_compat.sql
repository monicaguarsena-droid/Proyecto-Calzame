alter table public.ofertas
    add column if not exists tag text not null default 'OFERTA',
    add column if not exists imagen_url text;

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

    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'ofertas'
          and column_name = 'imagen'
    ) then
        execute 'update public.ofertas set imagen_url = imagen where imagen_url is null and imagen is not null';
    end if;
end
$$;
