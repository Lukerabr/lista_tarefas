import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];

  _salvarArquivo() async {

    final diretorio = (await getApplicationDocumentsDirectory()).path;
    var arquivo = File("$diretorio/dados.json");

    //Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = "ir ao mercado";
    tarefa["realizada"] = false;
    _listaTarefas.add(tarefa);

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
    //print("Caminho: " + diretorio.path);

  }

  @override
  Widget build(BuildContext context) {

    _salvarArquivo();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){
          
          showDialog(
              context: context,
              builder: (context){

                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar")
                    ),
                    FlatButton(
                        onPressed: (){

                          Navigator.pop(context);
                        },
                        child: Text("Salvar")
                    )
                  ],
                );

              }
          );
          
        },
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder:(context, index){
                  return ListTile(
                    title: Text(_listaTarefas[index]),
                  );
                } ,
              )
          )
        ],
      ),
    );
  }
}
