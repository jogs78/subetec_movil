import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'servicio_conexion.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({Key? key}) : super(key: key);

  @override
  _PantallaPerfilState createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  Future<Map<String, String>?> obtenerDatosPerfil() async {
    MySQLConnection conn = await ServicioConexion.conectar();
    
    // Cambiado a .execute
    var resultado = await conn.execute("SELECT * FROM usuarios LIMIT 1");
    await conn.close();

    if (resultado.rows.isNotEmpty) {
      var fila = resultado.rows.first.assoc();
      return {
        "nombre": fila['nombre'] ?? 'Usuario',
        "institucion": fila['institucion'] ?? 'TecNM / ITTG',
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, String>?>(
        future: obtenerDatosPerfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          String nombre = snapshot.data?['nombre'] ?? 'Jorge Octavio';
          String inst = snapshot.data?['institucion'] ?? 'SubeTec • TecNM / ITTG';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE25213),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(inst, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}