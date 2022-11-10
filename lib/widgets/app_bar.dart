import 'package:drh_project/screens/Principal/definicoes.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText; 
  final String? explicacao;
  final double tamanho, tamanhoCaixa;
  final bool condicao;
  const CustomAppBar(this.appBarText, this.tamanho, this.condicao, this.tamanhoCaixa,{Key? key, this.explicacao}) : super(key: key);
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(
        appBarText,
        style: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: tamanho,
          color: Colors.white,
        )
      ),
    
      actions: [
        Visibility(
          visible: false,  //condicao,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: InkWell(
                child: const Icon(
                  Icons.settings,
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DefinicoesScreen()
                    )
                  );
                },
              )
            )
          )
        ),
        Visibility(
          visible: !condicao && explicacao != null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: InkWell(
                child: const Icon(
                  Icons.question_mark,
                ),
                onTap: (){
                  showDialog(barrierDismissible: true, context: context, builder: (context){
                    return dialogBox(context, t.explicacao, explicacao!,  tamanhoCaixa, Icons.info);
                  });
                },
              )
            )
          )
        ),
      ],
      elevation: 0,
      centerTitle: true,
      backgroundColor: condicao ? Colors.brown[900] : const Color(0x44000000),
      toolbarHeight: 50
    );
  }
}