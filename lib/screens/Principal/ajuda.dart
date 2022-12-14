import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';


class HelpScreen extends StatefulWidget {
  const HelpScreen({ Key? key }) : super(key: key);
  
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {

  // Variáveis
  bool error=false, showprogress=false, stayAssign = false, isHiddenPassword = true;
  String email="", password="", errormsg="", explicacao = '';
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(appBarText: 'Atendimento Geral', tamanho: 25, condicao: true, tamanhoCaixa: 300, explicacao: explicacao),
      
      //Fundo
      body: fundoApp(
        'assets/fundos/fundo_parceria.png', 
        60, 
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index){
                        switch (index){
                          case 0:{
                            return infoBox('Notifique o departamento para entrar em contacto consigo');
                          }
                          case 1:{
                            return infoBox('Marque uma hora para se apresentar no DRH para se tentar resolver os problemas');
                          }
                          default:{
                            return infoBox('Envie um email e estabelece uma comunicação virtual');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: const Text(
                    'Desenvolvido pela Devtech©',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white
                    )
                  ),
                  onTap: () {
                    
                  },
                )
              )
            ]
          )
        )
      )
    );

  }
  Widget infoBox(String texto) {

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(barrierDismissible: false, context: context, builder: (context){
              return dialogBox(context, 'PREENCHER', 'TITULO', 400, Icons.warning);
            });
          },
          child:  Container(
            height: 60.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 2,
            ),
            decoration: BoxDecoration( 
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              texto,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black
              )
            ),
          ),
        ),
        const Divider(height: 15.0, color: Colors.transparent)
      ], 
    );
  }
}