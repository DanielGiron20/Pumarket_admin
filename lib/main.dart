import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pumarket_admin/anuncios.dart';
import 'package:pumarket_admin/productos.dart';
import 'package:pumarket_admin/usuarios_reportados.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que Flutter esté inicializado
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const AdminApp()); // Ejecuta la aplicación
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const DashboardScreen(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardBlock(
              title: 'Reportes',
              icon: Icons.report,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsuariosReportados(),
                      ),
                    );
                  },
                  child: const Text('Usuarios Reportados'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DashboardBlock(
              title: 'Productos',
              icon: Icons.shopping_bag,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Productos(),
                      ),
                    );
                  },
                  child: const Text('Ver Productos'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DashboardBlock(
              title: 'Anuncios',
              icon: Icons.announcement,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Anuncios()));
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
  final IconData icon;
  final List<Widget> actions;

  const DashboardBlock({
    super.key,
    required this.title,
    required this.icon,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
