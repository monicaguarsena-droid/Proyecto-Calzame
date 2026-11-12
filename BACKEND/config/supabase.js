import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
    
  console.error("❌ Error: Las variables de entorno SUPABASE_URL y SUPABASE_KEY son necesarias para la conexión a Supabase.");
  process.exit(1);
}

export const supabase = createClient(supabaseUrl, supabaseKey);

export const conectaDB = async () => {
  try {

    const { error } = await supabase.from('_realtime').select('*').limit(1);
    
    console.log("✅ Conexión a Supabase establecida correctamente.");
  } catch (err) {
    console.error("❌ Error al conectar con Supabase:", err.message);
  }
};