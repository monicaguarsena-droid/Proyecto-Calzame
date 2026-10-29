alter table public.carrito
    add column if not exists talla text not null default 'Única',
    add column if not exists color text not null default 'Único';
