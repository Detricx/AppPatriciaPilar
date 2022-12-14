import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';

class DefinicoesScreen extends StatefulWidget {
  const DefinicoesScreen({ Key? key }) : super(key: key);
  
  @override
  State<DefinicoesScreen> createState() => _DefinicoesScreenState();
}

class _DefinicoesScreenState extends State<DefinicoesScreen> {

  // Variáveis
  bool error=false, showprogress=false, stayAssign = false, isHiddenPassword = true;
  String email="", password="", errormsg="", explicacao = '';
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(appBarText: 'Definições', tamanho: 25, condicao: true, tamanhoCaixa: 300, explicacao: explicacao),
      
      //Fundo
      body: fundoApp(
        'assets/fundos/inicial.png',
        60,
        Expanded(
          child: Container(

          )
        )
      )
    );
  }
}