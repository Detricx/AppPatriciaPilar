import 'package:drh_project/models/descontos.dart';

class Parceria {

  final int? id;
  final String? logo;
  final bool estado;
  final String nome;
  final String morada;
  final List contacto;
  final dynamic destinatario;
  final dynamic tipoServico;
  final dynamic categoria;
  final List<DescontoParceria?> descontos;
  
  Parceria(
    this.id,
    this.logo, 
    this.estado, 
    this.nome, 
    this.morada,
    this.contacto,
    this.destinatario,
    this.tipoServico, 
    this.categoria,
    this.descontos,
  );

  //Converter o resultado dos descontos em String para ser enviado para o php
  String convertDescontosToString(List<DescontoParceria?> descontos){
    List<String> texto = [];

    for(int i = 0; i < descontos.length; i++){
      texto.addAll(['[__ ${descontos[i]?.descricao};; ${descontos[i]?.detalhe};; ${descontos[i]?.desconto};; ${descontos[i]?.tipo} __]']);
      texto.add(';;;');
    }
    return texto.toString();
  }
}