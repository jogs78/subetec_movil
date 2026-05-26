import 'package:flutter/material.dart';
import 'consultas.dart';

class PantallaHistorico extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario; // Requerido para personalizar el AppBar

  const PantallaHistorico({Key? key, required this.idUsuario, required this.nombreUsuario}) : super(key: key);

  @override
  State<PantallaHistorico> createState() => _PantallaHistoricoState();
}

class _PantallaHistoricoState extends State<PantallaHistorico> {
  
  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial: ${widget.nombreUsuario}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text('No tienes viajes publicados ni reservaciones activas.', style: TextStyle(color: Colors.grey)),
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

              final String rol = viaje['rol'] ?? 'Conductor';
              final bool esConductor = rol == 'Conductor';

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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: esConductor ? Colors.blue[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rol,
                              style: TextStyle(color: esConductor ? Colors.blue[800] : Colors.green[800], fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      Text('📍 Origen: ${viaje['origen']}', style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 6),
                      Text('🏁 Destino: ${viaje['destino']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      if (!esConductor) ...[
                        const SizedBox(height: 6),
                        Text('👤 Conductor: ${viaje['nombre_conductor'] ?? ''}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
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