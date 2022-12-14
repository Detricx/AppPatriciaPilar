import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {

  static Future<bool> isSupported() async{
    //Inicializo uma variável local 
    final LocalAuthentication auth = LocalAuthentication();

    //Verifico se o dispositivo suporta Biometrica
    return await auth.isDeviceSupported();
  }

  static Future<bool> authenticateUser(context) async {
    var t = AppLocalizations.of(context)!;
    
    //Inicializo uma variável local 
    final LocalAuthentication auth = LocalAuthentication();
    
    //Status da autenticação
    bool isAuthenticated = false;
    
    //Verifico se o dispositivo suporta Biometrica
    bool isBiometricSupported = await auth.isDeviceSupported();
    
    //Verifico se ele tem disponibilizado no dispositivo
    bool canCheckBiometrics = await auth.canCheckBiometrics;

    //Se tudo correr certo, avança para aqui
    if (isBiometricSupported && canCheckBiometrics) {
      try {
        isAuthenticated = await auth.authenticate(
          localizedReason: t.impressDig,
          options : const AuthenticationOptions(
            useErrorDialogs: true,      //Verfica se existe algum finger_print registado no dispositivo
            stickyAuth: true,           //Não pede novamente caso feche a aplicação
            sensitiveTransaction: true, //Uma segunda caixa de confirmação a dizer que o registo foi identificado com sucesso
            biometricOnly: true,        //Adiciona o PIN como 2ºvia --> PIN para desbloquer o telemóvel
          ),
        );
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return isAuthenticated;
  }
}