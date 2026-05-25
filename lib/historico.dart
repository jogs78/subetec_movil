import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'servicio_conexion.dart';

class PantallaHistorico extends StatefulWidget {
  const PantallaHistorico({Key? key}) : super(key: key);

  @override
  _PantallaHistoricoState createState() => _PantallaHistoricoState();
}

class _PantallaHistoricoState extends State<PantallaHistorico> {
  Future<IResultSet> obtenerHistorial() async {
    MySQLConnection conn = await ServicioConexion.conectar();
    // Cambiado de .query a .execute por compatibilidad
    var resultados = await conn.execute("SELECT * FROM viajes ORDER BY id DESC");
    await conn.close();
    return resultados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<IResultSet>(
        future: obtenerHistorial(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error al cargar el historial o sin datos."));
          }

          var viajes = snapshot.data!.rows;

          if (viajes.isEmpty) {
            return const Center(child: Text("No hay viajes registrados todavía."));
          }

          return ListView.builder(
            itemCount: viajes.length,
            itemBuilder: (context, index) {
              final viaje = viajes.elementAt(index);
              // Se accede a las columnas usando associative (nombre de la columna)
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Color(0xFFE25213)),
                  title: Text("${viaje.assoc()['origen']} ➔ ${viaje.assoc()['destino']}"),
                  subtitle: Text("Vehículo: ${viaje.assoc()['marca']} - Placas: ${viaje.assoc()['placas']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}