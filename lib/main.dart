import 'package:flutter/material.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardBlock(
              title: 'Reportes',
              actions: [
                ElevatedButton(
                  onPressed: () {
                   // aca metemos la accion de las rutas 
                  },
                  child: const Text('Usuarios Reportados'),
                ),
              ],
            ),
           const  SizedBox(height: 15), 
            DashboardBlock(
              title: 'Productos',
              actions: [
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: const Text('Buscar Producto'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DashboardBlock(
              title: 'Anuncios',
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Acción para crear anuncio
                  },
                  child: const Text('Crear Anuncio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBlock extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const DashboardBlock({super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
           const SizedBox(height: 15),
            Column(
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
