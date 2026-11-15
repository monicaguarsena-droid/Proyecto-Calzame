import 'package:shared_preferences/shared_preferences.dart';

class DatosTienda {
  final String nombre;
  final String direccion;
  final String telefono;
  final String correo;
  final String horario;
  final bool recogidaEnTienda;
  final bool domicilios;

  const DatosTienda({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.correo,
    required this.horario,
    required this.recogidaEnTienda,
    required this.domicilios,
  });

  static const predeterminada = DatosTienda(
    nombre: 'Calzado Mar & Paz',
    direccion: 'Cra. 11 #5-55 Local 3, Garzón, Huila',
    telefono: '',
    correo: '',
    horario: 'Lunes a Sábado: 8:00 AM - 7:00 PM',
    recogidaEnTienda: true,
    domicilios: false,
  );
}

class ConfiguracionTiendaService {
  static const _prefijo = 'config_tienda_';

  static Future<DatosTienda> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final predeterminada = DatosTienda.predeterminada;
    return DatosTienda(
      nombre:
          preferencias.getString('${_prefijo}nombre') ?? predeterminada.nombre,
      direccion:
          preferencias.getString('${_prefijo}direccion') ??
          predeterminada.direccion,
      telefono:
          preferencias.getString('${_prefijo}telefono') ??
          predeterminada.telefono,
      correo:
          preferencias.getString('${_prefijo}correo') ?? predeterminada.correo,
      horario:
          preferencias.getString('${_prefijo}horario') ??
          predeterminada.horario,
      recogidaEnTienda:
          preferencias.getBool('${_prefijo}recogida') ??
          predeterminada.recogidaEnTienda,
      domicilios:
          preferencias.getBool('${_prefijo}domicilios') ??
          predeterminada.domicilios,
    );
  }

  static Future<void> guardar(DatosTienda datos) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('${_prefijo}nombre', datos.nombre);
    await preferencias.setString('${_prefijo}direccion', datos.direccion);
    await preferencias.setString('${_prefijo}telefono', datos.telefono);
    await preferencias.setString('${_prefijo}correo', datos.correo);
    await preferencias.setString('${_prefijo}horario', datos.horario);
    await preferencias.setBool(
      '${_prefijo}recogida',
      datos.recogidaEnTienda,
    );
    await preferencias.setBool('${_prefijo}domicilios', datos.domicilios);
  }
}
