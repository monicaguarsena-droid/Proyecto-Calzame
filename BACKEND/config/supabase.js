import dotenv from 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("❌ error: la variable de entorno SUPABASE_URL Y SUPABASE_KEY son necesarias para la conexión a Supabase.");
    process.exit(1);
}

export const supabase = createClient(supabaseUrl, supabaseKey);

export const conectaDB =()=>{
    console.log("✅ Conexión a Supabase establecida correctamente.");
}