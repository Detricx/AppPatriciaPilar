import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:drh_project/models/noticia.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedScreen extends StatefulWidget {
  final String nif;
  const FeedScreen({ Key? key, required this.nif }) : super(key: key);
  
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<PostNoticia> noticias = [];
  String erro = '', titulo = '';
  int numeroFoto = 0;
  late Future<bool?> dataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_noticia.png'), context);
  }

  @override
  void initState() {
    dataFuture = retornarNoticias(widget.nif);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return fundoApp(
      'assets/fundos/fundo_evento.png',
      10,
      Expanded(
        child: FutureBuilder(
          future: dataFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(
                  child: SpinKitCircle(
                    size: 180,
                    duration: const Duration(seconds: 3),
                    itemBuilder: (context, index){
                      final colors = [Colors.white, Colors.brown];
                      final color = colors[index % colors.length];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        )
                      );
                    },
                  )
                );
              case ConnectionState.done:{
                return displayNoticias();
              }
              default:{
                return Container();
              }
            }
          }
        ),
      )   
    );
  }

  Future<bool?> retornarNoticias(String ctb) async{
    Uri url = definirUrl('recursosHumanos/noticia/noticias.php', ctb);
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);

    //Retornou uma lista de noticias
    if(data.statusCode == 200){
      List noticia = resposta["data"];

      if (!context.mounted){}
      String lingua = AppLocalizations.of(context)!.localeName;
      
      //Recolher os dados todos e coloca-lo numa listagem
      if(lingua == 'pt'){
        //Recolher data em portugês
        for(int i = 0; i < noticia.length; i++){
          int id = noticia[i][0];
          String titulo = noticia[i][1];
          String conteudo = noticia[i][2];
          String data = noticia[i][5];
          List<dynamic> album = noticia[i][6];
          noticias.add(PostNoticia(id, titulo, conteudo, data, album));
        }
      }
      else{
        //Recolher data em english
        for(int i = 0; i < noticia.length; i++){
          int id = noticia[i][0];
          String titulo = noticia[i][3];
          String conteudo = noticia[i][4];
          String data = noticia[i][5];
          List<dynamic> album = noticia[i][6];
          noticias.add(PostNoticia(id, titulo, conteudo, data, album));
        }
      }
      setState(() {});
      return true;
    }

    //Erro no servidor ou sem noticias registadas
    else{
      titulo = resposta["type"];
      erro = resposta["message"];
      return false;
    }
  }
  
  Widget displayNoticias() {
    return Column(
      children: [
        /*//!Selecionar uma data para ir para a notícia
        Expanded(
          flex: 0,
          child: FloatingActionButton.extended(
            herotag: null
            label: const Text('Selecionar Data'),
            onPressed: (){

            }
          )
        ),
        */
        Expanded(
          child: RefreshIndicator(
            onRefresh: swipeup,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: noticias.length,
              itemBuilder: (context, i){
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(195, 255, 255, 255),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        child: Text(
                          noticias[i].titulo,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'DaysOne',
                          ),
                        ),
                      ),
          
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: noticias[i].album.isNotEmpty ?
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: noticias[i].album.length > 1 ?
                                CarouselSlider.builder(
                                  options: CarouselOptions(
                                    height: 180.0,
                                    autoPlay: true,
                                    viewportFraction: 0.7,
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: true,
                                  ),
                                  
                                  itemCount: noticias[i].album.length,
                                  itemBuilder: ((context, index, realIndex) {
                                    return displayImage(noticias[i].album[index]);
                                  }),
                                )
                              :
                              displayImage(noticias[i].album[0])
                            ),
                          ],
                        ) : Container()
                      ),
          
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          noticias[i].conteudo,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Gantari',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }

  Future swipeup() async{
    noticias.clear();
    retornarNoticias(widget.nif);
  }
  
  Widget displayImage(String imagem) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1 ),
      child: CachedNetworkImage(
        //cacheManager: customCacheManager,
        //key: UniqueKey(),
        imageUrl: imagem,
        maxHeightDiskCache: 180,
        maxWidthDiskCache: 300,
        imageBuilder: (context, imageProvider) => Container(
          width: 300.0,
          height: 190.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider, fit: BoxFit.contain
            ),
          ),
        ),
        placeholder: (context, url){
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.grey[400],
              ),
            )
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 100,
            height: 100,
          );
        }
      ),
    );
  }
}