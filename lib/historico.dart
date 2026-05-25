import 'package:flutter/material.dart';
import 'consultas.dart';

class PantallaHistorico extends StatefulWidget {
  final int idUsuario;

  const PantallaHistorico({Key? key, required this.idUsuario}) : super(key: key);

  @override
  State<PantallaHistorico> createState() => _PantallaHistoricoState();
}

class _PantallaHistoricoState extends State<PantallaHistorico> {
  
  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Viajes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, String?>>>(
        future: ServicioConsultas.obtenerHistorialViajes(widget.idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: azulInstitucional));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos desde consultas'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No has publicado ningún viaje aún.', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final viajes = snapshot.data!;
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                                child: Text('#${viaje['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Text(fecha, style: const TextStyle(color: azulInstitucional, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${viaje['asientos_disponibles']} disp.'),
                            ],
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      Text('📍 Origen: ${viaje['origen']}', style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 6),
                      Text('🏁 Destino: ${viaje['destino']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const Divider(height: 24),
                      Text('Vehículo: ${viaje['marca'] ?? ''} ${viaje['modelo'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 13))
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}