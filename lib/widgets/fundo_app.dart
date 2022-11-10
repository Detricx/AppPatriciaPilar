// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

Widget fundoApp(String caminho, double top, Widget widget){
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      image: DecorationImage(
        //Serve para o programa compilar para o tamanho correto e fornecer menos processamento do processador
        image: ResizeImage(
          AssetImage(caminho),
          width: 720,
          height: 1256
        ),
        fit: BoxFit.cover,
        alignment: Alignment.center
      )
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(10, top, 10, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          widget
        ]
      )
    )
  );
}