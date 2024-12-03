import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pumarket_admin/add_anuncio_screen.dart';
import 'package:pumarket_admin/add_detail.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  // Lista para almacenar los anuncios
  List<Map<String, dynamic>> anunciosList = [];

  @override
  void initState() {
    super.initState();
    _loadAdds();
  }

  Widget buildAdds() {
    // Si la lista de anuncios está vacía, devolver un Container vacío
    if (anunciosList.isEmpty) {
      return Container(); // O puedes devolver un Widget que indique que no hay anuncios
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Evita el scroll dentro del GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10, // Espacio entre las columnas
        mainAxisSpacing: 10, // Espacio entre las filas
        childAspectRatio: 2 / 3, // Ajusta la relación de aspecto (más alto)
      ),
      itemCount: anunciosList.length,
      itemBuilder: (context, index) {
        var anuncio = anunciosList[index];
        return Card(
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDetails(
                    nombre: anuncio['titulo'],
                    descripcion: anuncio['descripcion'],
                    imagen: anuncio['image'],
                    yt: anuncio['yt'],
                    ws: anuncio['ws'],
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar la imagen del anuncio expandida al máximo
                if (anuncio['image'] != null && anuncio['image'].isNotEmpty)
                  SizedBox(
                    height:
                        150, // Ajusta esta altura para hacer la imagen más larga
                    width:
                        double.infinity, // Expandir a todo el ancho disponible
                    child: Image.network(
                      anuncio['image'],
                      fit: BoxFit.cover,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del anuncio
                      Text(
                        anuncio['titulo'] ?? 'Sin título',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Descripción del anuncio, mostrando "..." si es muy larga
                      Text(
                        anuncio['descripcion']?.isNotEmpty == true
                            ? anuncio['descripcion']!
                            : '...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadAdds() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference addsCollection = firestore.collection('anuncios');

      QuerySnapshot snapshot = await addsCollection.get();
      anunciosList.clear();
      List<Map<String, dynamic>> tempList = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String descripcion = data['descripcion'] ?? '';
        String image = data['image'] ?? '';
        String titulo = data['titulo'] ?? '';
        String yt = data['yt'] ?? '';
        String ws = data['ws'] ?? '';

        // Agregar a la lista temporal
        tempList.add({
          'descripcion': descripcion,
          'image': image,
          'titulo': titulo,
          'yt': yt,
          'ws': ws,
        });
      }

      // Actualizar la lista de anuncios y notificar a los widgets que se reconstruyan
      setState(() {
        anunciosList.addAll(tempList);
      });
    } catch (e) {
      if (e is FirebaseException) {
        // Manejo de errores de Firestore
        Get.snackbar(
          'Error de Firestore',
          e.message ?? 'Error desconocido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        // Manejo de errores genéricos
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuncios'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAnuncioScreen()),
            );
          },
        ),
      ),
      body: anunciosList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: anunciosList.length,
              itemBuilder: (context, index) {
                final anuncio = anunciosList[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: anuncio['image'].isNotEmpty
                        ? Image.network(anuncio['image'])
                        : const Icon(Icons.image,
                            size: 50), // Mostrar un ícono si no hay imagen
                    title: Text(anuncio['titulo']),
                    subtitle: Text(anuncio['descripcion']),
                    onTap: () {
                      // Puedes manejar el tap para abrir detalles, enlaces de YouTube o WhatsApp
                      if (anuncio['yt'].isNotEmpty) {
                        // Navegar al video de YouTube
                      }
                      if (anuncio['ws'].isNotEmpty) {
                        // Abrir enlace de WhatsApp
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
