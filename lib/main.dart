import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Essa classe é o widget raiz do aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 103, 58, 183)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Conversor de Moedas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State <MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _apiData = 0;
  String dataRetorno = '';
  Map <String, String> _currencies = {};
  String moedaSelecionadaBase = '';
  String moedaSelecionadaDestino = '';
  final _amountController = TextEditingController();

  /*Aqui Inicializa o estado do widget.*/
  @override
  void initState() {
    super.initState();
    fetchCurrencies();
    fetchData();
  }

  /*
  Esse método realiza faz a chamada para a API  responsável por fazer a conversão e guarda o resultado*/

  Future <void> fetchData() async {
    if (moedaSelecionadaBase.isEmpty || moedaSelecionadaDestino.isEmpty) {
      return;
    }

    String amount = _amountController.text.isNotEmpty ? _amountController.text : '1';
    final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?amount=$amount&from=$moedaSelecionadaBase&to=$moedaSelecionadaDestino'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _apiData = jsonData['rates'][moedaSelecionadaDestino];
        dataRetorno = jsonData['date'];
      });
    } else {
      print(
          'Erro ao carregar dados: ${response.statusCode} ${response.request.toString()}');
    }
  }

  /*Esse método retorna as moedas possíveis de serem convertidas e definem o valor inicial das variáveis
  moedaSelecionadaBase e moedaSelecionadaDestino*/ 

  Future <void> fetchCurrencies() async {
    final response = await http.get(Uri.parse('https://api.frankfurter.app/currencies'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        _currencies = jsonData.map((key, value) => MapEntry(key, value.toString()));
        moedaSelecionadaBase = _currencies.keys.first;
        moedaSelecionadaDestino = _currencies.keys.first;
      });
    } else {
      print('Erro ao carregar dados: ${response.statusCode}');
    }
  }

  /*Esse método constrói e estiliza a tela principal do aplicativo.
  Ele mostra um campo para digitar a quantidade a ser convertida, opções para escolher as moedas, e mostra o resultado da conversão.*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: const Color.fromARGB(255, 179, 169, 196),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300.0,
              child: TextField(
                onChanged: (newValue) {
                setState(() {
                  fetchData();
                });},
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(.0),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 215, 209, 219),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Selecione uma moeda de origem:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton <String>(
              value: moedaSelecionadaBase,
              onChanged: (newValue) {
                setState(() {
                  moedaSelecionadaBase = newValue!;
                  fetchData();
                });
              },
              items: _currencies.entries.map((entry) {
                String currencyCode = entry.key;
                String currencyName = entry.value;
                return DropdownMenuItem<String>(
                  value: currencyCode,
                  child: Text(
                    currencyName,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                );
              }).toList(),
              hint: const Text(
                'Selecione uma moeda de destino',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(
                Icons.currency_exchange,
                color: Colors.deepPurple,
              ),
              underline: Container(
                height: 2,
                color: const Color.fromARGB(255, 103, 58, 183),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Selecione uma moeda de destino:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton <String>(
              value: moedaSelecionadaDestino,
              onChanged: (newValue) {
                setState(() {
                  moedaSelecionadaDestino = newValue!;
                  fetchData();
                });
              },
              items: _currencies.entries.map((entry) {
                String currencyCode = entry.key;
                String currencyName = entry.value;
                return DropdownMenuItem<String>(
                  value: currencyCode,
                  child: Text(
                    currencyName,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 103, 58, 183),
                    ),
                  ),
                );
              }).toList(),
              hint: const Text(
                'Selecione uma moeda de destino',
                style: TextStyle(
                  color: Color.fromARGB(255, 158, 158, 158),
                ),
              ),
              dropdownColor: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(
                // Ícone do dropdown
                Icons.currency_exchange,
                color: Color.fromARGB(255, 103, 58, 183),
              ),
              underline: Container(
                // Linha sob o dropdown
                height: 2,
                color: const Color.fromARGB(255, 103, 58, 183),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: _apiData != 0 && dataRetorno.isNotEmpty,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10),
                color: const Color.fromARGB(255, 238, 238, 238),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_apiData ${_currencies[moedaSelecionadaDestino]}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(130, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataRetorno,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(130, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
