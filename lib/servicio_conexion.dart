import 'package:mysql_client/mysql_client.dart';

class ServicioConexion {
  /// Establece la conexión con el servidor MySQL local de la Mac
  /// manteniendo la contraseña completamente vacía.
  static Future<MySQLConnection> conectar() async {
    final conexion = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'subetec',
      password: 'subetec', // Mantenemos tu configuración nativa vacía
      databaseName: 'subetec',
    );

    // Eliminamos la línea de conexion.config que causaba el error de compilación
    await conexion.connect();
    return conexion;
  }
}