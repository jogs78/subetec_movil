import 'package:flutter/material.dart';
import 'consultas.dart';

class PantallaInicio extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaInicio({
    Key? key,
    required this.idUsuario,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  String categoriaSeleccionada = '';

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Inicio: ${widget.nombreUsuario}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ServicioConsultas.obtenerAnuncios(categoria: categoriaSeleccionada),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: azulInstitucional));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al conectar con la base de datos de anuncios.'));
          }

          final anuncios = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${widget.nombreUsuario}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: azulInstitucional),
                      ),
                      const SizedBox(height: 4),
                      const Text('Descubre los servicios y anuncios de la comunidad', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    children: [
                      _botonCategoria(Icons.all_inclusive, 'Todos', Colors.blueGrey, ''),
                      _botonCategoria(Icons.fastfood, 'Comida', Colors.orange, 'Comida'),
                      _botonCategoria(Icons.hotel, 'Hospedaje', Colors.purple, 'Hospedaje'),
                      _botonCategoria(Icons.print, 'Copias', Colors.teal, 'Copias'),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoriaSeleccionada.isEmpty ? 'Anuncios Sugeridos' : 'Categoría: $categoriaSeleccionada', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      if (categoriaSeleccionada.isNotEmpty)
                        Text('${anuncios.length} resultados', style: const TextStyle(color: Colors.grey, fontSize: 13))
                    ],
                  ),
                ),
              ),

              if (anuncios.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No hay anuncios en esta categoría.', style: TextStyle(color: Colors.grey))),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = anuncios[index % anuncios.length];
                      
                      // Solución definitiva al parseo seguro de tipos numéricos
                      final double precioParseado = double.tryParse(item['precio'].toString()) ?? 0.0;
                      final String precioFormateado = precioParseado.toStringAsFixed(2);
                      final String oferta = item['oferta'] ?? '';
                      
                      final int idAnuncio = int.tryParse(item['id'].toString()) ?? 1;
                      final String tiempoSimulado = idAnuncio % 2 == 0 ? '${10 + idAnuncio} Min' : 'A ${idAnuncio + 2} min del Tec';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Image.network(
                                    item['imagen'] ?? '',
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 160, 
                                        color: Colors.grey[300], 
                                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey)
                                      );
                                    },
                                  ),
                                  if (oferta.isNotEmpty)
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          oferta, 
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['titulo'] ?? 'Anuncio', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['descripcion'] ?? '', 
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'MX\$$precioFormateado', 
                                          style: const TextStyle(fontSize: 16, color: azulInstitucional, fontWeight: FontWeight.bold)
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(tiempoSimulado, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categoriaSeleccionada.isEmpty ? anuncios.length * 3 : anuncios.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _botonCategoria(IconData icono, String etiqueta, Color color, String valorCategoria) {
    final bool esActivo = categoriaSeleccionada == valorCategoria;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSeleccionada = valorCategoria;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: esActivo ? color : color.withOpacity(0.15),
              radius: 24,
              child: Icon(icono, color: esActivo ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: esActivo ? FontWeight.bold : FontWeight.w500,
                color: esActivo ? color : Colors.black87
              )
            ),
          ],
        ),
      ),
    );
  }
}