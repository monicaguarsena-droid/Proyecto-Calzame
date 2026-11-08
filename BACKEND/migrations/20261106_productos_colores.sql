alter table public."Productos"
    add column if not exists "Colores" jsonb not null default '[]'::jsonb;
