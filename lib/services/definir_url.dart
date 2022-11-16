import 'package:drh_project/services/globals.dart' as globals;

Uri definirUriGET(String caminho, {dynamic campo1, dynamic campo2, dynamic campo3, dynamic campo4, dynamic campo5}){
  return Uri(
    scheme: 'http',
    host: globals.ip,
    path: '/projects/flutter/drh_project/$caminho',
    queryParameters: {'ctb': globals.nif, 'campo1': campo1, 'campo2': campo2, 'campo3': campo3, 'campo4':campo4, 'campo5': campo5}
  );
}