import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'conexion.dart';

class ServicioConsultas {
  
  /// Consulta para el buscador del Pasajero: Filtra destinos con lugares libres
  static Future<List<Map<String, dynamic>>> buscarViajesPorDestino(String destinoBusqueda) async {
    List<Map<String, dynamic>> viajesEncontrados = [];
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();
      
      var resultado = await conn.execute(
        "SELECT v.id, v.origen, v.destino, v.salida, v.asientos_disponibles, "
        "v.marca, v.modelo, u.nombre AS nombre_conductor "
        "FROM viajes v "
        "JOIN usuarios u ON v.conductor = u.id "
        "WHERE v.destino LIKE :destino AND v.asientos_disponibles > 0 "
        "ORDER BY v.salida ASC",
        {"destino": "%$destinoBusqueda%"},
      );

      for (var fila in resultado.rows) {
        viajesEncontrados.add(Map<String, dynamic>.from(fila.assoc()));
      }
    } catch (e) {
      debugPrint("Error en ServicioConsultas (buscarViajes): \$e");
    } finally {
      if (conn != null) await conn.close();
    }

    return viajesEncontrados;
  }

  /// Consulta para el historial del Conductor: Trae rutas creadas por el usuario activo
  static Future<List<Map<String, String?>>> obtenerHistorialViajes(int idUsuario) async {
    List<Map<String, String?>> listaViajes = [];
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();
      
      var resultado = await conn.execute(
        "SELECT id, origen, destino, salida, asientos_disponibles, marca, modelo "
        "FROM viajes WHERE conductor = :conductor ORDER BY id DESC",
        {"conductor": idUsuario},
      );

      for (var fila in resultado.rows) {
        listaViajes.add(fila.assoc());
      }
    } catch (e) {
      debugPrint("Error en ServicioConsultas (obtenerHistorial): \$e");
    } finally {
      if (conn != null) await conn.close();
    }
    
    return listaViajes;
  }
}