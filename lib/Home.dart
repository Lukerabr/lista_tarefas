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
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();


  Future<File> _getFile() async {
    final diretorio = (await getApplicationDocumentsDirectory()).path;
    return File("$diretorio/dados.json");
  }

  _salvarTarefa(){

    String _textoDigitado = _controllerTarefa.text;

    //Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = _textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();

    _controllerTarefa.text = "";

  }

  _salvarArquivo() async {

    var arquivo = await _getFile();


    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
    //print("Caminho: " + diretorio.path);

  }

  _lerArquivo() async {

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }

  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });

  }

  Widget criarItemLista(contex, index){

    final item = _listaTarefas[index]["titulo"];

    return Dismissible(
      //sempre irá gerar uma chave diferente para poder reinserir na lista, o item que foi excluído.
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recuperar o último item excluido para desfazer
          _ultimaTarefaRemovida = _listaTarefas[index];

          //remove item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
            backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
              content: Text("Terefa removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){

                //Inserir novamente na lista
                setState(() {
                  _listaTarefas.insert(index, _ultimaTarefaRemovida);
                });
                _salvarArquivo();

              },
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
            title: Text(_listaTarefas[index]["titulo"]),
            value: _listaTarefas[index]["realizada"],
            onChanged: (valorAlterado){
              setState(() {
                _listaTarefas[index]["realizada"] = valorAlterado;
              });
              _salvarArquivo();
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    _salvarArquivo();

    print("itens: " + DateTime.now().millisecondsSinceEpoch.toString());

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
                    controller: _controllerTarefa,
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
                          _salvarTarefa();
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
                itemBuilder: criarItemLista,
              )
          )
        ],
      ),
    );
  }
}
