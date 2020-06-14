import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//NOTE Link de requisição para a api
const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=110af00c";

void main() async {
  print(await getData());

//Tela inicial
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.green, primaryColor: Colors.white)));
}

//NOTE método de requisição para obtenção dos dados, utilizando um GET
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//NOTE Controladores dos campos de valores
class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

//NOTE método para limpar os campos
  void _clearFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

//NOTE método para fazer os calculos para real, dependendo da moeda selecionada
  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

//NOTE método para fazer os calculos para dolar, dependendo da moeda selecionada
  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

//NOTE método para fazer os calculos para euro, dependendo da moeda selecionada
  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

//NOTE construção da página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("\$ Conversor de moeda \$"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando Dados...",
                style: TextStyle(color: Colors.green, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.green, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.green),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

//Widget de construção  do campo de texto personalizado
Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
      ),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.green, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
