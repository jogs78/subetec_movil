import 'package:flutter/material.dart';
import 'login.dart'; // Importamos el login para poder regresar

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({Key? key}) : super(key: key);

  void _cerrarSesion(BuildContext context) {
    // Mostramos un diálogo de confirmación institucional antes de salir
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas salir del sistema SubeTec?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Cierra el diálogo
                
                // Limpia el historial de pantallas y redirige al Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const VistaLoginReal()),
                  (route) => false,
                );
              },
              child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[50],
                child: const Icon(Icons.person, size: 60, color: azulInstitucional),
              ),
              const SizedBox(height: 20),
              const Text(
                'Perfil Universitario', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
              Text(
                'Comunidad TecNM / ITTG', 
                style: TextStyle(color: Colors.grey[600], fontSize: 16)
              ),
              const SizedBox(height: 40),
              
              // Tarjeta visual interactiva para cerrar sesión
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.power_settings_new, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Salir de la cuenta actual de SubeTec'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _cerrarSesion(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}