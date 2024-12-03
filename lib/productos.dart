// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductosState createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  List<Map<String, dynamic>> _products = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<_ProductosState> myWidgetKey = GlobalKey();
  bool _isLoading = true;
  String? _selectedCategory;
  List _filteredProducts = [];
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Todos',
    'Ropa',
    'Accesorios',
    'Alimentos',
    'Salud y belleza',
    'Arreglos y regalos',
    'Deportes',
    'Tecnologia',
    'Mascotas',
    'Juegos',
    'Libros',
    'Arte',
    'Otros'
  ];

  final int _pageSize = 8; //Cantidad de productos por petición
  DocumentSnapshot? _lastDocument; //Ultimo documento cargado

  bool _hasMoreProducts =
      true;

  @override

  void initState() {
    super.initState();

    _scrollController.addListener(
        _scrollListener); // al cargar la app se carga el scrollListener
    _loadProducts(isInitialLoad: true); //y se arga la primera petición
  }

  Future<void> _loadProducts({bool isInitialLoad = false}) async {
    //funcion para cargar los productos
    try {
      if (!_hasMoreProducts && !isInitialLoad) {
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference productsCollection =
          firestore.collection('products').doc('vs').collection('vs');
      // Referencia a la colección de productos

      Query query = productsCollection
          .orderBy('fecha', descending: true)
          .limit(_pageSize); // Limitar a _pageSize productos

      if (_lastDocument != null && !isInitialLoad) {
        query = query.startAfterDocument(
            _lastDocument!); // Empezar después del último documento cargado
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _products.addAll(snapshot.docs.map((doc) {
            // Agregar los nuevos productos a la lista existente
            return {
              'name': doc['name'],
              'description': doc['description'],
              'image': doc['image'],
              'price': doc['price'],
              'category': doc['category'],
              'sellerId': doc['sellerId'],
              'sellerName': doc['sellerName'],
              'fecha': doc['fecha'],
              'keywords': doc['keywords'],
            };
          }).toList());
          _lastDocument =
              snapshot.docs.last; // Actualizar el último documento cargado

          if (snapshot.docs.length < _pageSize) {
            //validar si hay mas productos que cargar
            _hasMoreProducts = false;
          }
        });
      } else {
        setState(() {
          _hasMoreProducts = false;
        });
      }
      if (isInitialLoad) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar los productos',
        backgroundColor: Colors.red, // Cambia el color de fondo
        colorText: Colors.white, // Cambia el color del texto
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_selectedCategory == null || _selectedCategory == 'Todos') {
        _loadProducts();
      } else {
        _loadProductsByCategory(_selectedCategory!);
      }
    }
  }

  void _searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        Get.snackbar('Error', 'Por favor, introduce una consulta',
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final searchLower = query.toLowerCase().split(' ');
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference productsCollection =
            firestore.collection('products').doc('vs').collection('vs');

        Query querySnapshot = productsCollection
            .where('keywords', arrayContainsAny: searchLower)
            .orderBy('name');

        QuerySnapshot snapshot = await querySnapshot.get();

        setState(() {
          _products = [];
          _selectedCategory = null;
        });
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _products = snapshot.docs.map((doc) {
              return {
                'name': doc['name'],
                'description': doc['description'],
                'image': doc['image'],
                'price': doc['price'],
                'category': doc['category'],
                'sellerId': doc['sellerId'],
                'sellerName': doc['sellerName'],
                'fecha': doc['fecha'],
                'keywords': doc['keywords'],
              };
            }).toList();
          });
        } else {
          setState(() {
            _products = [];
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.snackbar('Error', 'No se pudo buscar productos');
    }
  }

  void _filterByCategory(String? category) async {
    setState(() {
      _selectedCategory = category;
      _filteredProducts = [];
      _hasMoreProducts = true; // Reiniciar la variable de más productos
      _lastDocument = null; // Reiniciar el último documento cargado
    });

    if (category == 'Todos' || category == null) {
      _products = [];
      _loadProducts(isInitialLoad: true);
    } else {
      await _loadProductsByCategory(category);
    }
  }

  Future<void> _loadProductsByCategory(String category) async {
    if (!_hasMoreProducts && _filteredProducts.isNotEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection =
        firestore.collection('products').doc('vs').collection('vs');

    Query query = productsCollection
        .where('category', isEqualTo: category)
        .orderBy('fecha', descending: true)
        .limit(_pageSize);

    if (_lastDocument != null && _filteredProducts.isNotEmpty) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _filteredProducts.addAll(snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'description': doc['description'],
            'image': doc['image'],
            'price': doc['price'],
            'category': doc['category'],
            'sellerId': doc['sellerId'],
            'sellerName': doc['sellerName'],
            'fecha': doc['fecha'],
            'keywords': doc['keywords'],
          };
        }).toList());

        _lastDocument = snapshot.docs.last;

        if (snapshot.docs.length < _pageSize) {
          _hasMoreProducts = false;
        }
      });
    } else {
      setState(() {
        _hasMoreProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Stack(
              children: [
                // Texto con borde amarillo (sin color interior)
                Text(
                  '      Pumarket',
                  style: TextStyle(
                    fontFamily: 'Coolvetica',
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = const Color.fromARGB(255, 255, 211, 0),
                  ),
                ),
                const Text(
                  '      Pumarket',
                  style: TextStyle(
                    fontFamily: 'Coolvetica',
                    fontWeight: FontWeight.w400,
                    fontSize: 48,
                    color: Color.fromARGB(254, 33, 46, 127),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // Desplazamiento de la sombra
                        blurRadius: 3.0, // Difuminado
                        color: Colors.black54, // Sombra negra con opacidad
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller:
                _scrollController, // Controlador del scroll, NO ESTOY SEGURO DE PORQUE DEBE IR AQUI Y NO EN EL GRIDVIEW BUILDER PERO VA ACA (NO TOCAR)
            slivers: [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(0, 33, 46, 127),
                elevation: 0.0,
                expandedHeight: 145.0, // Tamaño total del "SliverAppBar"
                pinned: false, // Mantener el AppBar fijo
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                    child: Container(
                      color: const Color.fromARGB(
                          255, 33, 46, 127), // Color del "AppBar"
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          // Barra de búsqueda
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 22, 11, 11),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 211, 0),
                                width: 2.0, // Detalle en amarillo
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 211, 0),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Buscar producto...',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(
                                      255, 255, 211, 0), // Letra amarilla
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color.fromARGB(255, 255, 211, 0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 20),
                              ),
                              onSubmitted: (value) {
                                _searchProducts(value);
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                String category = _categories[index];
                                IconData icon;

                                // Asignar íconos dependiendo de la categoría
                                switch (category) {
                                  case 'Ropa':
                                    icon = Icons.shopping_bag;
                                    break;
                                  case 'Accesorios':
                                    icon = Icons.watch;
                                    break;
                                  case 'Alimentos':
                                    icon = Icons.fastfood;
                                    break;
                                  case 'Salud y belleza':
                                    icon = Icons.favorite;
                                    break;
                                  case 'Arreglos y regalos':
                                    icon = Icons.cake;
                                    break;
                                  case 'Deportes':
                                    icon = Icons.sports_soccer;
                                    break;
                                  case 'Tecnologia':
                                    icon = Icons.devices;
                                    break;
                                  case 'Mascotas':
                                    icon = Icons.pets;
                                    break;
                                  case 'Juegos':
                                    icon = Icons.videogame_asset;
                                    break;
                                  case 'Libros':
                                    icon = Icons.book;
                                    break;
                                  case 'Arte':
                                    icon = Icons.palette;
                                    break;
                                  case 'Otros':
                                    icon = Icons.category;
                                    break;
                                  default:
                                    icon = Icons.all_inclusive;
                                    break;
                                }

                                // Verificar si la categoría actual está seleccionada
                                bool isSelected =
                                    _selectedCategoryIndex == index;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryIndex =
                                            index; // Actualiza la categoría seleccionada
                                        _selectedCategory = category;
                                      });
                                      _filterByCategory(
                                          category); // Filtrar productos
                                    },
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255, 255, 211, 0)
                                                : Colors
                                                    .transparent, // Fondo amarillo para categoría seleccionada
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            icon,
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255, 33, 46, 127)
                                                : const Color.fromARGB(
                                                    255, 255, 211, 0),
                                          ),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 211, 0),
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          child: Text(category),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildEmptyState(),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isLoading && _products.isEmpty) {
      // Mostrar un círculo de carga cuando esté cargando y no haya productos
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 240.0,
        color: Colors.transparent,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (!_isLoading && _products.isEmpty) {
      // Mostrar el mensaje de "No se encontraron productos" cuando no esté cargando y la lista esté vacía
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 240.0,
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'No se encontraron productos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildProductGrid() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 240.0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const ClampingScrollPhysics(), // Permitir scroll dentro del GridView
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 8, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 8, // Espacio vertical entre tarjetas
          childAspectRatio: 2 / 3, // Relación de aspecto de las tarjetas
        ),
        itemCount: _selectedCategory == null || _selectedCategory == 'Todos'
            ? _products.length
            : _filteredProducts.length,
        itemBuilder: (context, index) {
          final product =
              _selectedCategory == null || _selectedCategory == 'Todos'
                  ? _products[index]
                  : _filteredProducts[index];

          return GestureDetector(
            onTap: () {
              // Implementa la acción que deseas al tocar una tarjeta
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto
                  if (product['image'] != null && product['image'].isNotEmpty)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del producto
                        Text(
                          product['name'] ?? 'Sin nombre',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Descripción del producto
                        Text(
                          product['description'] ?? 'Sin descripción',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Precio del producto
                        Text(
                          '\$${product['price'].toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
