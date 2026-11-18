ALTER TABLE public."Pedidos"
    ADD COLUMN IF NOT EXISTS "Comprobante_Pago" text;

NOTIFY pgrst, 'reload schema';
