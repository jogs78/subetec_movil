import 'package:flutter/material.dart';
import 'pantallas_viajes.dart';
import 'historico.dart';
import 'perfil.dart';
import 'servicio_conexion.dart'; // Importante para validar el correo en MySQL

void main() {
  runApp(const MiAppSubeTec());
}

class MiAppSubeTec extends StatelessWidget {
  const MiAppSubeTec({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubeTec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE25213),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE25213),
          primary: const Color(0xFFE25213),
        ),
        useMaterial3: true,
      ),
      home: const VistaLoginReal(),
    );
  }
}

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
      // Buscamos el usuario en la base de datos por su correo
      var resultado = await conn.execute(
        "SELECT id, nombre FROM usuarios WHERE correo = :correo LIMIT 1",
        {"correo": correo},
      );

      if (resultado.rows.isNotEmpty) {
        final usuarioEncontrado = resultado.rows.first.assoc;
        final int idDb = int.parse(usuarioEncontrado['id']!);
        final String nombreDb = usuarioEncontrado['nombre']!;

        // Login exitoso: Redirigimos pasando el ID y Nombre reales extraídos de MySQL
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
      setState(() => _validando = false);
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

class PantallaPrincipalContenedora extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario; // Recibe el nombre dinámico desde la DB

  const PantallaPrincipalContenedora({
    Key? key, 
    required this.idUsuario, 
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<PantallaPrincipalContenedora> createState() => _PantallaPrincipalContenedoraState();
}

class _PantallaPrincipalContenedoraState extends State<PantallaPrincipalContenedora> {
  int _indiceActual = 1; 
  late List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      const PantallaHistorico(),  
      PantallaConductor(idUsuario: widget.idUsuario, nombreUsuario: widget.nombreUsuario), // Pasamos ambos datos
      const Center(child: Text('Pantalla Pasajero (Próximamente)')), 
      const PantallaPerfil(),     
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int nuevoIndice) {
          setState(() {
            _indiceActual = nuevoIndice;
          });
        },
        selectedItemColor: const Color(0xFFE25213),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Conductor'),
          BottomNavigationBarItem(icon: Icon(Icons.hail), label: 'Pasajero'), 
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi Perfil'),
        ],
      ),
    );
  }
}