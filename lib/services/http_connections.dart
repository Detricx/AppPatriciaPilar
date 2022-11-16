import 'dart:convert';
import 'dart:io';
import 'package:drh_project/models/ausencia.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drh_project/services/globals.dart' as globals;
import 'package:http/http.dart' as http;

class HttpServicesProject{

  static String urlNif = 'http://${globals.ip}/projects/flutter/drh_project/images/app/pessoal/${globals.nif}.jpg';

  //Captura as categorias do feedback
  static Future<List> capturarCategorias(AppLocalizations t) async{
    List categorias = [];
    Uri url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/feedback/feedback_cat.php");
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);

    if(data.statusCode == 200){
      var dados = resposta["data"];
      if(t.localeName == 'pt'){
        for(int i = 0; i <= dados.length - 1; i++){
          String cat = resposta["data"][i][0];
          categorias.add(cat);  
        }
      }
      else{
        for(int i = 0; i <= dados.length - 1; i++){
          String cat = resposta["data"][i][1];
          categorias.add(cat);  
        }
      }
      
      return categorias;
    }
    else{
      return [resposta["type"], resposta["message"]]; 
    }
  }

  //Armazeno o token do dispositivo
  static void saveDataFromDevice(String idDispositivo, bool permissao, AppLocalizations t) async{
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();

    Uri url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/save_serial_number.php");
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', url);
    
    request.bodyFields = {
      "ctb" : globals.nif,
      "serialNumber" : idDispositivo,
      "token" : token ?? '',
      "lingua" : t.localeName,
      "not" : permissao ? '1' : '0',
    };

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    await response.stream.bytesToString();
  }

  //Fazer o update da ementa quando salvar / fechar a aba
  static Future<bool> updateEmenta(DateTime diasMes, List<String> ementa) async{
    String dia = diasMes.toIso8601String();

    Uri url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/rf/update_ementa.php");
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', url);
    
    request.bodyFields = {
      "ctb" : globals.nif,
      "dia" : dia,
      "sopa" : ementa[0],
      "carne" : ementa[1],
      "peixe" : ementa[2],
      "outro" : ementa[3],
    };

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    await response.stream.bytesToString();

    //Retornou a lista da semana atual
    if(response.statusCode == 200){
      return true;
    }
    else{
      return false;
    }
  }

  static Future<bool> storeImageSystem(String titulo, String imagem) async{
    DefaultCacheManager().emptyCache();
    File ficheiro = File(imagem);
    List<int> imageBytes = ficheiro.readAsBytesSync();
    String baseImage = base64Encode(imageBytes);
    
    try{
      var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/recursosHumanos/files/simple_image.php");
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request('POST', url);

      request.bodyFields = {
        "ctb" : globals.nif,
        "imagem" : baseImage,
      };

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      return response.statusCode == 200 ? true : false;
    }
    catch(e){
      return false;
    }
  }

  static Future<bool> deleteImageSystem(String titulo) async{ 
    DefaultCacheManager().emptyCache();
    try{
      var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/recursosHumanos/files/delete_image.php?ctb=${globals.nif}");
      var request = http.Request('DELETE', url);

      http.StreamedResponse response = await request.send();

      return response.statusCode == 200 ? true : false;
    }
    catch(e){
      return false;
    }
  }

  static void armazenarDadosFerias(String periodo, BuildContext context) async{
    var t = AppLocalizations.of(context)!;
    try{
      var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/ausencias/save_ferias.php");

      Map<String, String> data = {
        "ctb" : globals.nif,
        "categoria" : 'Férias',
        "desconto" : 'Férias',
        "data": periodo, 
      };
      
      http.Response response = await http.post(url, body:data);
      Map<String, dynamic> resposta = jsonDecode(response.body);

      if(response.statusCode == 200){
        showDialog(barrierDismissible: true, context: context, builder: (context){
          return dialogBox(context, t.errPHP7, t.feriasAprovacao, 180, Icons.warning);
        }).then((value) => Navigator.pop(context));
      }
      else{
        showDialog(barrierDismissible: true, context: context, builder: (context){
          return dialogBox(context, resposta['type'], resposta['message'], 500, Icons.warning);
        });
      } 
    }
    catch(e){
      showDialog(barrierDismissible: true, context: context, builder: (context){
        return dialogBox(context, t.avisInesperado, 'Detahes: $e',500, Icons.warning);
      });
    }
  }

  static Future<bool> recusaAusencia(Ausencia ausencia, AppLocalizations t, int nivel) async{
    try{
      var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/ausencias/delete_ausencia.php?ctb=${globals.nif}&idAusencia=${ausencia.id}&nivel=$nivel");
      var request = http.Request('DELETE', url);

      http.StreamedResponse response = await request.send();
      await response.stream.bytesToString();
      return response.statusCode == 200 ? true : false;
    }
    catch(e){
      return false;
    }
  }

  static Future<bool> storeFeedbackInDataBase(String nif, String msg, int ranking, String categoria, bool condicao) async{
    try{
      var url = Uri.parse("http://192.168.26.146/projects/flutter/drh_project/feedback/feedback_add.php");
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request('POST', url);
      
      request.bodyFields = {
        "ctb" : nif,
        "campo1" : msg,
        "campo2" : ranking.toString(),
        "campo3": categoria,
        "campo4": condicao ? nif : '',
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      //String resultado = await response.stream.bytesToString();
      //Map<String, dynamic> resposta = jsonDecode(resultado); 

      return response.statusCode == 200 ? true : false;
    }
    catch(e){
      return false;
    }
  }
}