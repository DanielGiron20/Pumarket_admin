import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AddDetails extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imagen;
  final String yt;
  final String ws;

  const AddDetails({
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.yt,
    required this.ws,
    super.key,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detalles del Producto',
      home: Scaffold(
        appBar: AppBar(
          title: Text(nombre),
          backgroundColor: const Color.fromARGB(255, 33, 46, 127),
          foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              Center(
                child: Image.network(
                  imagen,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Nombre del producto
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Descripción del producto
              Text(
                descripcion,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Iconos de YouTube y WhatsApp con separador
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (yt.isNotEmpty)
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.youtube,
                        color: Colors.red,
                      ),
                      iconSize: 40,
                      onPressed: () => _launchUrl(yt),
                    ),
                  if (yt.isNotEmpty && ws.isNotEmpty)
                    const SizedBox(width: 20), // Separador entre los iconos
                  if (ws.isNotEmpty)
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                      ),
                      iconSize: 40,
                      onPressed: () => _launchUrl(ws),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
