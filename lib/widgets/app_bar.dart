import 'package:drh_project/controllers/locale_provider.dart';
import 'package:drh_project/l10n/l10n.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:drh_project/services/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget{
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  final String appBarText;
  final String? explicacao;
  final double tamanho, tamanhoCaixa;
  final bool condicao;

  const CustomAppBar({Key? key, required this.appBarText, required this.tamanho, required this.condicao, required this.tamanhoCaixa, this.explicacao}) : super(key: key);
  
  @override
  State<CustomAppBar> createState() => _CustomAppBar();
}

class _CustomAppBar extends State<CustomAppBar>{

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final locale = provider.locale;
    String titulo = widget.appBarText;

    return AppBar(
      title: Text(
        titulo,
        style: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: widget.tamanho,
          color: Colors.white,
        )
      ),
    
      actions: [
        Visibility( 
          visible: true && widget.explicacao == null && (titulo != 'Calendários' && titulo != 'Calendars') && widget.condicao,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: locale,
              hint: Center(
                child: Text(
                  L10n.getFlag(globals.linguaProjeto),
                  style: const TextStyle(
                    fontSize: 32
                  ),
                ),
              ),
              
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
                changeLanguage(locale);
                globals.linguaProjeto = locale.languageCode;
              },
            ),
          )
        ),
        Visibility(
          visible: !widget.condicao && widget.explicacao != null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: InkWell(
                child: const Icon(
                  Icons.question_mark,
                ),
                onTap: (){
                  showDialog(barrierDismissible: true, context: context, builder: (context){
                    return dialogBox(context, t.explicacao, widget.explicacao!,  widget.tamanhoCaixa, Icons.info);
                  });
                },
              )
            )
          )
        ),
      ],
      elevation: 0,
      centerTitle: true,
      backgroundColor: widget.condicao ? Colors.brown[900] : const Color(0x44000000),
      toolbarHeight: 50
    );
  }
  
  Future<bool> changeLanguage(Locale locale) async{
    try{
      Uri url = definirUriGET("change_language.php", campo1: globals.id, campo2: locale.languageCode);
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request('PUT', url);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      await response.stream.bytesToString();

      return response.statusCode == 200 ? true : false;
    }
    catch(e){
      return false;
    }
  }
}