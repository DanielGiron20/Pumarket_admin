import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddAnuncioScreen extends StatefulWidget {
  const AddAnuncioScreen({Key? key}) : super(key: key);

  @override
  _AddAnuncioScreenState createState() => _AddAnuncioScreenState();
}

class _AddAnuncioScreenState extends State<AddAnuncioScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ytController = TextEditingController();
  final _wsController = TextEditingController();
  File? _imagenFile;

  Future<void> _pickImage() async {
  try {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenFile = File(pickedFile.path);
      });
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'No se pudo seleccionar la imagen.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}


  Future<void> _addAnuncio() async {
    if (_tituloController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Título y descripción son obligatorios.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String? imageUrl;
    try {
      if (_imagenFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref('anuncios/${DateTime.now().toIso8601String()}');
        final uploadTask = await storageRef.putFile(_imagenFile!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('anuncios').add({
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'yt': _ytController.text.trim(),
        'ws': _wsController.text.trim(),
        'image': imageUrl ?? '',
      });

      // Resetear campos
      _tituloController.clear();
      _descripcionController.clear();
      _ytController.clear();
      _wsController.clear();
      setState(() => _imagenFile = null);

      Get.snackbar('Éxito', 'Anuncio añadido correctamente.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Error al guardar el anuncio: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Anuncio'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_tituloController, 'Título'),
              const SizedBox(height: 10),
              _buildTextField(_descripcionController, 'Descripción',
                  maxLines: 3),
              const SizedBox(height: 10),
              _buildTextField(_ytController, 'Enlace de YouTube (opcional)'),
              const SizedBox(height: 10),
              _buildTextField(_wsController, 'Enlace de WhatsApp (opcional)'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: _imagenFile == null
                      ? const Center(child: Text('Selecciona una imagen'))
                      : Image.file(_imagenFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAnuncio,
                child: const Text('Añadir Anuncio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
