import { supabase } from '../config/supabase.js';

export const obtenerProductos = async () => {
  const { data, error } = await supabase
    .from('Productos')
    .select('*');
  return { data, error };
};

export const obtenerPorCategoria = async (categoria) => {
  const { data, error } = await supabase
    .from('Productos')
    .select('*')
    .eq('Categoria', categoria);
  return { data, error };
};

export const crearProducto = async (productoData) => {
  const { data, error } = await supabase
    .from('Productos')
    .insert([
      {
        Nombre: productoData.Nombre,
        Categoria: productoData.Categoria,
        TipoCalzado: productoData.TipoCalzado,
        Precio: productoData.Precio,
        Stock: productoData.Stock,
        Descripcion: productoData.Descripcion,
        Tallas: productoData.Tallas,
        Colores: productoData.Colores ?? [],
        Imagen: productoData.Imagen,
        Imagenes: productoData.Imagenes ?? [], // todas las fotos
      }
    ])
    .select();
  return { data, error };
};

export const actualizarProducto = async (id, campos) => {
  const camposMapeados = {};
  if (campos.nombre !== undefined) camposMapeados.Nombre = campos.nombre;
  if (campos.precio !== undefined) camposMapeados.Precio = campos.precio;
  if (campos.stock !== undefined) camposMapeados.Stock = campos.stock;
  if (campos.descripcion !== undefined) camposMapeados.Descripcion = campos.descripcion;
  if (campos.tallas !== undefined) camposMapeados.Tallas = campos.tallas;
  if (campos.imagen !== undefined) camposMapeados.Imagen = campos.imagen;
  if (campos.imagenes !== undefined) camposMapeados.Imagenes = campos.imagenes;
  if (campos.colores !== undefined) camposMapeados.Colores = campos.colores;
  if (campos.categoria !== undefined) camposMapeados.Categoria = campos.categoria;
  if (campos.tipoCalzado !== undefined) camposMapeados.TipoCalzado = campos.tipoCalzado;

  const { data, error } = await supabase
    .from('Productos')
    .update(camposMapeados)
    .eq('id', id)
    .select();
  return { data, error };
};

export const eliminarProducto = async (id) => {
  const { data, error } = await supabase
    .from('Productos')
    .delete()
    .eq('id', id)
    .select();
  return { data, error };
};