import 'package:flutter/material.dart';
import 'conductor.dart'; 

class VistaLoginReal extends StatefulWidget {
  const VistaLoginReal({Key? key}) : super(key: key);

  @override
  State<VistaLoginReal> createState() => _VistaLoginRealState();
}

class _VistaLoginRealState extends State<VistaLoginReal> {
  final TextEditingController _correoController = TextEditingController();
  bool _cargando = false;

  // Tu lista real de usuarios para simular el inicio de sesión
  final List<Map<String, dynamic>> _usuarios = [
    {'id': 1, 'nombre': 'Jorge Octavio', 'correo': 'jorge'},
    {'id': 2, 'nombre': 'Fulanito Detal', 'correo': 'fulanito'},
    {'id': 3, 'nombre': 'Carlos Eduardo', 'correo': 'carlos'},
    {'id': 4, 'nombre': 'Ana Valeria', 'correo': 'ana'},
    {'id': 5, 'nombre': 'María Fernanda', 'correo': 'maria'},
    {'id': 6, 'nombre': 'Alejandro Ruiz', 'correo': 'alejandro'},
  ];

  void _autenticarUsuario() async {
    String entrada = _correoController.text.trim().toLowerCase();
    if (entrada.isEmpty) return;

    setState(() => _cargando = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _cargando = false);

    // Buscamos si el correo ingresado coincide con alguno de la lista
    final usuarioEncontrado = _usuarios.firstWhere(
      (u) => u['correo'] == entrada || entrada.contains(u['correo']),
      orElse: () => {'id': 1, 'nombre': 'Jorge Octavio'}, // Por defecto si no coincide
    );

    if (!mounted) return;

    // ¡AHORA SÍ ES DINÁMICO! Pasa el ID y Nombre del que inicia sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaConductor(
          idUsuario: usuarioEncontrado['id'],
          nombreUsuario: usuarioEncontrado['nombre'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 90, color: azulInstitucional),
              const SizedBox(height: 16),
              const Text(
                'Subetec',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: azulInstitucional),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'alguien@tuxtla.tecnm.mx',
                  prefixIcon: const Icon(Icons.email, color: azulInstitucional),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulInstitucional,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _cargando ? null : _autenticarUsuario,
                  child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}