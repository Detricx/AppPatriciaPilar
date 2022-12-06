import 'package:drh_project/controllers/locale_provider.dart';
import 'package:drh_project/l10n/l10n.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final locale = provider.locale;

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
          visible: true && explicacao == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: locale,
              icon: Container(width: 12),
              items: L10n.all.map((locale) {
                final flag = L10n.getFlag(locale.languageCode);
                return DropdownMenuItem(
                  value: locale,
                  child: Center(
                    child: Text(
                      flag,
                      style: const TextStyle(
                        fontSize: 32
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (locale){
                final provider = Provider.of<LocaleProvider>(context, listen: false);
                provider.setLocale(locale as Locale);
              },
            ),
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