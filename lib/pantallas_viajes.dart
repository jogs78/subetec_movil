import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'servicio_conexion.dart';
import 'historico.dart';
import 'perfil.dart';

// ==========================================
// CONTENEDOR PRINCIPAL DE LAS 4 PESTAÑAS
// ==========================================
class PantallaPrincipalContenedora extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaPrincipalContenedora({
    Key? key, 
    required this.idUsuario, 
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<PantallaPrincipalContenedora> createState() => _PantallaPrincipalContenedoraState();
}

class _PantallaPrincipalContenedoraState extends State<PantallaPrincipalContenedora> {
  int _indiceActual = 1; // Inicia por defecto en la pestaña Conductor
  late List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      const PantallaHistorico(),  // Índice 0: Historial
      PantallaConductor(
        idUsuario: widget.idUsuario, 
        nombreUsuario: widget.nombreUsuario
      ),                          // Índice 1: Formulario Conductor
      const Center(child: Text('Pantalla Pasajero (Próximamente)')), // Índice 2: Pasajero
      const PantallaPerfil(),     // Índice 3: Mi Perfil
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

// ==========================================
// VISTA DEL FORMULARIO DEL CONDUCTOR
// ==========================================
class PantallaConductor extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaConductor({
    Key? key, 
    required this.idUsuario, 
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  _PantallaConductorState createState() => _PantallaConductorState();
}

class _PantallaConductorState extends State<PantallaConductor> {
  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController placasController = TextEditingController();
  
  String _asientosSeleccionados = '3 asientos vacíos';
  bool _cargando = false;

  Future<void> publicarViaje() async {
    if (origenController.text.isEmpty || destinoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena los campos obligatorios.')),
      );
      return;
    }

    setState(() => _cargando = true);
    MySQLConnection? conn;

    try {
      conn = await ServicioConexion.conectar();

      var resultado = await conn.execute(
        "INSERT INTO viajes (origen, destino, marca, modelo, color, placas, conductor, asientos_disponibles) "
        "VALUES (:origen, :destino, :marca, :modelo, :color, :placas, :conductor, :asientos)",
        {
          "origen": origenController.text,
          "destino": destinoController.text,
          "marca": marcaController.text,
          "modelo": modeloController.text,
          "color": colorController.text,
          "placas": placasController.text,
          "conductor": widget.idUsuario,
          "asientos": _asientosSeleccionados,
        },
      );

      if (resultado.affectedRows > BigInt.zero) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Viaje publicado con éxito en MySQL!'),
            backgroundColor: Colors.green,
          ),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar en MySQL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (conn != null) await conn.close();
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _limpiarFormulario() {
    origenController.clear();
    destinoController.clear();
    marcaController.clear();
    modeloController.clear();
    colorController.clear();
    placasController.clear();
    setState(() {
      _asientosSeleccionados = '3 asientos vacíos';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con saludo dinámico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${widget.nombreUsuario}!', 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                      Text('SubeTec • TecNM / ITTG', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.notifications_none, size: 28), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Registrar nueva ruta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Inputs con diseño OutlineInputBorder original
              TextField(
                controller: origenController,
                decoration: const InputDecoration(labelText: 'Punto de Origen', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: destinoController,
                decoration: const InputDecoration(labelText: 'Destino Final', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: marcaController,
                      decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: modeloController,
                      decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: placasController,
                      decoration: const InputDecoration(labelText: 'Placas', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Selector Dropdown original
              DropdownButtonFormField<String>(
                value: _asientosSeleccionados,
                decoration: const InputDecoration(labelText: 'Asientos libres para pasajeros', border: OutlineInputBorder()),
                items: ['1 asiento vacío', '2 asientos vacíos', '3 asientos vacíos', '4 asientos vacíos']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _asientosSeleccionados = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                '⚠️ Recordatorio: Tu lugar como conductor ya está ocupado de forma implícita. Indica únicamente los asientos vacíos disponibles.',
                style: TextStyle(color: Colors.orange[800], fontSize: 12),
              ),
              const SizedBox(height: 25),

              // Botón naranja de acción ovalado
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE25213),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _cargando ? null : publicarViaje,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publicar Oferta de Viaje', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}