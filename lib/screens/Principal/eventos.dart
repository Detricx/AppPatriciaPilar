import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';


class EventoScreen extends StatefulWidget {
  const EventoScreen({ Key? key }) : super(key: key);
  
  @override
  State<EventoScreen> createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  
  @override
  Widget build(BuildContext context) {
    String explicacao = '';

    return Scaffold(
      //Os Widgets que estiverem presentes não serão alterados conforme o teclado
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(appBarText: 'Eventos', tamanho: 25, condicao:true, tamanhoCaixa: 300, explicacao: explicacao),
      //Fundo
      body: fundoApp(
        'assets/fundos/fundo_evento.png',
        60,
        Expanded(
          child: Container(
            
          ),
        )
      ) 
    );
  }
}