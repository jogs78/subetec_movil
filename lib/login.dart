import 'package:flutter/material.dart';
import 'pantallas_viajes.dart';
import 'servicio_conexion.dart';

class VistaLoginReal extends StatefulWidget {
  const VistaLoginReal({Key? key}) : super(key: key);

  @override
  State<VistaLoginReal> createState() => _VistaLoginRealState();
}

class _VistaLoginRealState extends State<VistaLoginReal> {
  final TextEditingController _correoController = TextEditingController();
  bool _validando = false;

  Future<void> _iniciarSesion() async {
    final correo = _correoController.text.trim();

    if (correo.isEmpty) {
      _mostrarAlerta('Por favor, ingresa tu correo institucional.');
      return;
    }

    setState(() => _validando = true);
    var conn = await ServicioConexion.conectar();

    try {
      // Consultamos el usuario en base al correo ingresado
      var resultado = await conn.execute(
        "SELECT id, nombre FROM usuarios WHERE correo = :correo LIMIT 1",
        {"correo": correo},
      );

      if (resultado.rows.isNotEmpty) {
        // CORRECCIÓN: Invocamos .assoc() como función con los paréntesis ()
        final usuarioEncontrado = resultado.rows.first.assoc(); 
        
        final int idDb = int.parse(usuarioEncontrado['id']!);
        final String nombreDb = usuarioEncontrado['nombre']!;

        if (!mounted) return;
        
        // Redirigimos al contenedor de las 4 pestañas pasando los datos de la DB
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPrincipalContenedora(
              idUsuario: idDb,
              nombreUsuario: nombreDb,
            ),
          ),
        );
      } else {
        _mostrarAlerta('El correo no está registrado en el sistema SubeTec.');
      }
    } catch (e) {
      _mostrarAlerta('Error de autenticación: $e');
    } finally {
      await conn.close();
      if (mounted) setState(() => _validando = false);
    }
  }

  void _mostrarAlerta(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SubeTec',
                  style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold, color: Color(0xFFE25213)),
                ),
                const SizedBox(height: 5),
                Text('TecNM / ITTG', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 40),
                
                // Campo de texto con el estilo de bordes redondeados (OutlineInputBorder)
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Institucional',
                    hintText: 'ejemplo@tuxtla.tecnm.mx',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 25),
                
                // Botón ovalado naranja
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE25213),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _validando ? null : _iniciarSesion,
                    child: _validando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar Sesión', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}