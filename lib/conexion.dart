import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class ServicioConexion {
  static const String _host = '127.0.0.1'; 
  static const int _port = 3306;
  static const String _user = 'subetec';
  static const String _password = 'subetec';
  static const String _database = 'subetec';

  // Abre y retorna el canal de conexión físico
  static Future<MySQLConnection> conectar() async {
    final conn = await MySQLConnection.createConnection(
      host: _host,
      port: _port,
      userName: _user,
      password: _password,
      databaseName: _database,
    );
    
    await conn.connect();
    return conn;
  }
}