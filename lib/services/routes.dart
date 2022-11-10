import 'package:drh_project/screens/Principal/ajuda.dart';
import 'package:drh_project/screens/Principal/login.dart';
import 'package:drh_project/screens/Utilizador/Documents/menu_docs.dart';
import 'package:drh_project/screens/Utilizador/feed.dart';
import 'package:drh_project/screens/Utilizador/parcerias.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> roteamentoDeTelas(String ctb, String ctbEmpresa, String nome, String nFuncionario){ 
    Map<String, Widget Function(BuildContext)> list = <String, WidgetBuilder>{
      '/login': (context) => const LoginScreen(), //Primeiro tem de ser sempre o (home)
      '/help': (context) => const HelpScreen(),
      '/feed': (context) => FeedScreen(nif: ctb),
      '/parcerias': (context) => ParceriasScreen(ctbEmpresa, nif: ctb, nome: nome, numeroFuncionario: nFuncionario),
      '/docs': (context) => DocsScreen(ctbEmpresa, nif: ctb),
      //home: condicao ? HomeScreen(nif: contribuinte) : const LoginScreen()
    };
    return list;
  }

  static String initial = '/login';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}

// Esta class serve para transitar de um local para o outro através da inicialização do projeto