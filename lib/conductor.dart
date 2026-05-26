import 'package:flutter/material.dart';
import 'inicio.dart'; 
import 'historico.dart';
import 'pasajero.dart';
import 'perfil.dart'; // Importa tu archivo de perfil externo
import 'conexion.dart'; 

class PantallaConductor extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaConductor({
    Key? key, 
    required this.idUsuario, 
    required this.nombreUsuario
  }) : super(key: key);

  @override
  State<PantallaConductor> createState() => _PantallaConductorState();
}

class _PantallaConductorState extends State<PantallaConductor> {
  int _indiceActual = 0; // Inicia en la Pantalla de Inicio

  final _formKey = GlobalKey<FormState>();
  
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placasController = TextEditingController();
  final _colorController = TextEditingController();
  final _salidaTextoController = TextEditingController();
  final _llegadaTextoController = TextEditingController();

  DateTime? _fechaHoraSalida;
  DateTime? _fechaHoraLlegada;
  int _asientosSeleccionados = 3;

  String _formatearFechaHora(DateTime dt) {
    String anio = dt.year.toString();
    String mes = dt.month.toString().padLeft(2, '0');
    String dia = dt.day.toString().padLeft(2, '0');
    String hora = dt.hour.toString().padLeft(2, '0');
    String minuto = dt.minute.toString().padLeft(2, '0');
    return '$anio-$mes-$dia $hora:$minuto';
  }

  Future<void> _seleccionarFechaHora(BuildContext context, bool esSalida) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    if (fecha == null) return;

    if (!mounted) return;

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    final DateTime fechaHoraCombinada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);

    setState(() {
      if (esSalida) {
        _fechaHoraSalida = fechaHoraCombinada;
        _salidaTextoController.text = _formatearFechaHora(fechaHoraCombinada);
      } else {
        _fechaHoraLlegada = fechaHoraCombinada;
        _llegadaTextoController.text = _formatearFechaHora(fechaHoraCombinada);
      }
    });
  }

  void _registrarViaje() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaHoraSalida == null || _fechaHoraLlegada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona la fecha y hora de salida y llegada.')),
        );
        return;
      }

      try {
        final conn = await ServicioConexion.conectar();

        await conn.execute(
          "INSERT INTO viajes (conductor, marca, modelo, color, placas, asientos_disponibles, origen, destino, salida, llegada) "
          "VALUES (:conductor, :marca, :modelo, :color, :placas, :asientos_disponibles, :origen, :destino, :salida, :llegada)",
          {
            "conductor": widget.idUsuario,
            "marca": _marcaController.text,
            "modelo": _modeloController.text,
            "color": _colorController.text,
            "placas": _placasController.text,
            "asientos_disponibles": _asientosSeleccionados,
            "origen": _origenController.text,
            "destino": _destinoController.text,
            "salida": _formatearFechaHora(_fechaHoraSalida!), 
            "llegada": _formatearFechaHora(_fechaHoraLlegada!),
          },
        );

        await conn.close();

        _origenController.clear();
        _destinoController.clear();
        _marcaController.clear();
        _modeloController.clear();
        _placasController.clear();
        _colorController.clear();
        _salidaTextoController.clear();
        _llegadaTextoController.clear();
        _fechaHoraSalida = null;
        _fechaHoraLlegada = null;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Viaje publicado e insertado en MySQL con éxito!'), backgroundColor: Colors.green),
        );

        // Mueve al índice 1 (Historial) tras guardar exitosamente
        setState(() {
          _indiceActual = 1;
        });

      } catch (e) {
        debugPrint("Error al insertar viaje: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _construirPantallaFormulario() {
    const Color azulInstitucional = Color(0xFF1565C0);
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicar Viaje: ${widget.nombreUsuario}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Datos de la Ruta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azulInstitucional)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _origenController,
              decoration: const InputDecoration(labelText: 'Origen', prefixIcon: Icon(Icons.location_on, color: azulInstitucional)),
              validator: (v) => v!.isEmpty ? 'Introduce el origen' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _destinoController,
              decoration: const InputDecoration(labelText: 'Destino', prefixIcon: Icon(Icons.flag, color: azulInstitucional)),
              validator: (v) => v!.isEmpty ? 'Introduce el destino' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salidaTextoController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Fecha/Hora Salida', prefixIcon: Icon(Icons.calendar_today, color: azulInstitucional)),
                    onTap: () => _seleccionarFechaHora(context, true),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _llegadaTextoController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Fecha/Hora Llegada', prefixIcon: Icon(Icons.calendar_today, color: azulInstitucional)),
                    onTap: () => _seleccionarFechaHora(context, false),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Datos del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azulInstitucional)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(labelText: 'Marca'),
                    validator: (v) => v!.isEmpty ? 'Escribe la marca' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    validator: (v) => v!.isEmpty ? 'Escribe el modelo' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _placasController,
                    decoration: const InputDecoration(labelText: 'Placas'),
                    validator: (v) => v!.isEmpty ? 'Introduce las placas' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Color'),
                    validator: (v) => v!.isEmpty ? 'Introduce el color' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _asientosSeleccionados,
                    decoration: const InputDecoration(labelText: 'Asientos Disponibles'),
                    items: [1, 2, 3, 4, 5].map((int valor) {
                      return DropdownMenuItem<int>(value: valor, child: Text('$valor lugares'));
                    }).toList(),
                    onChanged: (nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() => _asientosSeleccionados = nuevoValor);
                      }
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: azulInstitucional, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Dar de Alta Viaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _registrarViaje,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Las 5 pantallas alineadas con parámetros correctos
    final List<Widget> pantallas = [
      PantallaInicio(idUsuario: widget.idUsuario, nombreUsuario: widget.nombreUsuario), 
      PantallaHistorico(idUsuario: widget.idUsuario, nombreUsuario: widget.nombreUsuario), 
      _construirPantallaFormulario(), 
      PantallaPasajero(idUsuario: widget.idUsuario, nombreUsuario: widget.nombreUsuario), 
      PantallaPerfil(idUsuario: widget.idUsuario, nombreUsuario: widget.nombreUsuario),     
    ];

    return Scaffold(
      body: pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (indice) => setState(() => _indiceActual = indice),
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.drive_eta), label: 'Conductor'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin_circle), label: 'Pasajero'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}