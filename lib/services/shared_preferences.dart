import 'package:shared_preferences/shared_preferences.dart';

class GuardarPreferences {
  
  static late SharedPreferences _preferences;

  static const _keyUser = 'username';

  static Future init() async => _preferences = await SharedPreferences.getInstance();

  //?Guardo as credências para mais tarde serem usadas
  //  static Future setValues(String ctb) async => await _preferences.setString(_keyUser, ctb);

  //?Recolho os dados que ficaram guardados com a chave de acesso
  //  static String? getValues() => _preferences.getString(_keyUser);

  //? Para usar em Listas
  static Future setValues(List<String> utilizador) async => await _preferences.setStringList(_keyUser, utilizador);
  static List<String>? getValues() => _preferences.getStringList(_keyUser);
}