import 'package:drh_project/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier{
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale){
    //Caso ele n encontre a língua n a insere
    if(!L10n.all.contains(locale)) return;
    
    _locale = locale;
    notifyListeners();

    //! TODO Guardar na base de dados a última língua inserida
  }

  void clearLocale(){
    _locale = null;
    notifyListeners();
  }
}