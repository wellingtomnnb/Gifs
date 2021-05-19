import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gifs/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=8YsY6iE93io0A2nYpuvMRuTFT9rqwYsi&limit=20&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=8YsY6iE93io0A2nYpuvMRuTFT9rqwYsi&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt");
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: "Pesquise aqui",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder()),
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                onSubmitted: (text){
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                },
              )),
          Expanded(
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5.0),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return _createGifTable(context, snapshot);
                    }
                  }
              ))
        ],
      ),
    );
  }

  int _getCount(List data){
    if(_search == null) return data.length;
    else return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //Quantidade de itens na horizontal
          crossAxisSpacing: 5,//espaçamentento  horizontal entre os itens do grid
          mainAxisSpacing: 5,//espaçamentento  horizontal entre os itens do grid
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if(_search == null || _search.isEmpty || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage, //Faz as imagens carregarem mais suavemente
                  image:
                    ///INFORMA O CAMINHO DO DADO NO ARQUIVO JSON
                    snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                    height: 300.0,
                    fit: BoxFit.cover
              ),
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);

              },
            );
          else return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 70),
                  Text("Carregar mais...",
                  style: TextStyle(color: Colors.white))
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        }
    );
  }

}
