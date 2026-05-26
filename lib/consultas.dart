import 'package:flutter/foundation.dart'; // Define debugPrint sin cargar todo Material
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
        "SELECT v.id, v.conductor, v.origen, v.destino, v.salida, v.asientos_disponibles, "
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
      debugPrint("Error en ServicioConsultas (buscarViajes): $e");
    } finally {
      if (conn != null) await conn.close();
    }

    return viajesEncontrados;
  }

  /// Registra la reservación real en la tabla pivote y descuenta el asiento
  static Future<bool> reservarViaje({required int idPasajero, required int idViaje}) async {
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();

      // 1. Insertamos en la tabla pivote 'usuario_viaje'
      await conn.execute(
        "INSERT INTO usuario_viaje (usuario_id, viaje_id, created_at, updated_at) "
        "VALUES (:usuarioId, :viajeId, NOW(), NOW())",
        {
          "usuarioId": idPasajero,
          "viajeId": idViaje,
        },
      );

      // 2. Descontamos el asiento disponible de la tabla viajes
      await conn.execute(
        "UPDATE viajes SET asientos_disponibles = asientos_disponibles - 1 WHERE id = :viajeId",
        {
          "viajeId": idViaje,
        },
      );

      return true; 
    } catch (e) {
      debugPrint("Error en ServicioConsultas (reservarViaje): $e");
      return false; 
    } finally {
      if (conn != null) await conn.close();
    }
  }

  /// Consulta para el historial mixto: Trae viajes creados (Conductor) o reservados (Pasajero)
  static Future<List<Map<String, String?>>> obtenerHistorialViajes(int idUsuario) async {
    List<Map<String, String?>> listaViajes = [];
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();
      
      var resultado = await conn.execute(
        "SELECT v.id, v.origen, v.destino, v.salida, v.asientos_disponibles, v.marca, v.modelo, "
        "u.nombre AS nombre_conductor, 'Conductor' AS rol "
        "FROM viajes v "
        "JOIN usuarios u ON v.conductor = u.id "
        "WHERE v.conductor = :usuarioId "
        
        "UNION "
        
        "SELECT v.id, v.origen, v.destino, v.salida, v.asientos_disponibles, v.marca, v.modelo, "
        "u.nombre AS nombre_conductor, 'Pasajero' AS rol "
        "FROM viajes v "
        "JOIN usuario_viaje uv ON v.id = uv.viaje_id "
        "JOIN usuarios u ON v.conductor = u.id "
        "WHERE uv.usuario_id = :usuarioId "
        
        "ORDER BY salida DESC",
        {"usuarioId": idUsuario},
      );

      for (var fila in resultado.rows) {
        listaViajes.add(fila.assoc());
      }
    } catch (e) {
      debugPrint("Error en ServicioConsultas (obtenerHistorialMixto): $e");
    } finally {
      if (conn != null) await conn.close();
    }
    
    return listaViajes;
  }

  /// CONSULTA DE ANUNCIOS: Soporta filtrado opcional por categoría desde el Feed de Inicio
  static Future<List<Map<String, dynamic>>> obtenerAnuncios({String categoria = ''}) async {
    List<Map<String, dynamic>> listaAnuncios = [];
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();
      
      IResultSet resultado;
      if (categoria.isNotEmpty) {
        resultado = await conn.execute(
          "SELECT id, imagen, titulo, descripcion, oferta, precio, categoria FROM anuncios WHERE categoria = :categoria ORDER BY id DESC",
          {"categoria": categoria}
        );
      } else {
        resultado = await conn.execute(
          "SELECT id, imagen, titulo, descripcion, oferta, precio, categoria FROM anuncios ORDER BY id DESC"
        );
      }

      for (var fila in resultado.rows) {
        listaAnuncios.add(Map<String, dynamic>.from(fila.assoc()));
      }
    } catch (e) {
      debugPrint("Error en ServicioConsultas (obtenerAnuncios): $e");
    } finally {
      if (conn != null) await conn.close();
    }
    
    return listaAnuncios;
  }
}