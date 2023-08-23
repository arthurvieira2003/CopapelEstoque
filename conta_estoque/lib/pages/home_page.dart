import 'package:firebase_auth/firebase_auth.dart';
import 'package:conta_estoque/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _fetchProductDescription(String code) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(code)
          .get();

      if (snapshot.exists) {
        final productData = snapshot.data();
        final description = productData?['description'];

        _descriptionController.text = description;
      } else {
        _descriptionController.text = 'Produto não encontrado';
      }
    } catch (e) {
      print('Erro ao buscar descrição do produto: $e');
    }
  }

  Future<void> _submitLaunch() async {
    final code = _codeController.text;
    final position = _positionController.text;
    final quantity = int.parse(_quantityController.text);

    try {
      await FirebaseFirestore.instance.collection('launches').add({
        'code': code,
        'position': position,
        'quantity': quantity,
        'user': user?.email,
      });

      _codeController.clear();
      _positionController.clear();
      _quantityController.clear();
    } catch (e) {
      print('Erro ao fazer lançamento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 1.0, top: 10),
                  child: Text(
                    user?.email ?? 'User email',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(167, 131, 126, 126),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 10),
                  child: Image.asset('assets/copapel-removebg-preview.png',
                      width: 120, height: 120),
                ),
              ),
              const SizedBox(
                height: 150,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration:
                    const InputDecoration(labelText: 'Código do Produto'),
                onChanged: (code) {
                  _fetchProductDescription(code);
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                readOnly: true,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Vaga'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLaunch,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Remove o padding interno do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text('Lançar'),
              ),
              ElevatedButton(
                onPressed: signOut,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Remove o padding interno do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text('Sair'),
              ),
              const SizedBox(
                height: 110,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
