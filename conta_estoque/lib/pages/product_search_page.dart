import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allProducts = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        _allProducts = snapshot.docs;
        _filteredProducts = _allProducts;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar produto: $e');
      }
    }
  }

  void _searchProducts() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((doc) {
        final description = doc['description'].toString().toLowerCase();
        final code = doc.id;
        return description.contains(searchText) || code.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Pesquise pela descrição ou código',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _searchProducts,
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final description = product['description'];
                    final code = product.id;

                    return ListTile(
                      title: Text(description),
                      subtitle: Text('Código: $code'),
                      onTap: () {
                        Navigator.pop(context, code);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
