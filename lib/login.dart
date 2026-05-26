import 'package:flutter/material.dart';
import 'conductor.dart'; 
import 'conexion.dart';  

class VistaLoginReal extends StatefulWidget {
  const VistaLoginReal({Key? key}) : super(key: key);

  @override
  State<VistaLoginReal> createState() => _VistaLoginRealState();
}

class _VistaLoginRealState extends State<VistaLoginReal> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  bool _cargando = false;

  void _intentarIniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
      });

      String correoDigitado = _correoController.text.trim();

      try {
        final conn = await ServicioConexion.conectar();

        final resultado = await conn.execute(
          "SELECT id, nombre FROM usuarios WHERE correo = :correo LIMIT 1",
          {"correo": correoDigitado},
        );

        await conn.close();

        if (resultado.rows.isNotEmpty) {
          final usuarioEncontrado = resultado.rows.first;
          
          int idReal = int.parse(usuarioEncontrado.assoc()['id']!);
          String nombreReal = usuarioEncontrado.assoc()['nombre']!;

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaConductor(
                idUsuario: idReal,
                nombreUsuario: nombreReal,
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El correo electrónico no se encuentra registrado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error en el login: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión con el servidor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _cargando = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car, size: 64, color: azulInstitucional),
                    const SizedBox(height: 16),
                    const Text(
                      'Sistema de Asistencia Compartida',
                      textAlign: TextAlign.center, // Corregido aquí
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: azulInstitucional),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingrese su identificador de acceso',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico o Usuario',
                        prefixIcon: Icon(Icons.person, color: azulInstitucional),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Por favor introduce tu identificador' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulInstitucional,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _cargando ? null : _intentarIniciarSesion,
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}