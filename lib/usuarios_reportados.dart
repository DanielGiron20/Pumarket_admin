import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsuariosReportados extends StatefulWidget {
  const UsuariosReportados({super.key});

  @override
  _UsuariosReportadosState createState() => _UsuariosReportadosState();
}

class _UsuariosReportadosState extends State<UsuariosReportados> {
  // Lista para almacenar los usuarios reportados
  List<Map<String, dynamic>> usuariosList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // Método para cargar los usuarios desde Firestore
  Future<void> loadUsers() async {
    try {
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('sellers')
          .where('reporte', isGreaterThan: 0) // Reportes mayores a 0
          .get();

      List<Map<String, dynamic>> tempList = [];
      for (var doc in userQuery.docs) {
        var data = doc.data() as Map<String, dynamic>;

        tempList.add({
          'name': data['name'] ?? 'Sin nombre',
          'logo': data['logo'] ?? '',
          'descripcion': data['description'] ?? '',
          'titulo': data['title'] ?? 'Sin título',
          'ws': data['ws'] ?? '',
          'instagram': data['instagram'] ?? '',
          'email': data['email'] ?? '',
          'enable': data['enable'] ?? 0,
          'reporte': data['reporte'] ?? 0,
        });
      }

      setState(() {
        usuariosList = tempList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (e is FirebaseException) {
        Get.snackbar(
          'Error de Firestore',
          e.message ?? 'Error desconocido',
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
        title: const Text('Usuarios Reportados'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuariosList.isEmpty
              ? const Center(
                  child: Text(
                    'No hay usuarios reportados.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: usuariosList.length,
                  itemBuilder: (context, index) {
                    final usuario = usuariosList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: usuario['logo'].isNotEmpty
                            ? Image.network(
                                usuario['logo'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50),
                        title: Text(usuario['name']),
                        subtitle: Text(
                          'Reportado ${usuario['reporte']} veces',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          // Acción al tocar un usuario
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// Pantalla de detalles del usuario reportado
class UsuarioDetalles extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const UsuarioDetalles({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(usuario['name']),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (usuario['logo'].isNotEmpty)
              Center(
                child: Image.network(
                  usuario['logo'],
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Nombre: ${usuario['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Descripción: ${usuario['descripcion'] ?? "No disponible"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'WhatsApp: ${usuario['ws'] ?? "No disponible"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Instagram: ${usuario['instagram'] ?? "No disponible"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${usuario['email'] ?? "No disponible"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Reportes: ${usuario['reporte']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
