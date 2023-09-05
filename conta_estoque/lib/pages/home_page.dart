import 'package:firebase_auth/firebase_auth.dart';
import 'package:conta_estoque/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conta_estoque/pages/product_search_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  String _productImageUrl = '';

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _corredorController = TextEditingController();
  final TextEditingController _colunaController = TextEditingController();
  final TextEditingController _nivelController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _launchSuccess = false;
  bool _isButtonEnabled = false;
  String? _selectedBranch;

  final List<String> _branchOptions = [
    'Selecione a Filial',
    'Joinville Matriz',
    'Joinville Casa Verde',
    'Chapecó',
    'Palhoça',
    'Porto Alegre',
    'SJP',
    'Arapongas',
  ];

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _buscarDescricoes(String code) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(code)
          .get();

      if (snapshot.exists) {
        final productData = snapshot.data() as Map<String, dynamic>;
        final description = productData['description'] as String;
        final imageUrl = productData['imageURL'] as String;

        setState(() {
          _descriptionController.text = description;
          _productImageUrl = imageUrl;
        });
      } else {
        setState(() {
          _descriptionController.text = 'Produto não encontrado';
          _productImageUrl =
              'https://storage.googleapis.com/img-produtos-copapel/copapel-removebg-preview.png';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar descrição do produto: $e');
      }
    }
  }

  Future<void> _submitLaunch() async {
    final code = _codeController.text;
    final corredor = _corredorController.text;
    final coluna = _colunaController.text;
    final nivel = _nivelController.text;
    final quantity = int.parse(_quantityController.text);
    final description = _descriptionController.text;
    final position = '$corredor$coluna.$nivel';

    try {
      final currentTime = DateTime.now();

      await FirebaseFirestore.instance.collection('launches').add({
        'posição': position,
        'código': code,
        'descrição': description,
        'quantidade': quantity,
        'filial': _selectedBranch,
        'usuário': user?.email,
        'hora': currentTime,
      });

      _codeController.clear();
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
      if (kDebugMode) {
        print('Erro ao fazer lançamento: $e');
      }
    }
  }

  void _updateButtonEnabledState() {
    setState(() {
      _isButtonEnabled = _codeController.text.isNotEmpty &&
          _corredorController.text.isNotEmpty &&
          _colunaController.text.isNotEmpty &&
          _nivelController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _selectedBranch != null &&
          _selectedBranch != 'Selecione a Filial';
    });
  }

  FocusNode fieldCorredor = FocusNode();
  FocusNode fieldColuna = FocusNode();
  FocusNode fieldNivel = FocusNode();
  FocusNode fieldCodigo = FocusNode();
  FocusNode fieldQuantidade = FocusNode();

  @override
  void initState() {
    super.initState();

    _productImageUrl =
        'https://storage.googleapis.com/img-produtos-copapel/copapel-removebg-preview.png';
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
            children: <Widget>[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  user?.email ?? 'User email',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(167, 131, 126, 126),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageDetailScreen(imageUrl: _productImageUrl),
                    ),
                  );
                },
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Image.network(
                    _productImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 100,
                        child: TextFormField(
                          focusNode: fieldCorredor,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            UpperCaseTextFormatter(),
                          ],
                          controller: _corredorController,
                          decoration:
                              const InputDecoration(labelText: 'Corredor'),
                          style: const TextStyle(fontSize: 16),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(fieldColuna);
                          },
                          onChanged: (_) => _updateButtonEnabledState(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100,
                        child: TextFormField(
                          focusNode: fieldColuna,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2)
                          ],
                          keyboardType: TextInputType.number,
                          controller: _colunaController,
                          decoration:
                              const InputDecoration(labelText: 'Coluna'),
                          style: const TextStyle(fontSize: 16),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(fieldNivel);
                          },
                          onChanged: (_) => _updateButtonEnabledState(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        child: TextFormField(
                          focusNode: fieldNivel,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1)
                          ],
                          keyboardType: TextInputType.number,
                          controller: _nivelController,
                          decoration: const InputDecoration(labelText: 'Nível'),
                          style: const TextStyle(fontSize: 16),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(fieldCodigo);
                          },
                          onChanged: (_) => _updateButtonEnabledState(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: fieldCodigo,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        UpperCaseTextFormatter(),
                      ],
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: 'Código'),
                      onChanged: (code) {
                        if (code.isEmpty) {
                          _descriptionController.clear();
                        } else {
                          _buscarDescricoes(code);
                        }
                        _updateButtonEnabledState();
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(fieldQuantidade);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final selectedProductCode = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductSearchPage(),
                        ),
                      );
                      if (selectedProductCode != null) {
                        setState(() {
                          _codeController.text = selectedProductCode;
                          _buscarDescricoes(selectedProductCode);
                        });
                      }
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                readOnly: true,
                maxLines: null,
                style: const TextStyle(fontSize: 16),
              ),
              TextFormField(
                focusNode: fieldQuantidade,
                keyboardType: TextInputType.number,
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                style: const TextStyle(fontSize: 16),
                onChanged: (_) => _updateButtonEnabledState(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedBranch,
                hint: const Text('Selecione a Filial'),
                items: _branchOptions.map((String branch) {
                  return DropdownMenuItem<String>(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != 'Selecione a Filial') {
                    setState(() {
                      _selectedBranch = newValue!;
                      _updateButtonEnabledState();
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _submitLaunch : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      _isButtonEnabled ? Colors.green[900] : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Text(
                        'Lançar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        'assets/copapel-removebg-preview.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signOut,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    'Sair',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;

  const ImageDetailScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
