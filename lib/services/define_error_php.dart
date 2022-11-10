import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<String> definirErroPhp(String titulo, String msg, AppLocalizations t){
  switch(titulo){
    case '1':
    return [t.errPHP1, t.errPHP2];

    case '3':
    return [t.errPHP3, t.errPHP4];

    case '5':
    return [t.errPHP5, t.errPHP5];

    case '7':
    return [t.errPHP7, t.errPHP7];

    case '8':
    return [t.errPHP8, t.errPHP9];

    case '10':
    return [t.errPHP10, t.errPHP11];

    case '12':
    if(msg == '13'){
      return [t.errPHP12, t.errPHP13];
    }
    else{
      return [t.errPHP12, t.errPHP14];
    }

    case '15':
    return [t.errPHP15, t.errPHP16];

    case '17':
    if(msg == '18'){
      return [t.errPHP17, t.errPHP18];
    }
    else{
      return [t.errPHP17, t.errPHP19];
    }

    case '20':
    return [t.errPHP20, t.errPHP21];

    case '22':
    return [t.errPHP22, t.errPHP23];

    case '25':
    return [t.errPHP25, t.errPHP26];

    case '27':
    return [t.errPHP27, t.errPHP28];

    default:
    return [t.errPHP24, t.errPHP23];   
  }
}