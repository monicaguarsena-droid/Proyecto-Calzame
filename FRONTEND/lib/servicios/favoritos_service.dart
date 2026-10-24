class ProductoFavorito {
  final String imagen;
  final String titulo;
  final String subtitulo;
  final String precio;

  ProductoFavorito({
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
  });
}

class FavoritosService {
  // Lista global en memoria para almacenar los favoritos
  static final List<ProductoFavorito> _favoritos = [];

  static List<ProductoFavorito> get favoritos => _favoritos;

  // Verifica si un producto ya está marcado como favorito
  static bool esFavorito(String titulo) {
    return _favoritos.any((prod) => prod.titulo == titulo);
  }

  // Agrega o quita el producto de la lista global
  static void toggleFavorito({
    required String imagen,
    required String titulo,
    required String subtitulo,
    required String precio,
  }) {
    final index = _favoritos.indexWhere((prod) => prod.titulo == titulo);
    if (index >= 0) {
      _favoritos.removeAt(index); // Si ya estaba, lo saca
      print("Producto eliminado. Total en favoritos: ${_favoritos.length}");
    } else {
      _favoritos.add(
        ProductoFavorito(
          imagen: imagen,
          titulo: titulo,
          subtitulo: subtitulo,
          precio: precio,
        ),
      ); // Si no estaba, lo añade
      print("Producto guardado: $titulo. Total en favoritos: ${_favoritos.length}");
    }
  }
}