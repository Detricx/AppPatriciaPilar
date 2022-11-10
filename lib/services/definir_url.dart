Uri definirUrl(String caminho, String ctb, {dynamic campo2, dynamic campo3, dynamic campo4, dynamic campo5, dynamic campo6}){
  return Uri(
    scheme: 'http',
    host: '192.168.26.146',
    path: '/projects/flutter/drh_project/$caminho',
    queryParameters: {'ctb': ctb, 'campo1': campo2, 'campo2': campo3, 'campo3': campo4, 'campo4':campo5, 'campo5': campo6}
  );
}