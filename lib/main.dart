import 'package:drh_project/controllers/locale_provider.dart';
import 'package:drh_project/l10n/l10n.dart';
import 'package:drh_project/services/awesome_notification.dart';
import 'package:flutter/material.dart';
import 'package:drh_project/services/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:drh_project/services/shared_preferences.dart';

//Função que será chamada
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("A segurar a mensagem: ${message.messageId}");
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  .then(
    (value) => runApp(
      //Widget que funciona como base para mudar valores
      ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child){
          final provider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            theme: ThemeData(primaryColor: const Color.fromARGB(255, 209, 209, 209)),
            debugShowCheckedModeBanner: false, //Remover o banner do debug que aparece
        
            //Línguagens suportadas
            supportedLocales: L10n.all,
            
            //Serve para definir localemente a língua do projeto
            locale: provider.locale,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,   //Traduz línguas de vários widgets (Material) no package que vem no flutter
              GlobalCupertinoLocalizations.delegate,  //Traduz línguas de vários widgets (Cupertino) no package que vem no flutter
              GlobalWidgetsLocalizations.delegate,    //_Define a forma de leitura (Esquerda -> Direita ou Direita -> Esquerda)
            ],
        
            routes: Routes.roteamentoDeTelas('', '', '', 'pt'),
            initialRoute: Routes.initial,
            navigatorKey: Routes.navigatorKey,
          );
        },
      )
    )
  );
}
