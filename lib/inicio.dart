import 'package:flutter/material.dart';

class PantallaInicio extends StatelessWidget {
  final int idUsuario;
  final String nombreUsuario;

  const PantallaInicio({
    Key? key,
    required this.idUsuario,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color azulInstitucional = Color(0xFF1565C0);

    final List<Map<String, String>> anuncios = [
      {
        'titulo': 'Tacos de Cochito "El Profe"',
        'categoria': 'Comida',
        'precio': 'MX\$12.00',
        'descuento': '32% OFF',
        'tiempo': '15 Min',
        'imagen': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&auto=format&fit=crop&q=60',
      },
      {
        'titulo': 'Hospedaje Universitario Chiapa',
        'categoria': 'Hospedaje',
        'precio': 'MX\$350 / noche',
        'descuento': 'Hasta 15% dto.',
        'tiempo': 'A 5 min del Tec',
        'imagen': 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=500&auto=format&fit=crop&q=60',
      },
      {
        'titulo': 'Pizzería La Squadra - Grande de Queso',
        'categoria': 'Comida',
        'precio': 'MX\$87.30',
        'descuento': 'Precio Especial',
        'tiempo': '20 Min',
        'imagen': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60',
      },
      {
        'titulo': 'Copias y Papelería "SubeTec"',
        'categoria': 'Servicios',
        'precio': 'MX\$0.50 c/u',
        'descuento': 'Estudiantes',
        'tiempo': 'Inmediato',
        'imagen': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=500&auto=format&fit=crop&q=60',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Inicio: $nombreUsuario', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulInstitucional,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $nombreUsuario!',
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
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  _botonCategoria(Icons.fastfood, 'Comida', Colors.orange),
                  _botonCategoria(Icons.hotel, 'Hospedaje', Colors.purple),
                  _botonCategoria(Icons.print, 'Impresiones', Colors.teal),
                  _botonCategoria(Icons.local_library, 'Asesorías', Colors.blue),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Anuncios Sugeridos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = anuncios[index % anuncios.length];
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
                              item['imagen']!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover, // Corrección aquí
                              errorBuilder: (context, error, stackTrace) {
                                return Container(height: 160, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 40));
                              },
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                child: Text(item['descuento']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['titulo']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['precio']!, style: const TextStyle(fontSize: 15, color: azulInstitucional, fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(item['tiempo']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCategoria(IconData icono, String etiqueta, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 24,
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(etiqueta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}