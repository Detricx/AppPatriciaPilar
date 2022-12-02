import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DetailsPage extends StatelessWidget{

  final File documento;
  final String? caminho;
  final String extensao;
  final int index;
  const DetailsPage({Key? key, required this.documento, required this.index, required this.extensao, this.caminho}) : super(key: key);
  
  final bool condicao = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(227, 255, 255, 255),
      body: extensao == '.pdf' 
      ?
      //!Para o caso de ser um PDF
      Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Stack(
          children: <Widget>[
            caminho!.substring(0, 4) != 'http' ?
            SfPdfViewer.file(
              File(documento.path),
            )
            :
            SfPdfViewer.network(
              documento.path,
            ),
            
            FutureBuilder(
              future: Future<dynamic>.delayed(const Duration(seconds: 5)).then((dynamic value) {return;}),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done){
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
                }
                else{
                  return Container();
                }
              },
            ),
      
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              child: FloatingActionButton(
                heroTag: null,  
                backgroundColor: Colors.brown[800],
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }
              )
            )
          ],
        ),
      )

      :
      //!Para o caso de ser uma imagem
      Stack(
        children: <Widget>[
          InteractiveViewer(
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'logo$index',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(documento),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: FloatingActionButton(
              heroTag: null,  
              backgroundColor: Colors.brown[800],
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: (){
                Navigator.of(context).pop();
              }
            )
          )
        ],
      ),
    );
  }
}