import 'dart:convert';

import 'package:drh_project/models/recibo_vencimento.dart';
import 'package:drh_project/models/rv_desconto.dart';
import 'package:drh_project/models/rv_renumeracao.dart';
import 'package:drh_project/screens/Utilizador/Documents/rv/recibo_vencimento.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Classe que servirá para converter dados para "DataGridSource"
class DocsFuncionarioRV extends DataGridSource{
  final String nifEmpresa;
  final List lista; //Esta lista pode ser tanto um erro como uma listagem de documentos (Ps: A listagem de erro só coloquei por ser um campo obrigatório)
  DocsFuncionarioRV({required this.lista, required this.nifEmpresa});

  @override
  List<DataGridRow> get rows => lista
    .map<DataGridRow>((dataRow) => DataGridRow(
    cells: [
      DataGridCell<String>(columnName: 'Mês', value: dataRow[1]),
      DataGridCell<String>(columnName: 'doc', value: dataRow[2]),
    ]
  )).toList();
    
  //Irá retornar o formato em como o texto dos dados será exposto
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>(
        (dataCell){
           return Container(
            alignment: Alignment.center,
            child: dataCell.columnName == 'doc' ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return ElevatedButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.brown[800]
                  ),
                  onPressed: () async{
                    ReciboVenc documento = await getDataFromDocument(dataCell.value) as ReciboVenc;

                    // ignore: use_build_context_synchronously
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context){
                          //! MANDAR JUNTO O CAMINHO DA FOTO DA EMPRESA
                          return ReciboVencimentoScreen(recibo: documento, nifEmpresa: nifEmpresa);
                        }
                      )
                    );
                  },
                  child: const Icon(
                    Icons.preview,
                    size: 30,
                  )
                );
              }
            ) 
            : Text(dataCell.value.toString()
            )
          );
        }
      ).toList()
    );
  }

  //Sacar a data toda a cerca do documento clicado
  Future<Object> getDataFromDocument(dynamic tempo) async{
    
    Uri url = definirUriGET('rv/recibo_data.php', campo1: tempo.replaceAll('.', '-'));
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);
    
    //Retornou uma lista de recibos
    switch (data.statusCode){
      case 200:
        List<Renumeracao> renumeracaos = [];
        List<Desconto> descontos = [];

        //renumeracaoDescricao
        for(int i = 0; i <= resposta["renumeracoes"].length - 1; i++){
          String renumeracaoDescricao = resposta["renumeracoes"][i][0];
          String? ervu = resposta["renumeracoes"][i][1];
          String ere = resposta["renumeracoes"][i][2];
          String? rqtt = resposta["renumeracoes"][i][3];
          
          Renumeracao renumeracao = Renumeracao(renumeracaoDescricao, ervu, rqtt, ere);
          renumeracaos.add(renumeracao);
        }
        
        //descontoDescricao
        for(int i = 0; i <= resposta["descontos"].length - 1; i++){
          String descontoDescricao = resposta["descontos"][i][0];
          String? edvu = resposta["descontos"][i][1];
          String ede = resposta["descontos"][i][2];
          String? dqtt = resposta["descontos"][i][3];
          Desconto desconto = Desconto(descontoDescricao, edvu, dqtt, ede);
          descontos.add(desconto);
        }

        ReciboVenc recibo = ReciboVenc(
        resposta["empresa"][0], //empresaNome
        resposta["empresa"][1], //empresaMorada
        resposta["empresa"][4], //empresaCodPostal
        ('${resposta["empresa"][3]} - ${resposta["empresa"][5]}'), //empresaLocalizacao
        resposta["empresa"][2], //empresaContribuinte
        resposta["dados"][0], //funcionarioNome 
        resposta["dados"][15], //funcionarioSeguro
        resposta["dados"][17], //funcionarioApolice 
        resposta["dados"][5], //funcionarioNumero 
        resposta["dados"][10], //funcionarioCustoAnalitico
        resposta["dados"][6], //funcionarioContribuinte
        resposta["dados"][7], //funcionarioBeneficiario

        (resposta["dados"][14]),  //funcionarioCategoria

        resposta["dados"][12], //funcionarioVB
        resposta["dados"][11], //funcionarioValorHora
        resposta["dados"][4], //funcionarioDias
        resposta["dados"][16], //funcionarioNIB
        resposta["dados"][8], //valorTotalSujeito
        resposta["dados"][9], //valorTotalNaoSujeito
        resposta["dados"][13], //valorTotalDescontos
        resposta["dados"][3], //valorTotalLiquidoReceber
        renumeracaos,
        descontos,
        resposta["dados"][2], //data
        resposta["dados"][1], //númeroRecibo
      );
      return recibo;

      //Deve atualizar o token
      case 202:
      return[];

      //Não retornou erro, mas o Utilizador tmb n tem nenhum recibo associado
      case 300:
      return[];

      //Retornou um erro inesperado
      default:
      return [resposta["type"], resposta["message"]];
    }
  }
}