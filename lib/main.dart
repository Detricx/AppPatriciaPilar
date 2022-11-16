import 'package:drh_project/services/awesome_notification.dart';
import 'package:flutter/material.dart';
import 'package:drh_project/services/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:drh_project/services/shared_preferences.dart';

//Função que será chamada 
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("A segurar a mensagem: ${message.messageId}");
}

Future main() async{  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GuardarPreferences.init();
  AwesomeNotificationService.initialize;

  /*?
  bool condicao = (utilizador[1] == 'true') ? true : false;
  //Caso o Utilizador tenha deixado guardar as suas credênciais ele faz refresh ao token
  if(condicao){
    String contribuinte = utilizador[0];
    //Refresh ao token de acesso 
    Uri url = definirUrl('refresh_token.php', contribuinte);
    await http.get(url);
  }
  */

  //Colocar por defeito a orientação na horizontal
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((value) => runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: const Color.fromARGB(255, 209, 209, 209),
      //primarySwatch: Colors.black,
    ),
    //Remover o banner do debug que aparece
    debugShowCheckedModeBanner: false,
    
    //Após ter colocado o código de baixo, coloca-se este para ele começar a usar a língua predefinida
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const[
      //_Define a forma de leitura (Esquerda -> Direita ou Direita -> Esquerda)
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],

    routes: Routes.roteamentoDeTelas('', '', ''),
    initialRoute: Routes.initial,
    navigatorKey: Routes.navigatorKey,
  )));
}