import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
      padding: const EdgeInsets.only(
        top: 60,
        left: 40,
        right: 40,
      ),
      color: Colors.green,
      child: ListView(
        children: <Widget>[
          SizedBox(
            width: 128,
            height: 128,
            child: Image.asset("images/copapel.jpeg"),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: "Nome",
              labelStyle: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            style: const TextStyle(
              fontSize: 20
              ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Senha",
              labelStyle: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            style: const TextStyle(fontSize: 20),
          ),
          Container(
            height: 40,
            alignment: Alignment.centerRight,
            child: FlatButton(
              child: Text(
                "Recuperar Senha",
                textAlign: TextAlign.right,
              ),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}