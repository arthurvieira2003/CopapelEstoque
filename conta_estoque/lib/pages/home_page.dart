import 'package:firebase_auth/firebase_auth.dart';
import 'package:conta_estoque/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _launchSuccess = false;

  bool _isButtonEnabled = false;

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
    final description = _descriptionController.text;

    try {
      await FirebaseFirestore.instance.collection('launches').add({
        'code': code,
        'description': description,
        'position': position,
        'quantity': quantity,
        'user': user?.email,
      });

      _codeController.clear();
      _positionController.clear();
      _quantityController.clear();
      _descriptionController.clear();

      setState(() {
        _launchSuccess = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _launchSuccess = false;
        });
      });

      setState(() {
        _isButtonEnabled = false;
      });
    } catch (e) {
      print('Erro ao fazer lançamento: $e');
    }
  }

  void _updateButtonEnabledState() {
    setState(() {
      _isButtonEnabled = _codeController.text.isNotEmpty &&
          _positionController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty;
    });
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
                      fontSize: 20,
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
                  if (code.isEmpty) {
                    _descriptionController.clear();
                  } else {
                    _fetchProductDescription(code);
                  }
                  _updateButtonEnabledState();
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                readOnly: true,
                maxLines: null,
                style: const TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Vaga'),
                style: const TextStyle(fontSize: 16),
                onChanged: (_) => _updateButtonEnabledState(),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                style: const TextStyle(fontSize: 16),
                onChanged: (_) => _updateButtonEnabledState(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _submitLaunch : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Lançar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Visibility(
                visible: _launchSuccess,
                child: const Text(
                  'Lançamento realizado com sucesso!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: signOut,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(fontSize: 16),
                ),
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
