import 'package:flutter/material.dart';
import 'consultas.dart';

class PantallaPasajero extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaPasajero({Key? key, required this.idUsuario, required this.nombreUsuario}) : super(key: key);

  @override
  State<PantallaPasajero> createState() => _PantallaPasajeroState();
}

class _PantallaPasajeroState extends State<PantallaPasajero> {
  final TextEditingController _buscarController = TextEditingController();
  String _criterioBusqueda = "";

  void _reservarAsiento(String idViaje, String conductor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('¡Lugar Apartado!'),
          ],
        ),
        content: Text(
          'Tu asiento ha sido apartado.\n\n'
          '🔑 DATOS PARA LA APP WEB:\n'
          '• ID del Viaje: #$idViaje\n'
          '• Conductor: $conductor\n\n'
          'Utiliza estos datos en la web institucional para visualizar el mapa de la ruta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Viajes disponibles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue[50],
            child: TextField(
              controller: _buscarController,
              decoration: InputDecoration(
                labelText: '¿A qué municipio de Chiapas vas?',
                prefixIcon: const Icon(Icons.search, color: azulInstitucional),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white, // Corrección del atributo a fillColor
              ),
              onChanged: (valor) => setState(() => _criterioBusqueda = valor),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ServicioConsultas.buscarViajesPorDestino(_criterioBusqueda),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: azulInstitucional));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al conectar con la base de datos'));
                }

                final viajes = snapshot.data ?? [];
                if (viajes.isEmpty) {
                  return const Center(child: Text('No hay viajes que coincidan con tu búsqueda.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viajes.length,
                  itemBuilder: (context, index) {
                    final viaje = viajes[index];
                    String fecha = viaje['salida'] ?? 'Sin fecha';
                    if (fecha.length > 16) fecha = fecha.substring(0, 16);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('#${viaje['id']} - $fecha', style: const TextStyle(color: azulInstitucional, fontWeight: FontWeight.bold)),
                                Text('${viaje['asientos_disponibles']} lugares', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            Text('📍 Origen: ${viaje['origen']}'),
                            Text('🏁 Destino: ${viaje['destino']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('🚗 Conductor: ${viaje['nombre_conductor']}'),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: azulInstitucional, foregroundColor: Colors.white),
                                onPressed: () => _reservarAsiento(viaje['id']!, viaje['nombre_conductor']!),
                                child: const Text('Reservar Asiento'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}