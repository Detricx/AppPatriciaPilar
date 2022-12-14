import 'dart:convert';

import 'package:drh_project/models/recibo_irs.dart';
import 'package:drh_project/screens/Utilizador/Documents/irs/irs.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Classe que servirá para converter dados para "DataGridSource"
class DocsFuncionarioIRS extends DataGridSource{
  final String nifEmpresa;
  final List lista; //Esta lista pode ser tanto um erro como uma listagem de documentos (Ps: A listagem de erro só coloquei por ser um campo obrigatório)
  DocsFuncionarioIRS(this.nifEmpresa, {required this.lista});

  @override
  List<DataGridRow> get rows => lista
    .map<DataGridRow>((dataRow) => DataGridRow(
    cells: [
      DataGridCell<String>(columnName: 'Ano', value: dataRow[1]),
      DataGridCell<String>(columnName: 'doc', value: dataRow[1]),
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
                    //!Colocar aqui os valores do documento selecionado
                    DeclaracaoIRS documento = await getDataFromDocument(dataCell.value) as DeclaracaoIRS;

                    // ignore: use_build_context_synchronously
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context){
                          return IrsScreen(recibo: documento, nifEmpresa: nifEmpresa);
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
  Future<Object> getDataFromDocument(String ano) async{
    
    Uri url = definirUriGET('rv/irs_data.php', campo1: ano);
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);

    //Retornou uma lista de recibos
    switch (data.statusCode){
      case 200:
        DeclaracaoIRS documento = DeclaracaoIRS(
          resposta["empresa"][0],                                     //empresaNome
          resposta["empresa"][1],                                     //empresaMorada
          ('${resposta["empresa"][2]} ${resposta["empresa"][3]}'),    //empresaCodPostal
          resposta["empresa"][4],                                     //empresaContribuinte

          resposta["funcionario"][0],   //funcionarioNome
          resposta["funcionario"][1],   //funcionarioMorada
          resposta["funcionario"][2],   //funcionariocodPostal
          resposta["funcionario"][3],   //funcionarioContribuinte
          resposta["funcionario"][4],   //funcionarioNumero

          ano,                        //ano
          resposta["dados"][2],       //rendimentoAno
          resposta["dados"][3],       //rendimentoAnosAnteriores
          resposta["dados"][4],       //totalRendimentos
          resposta["dados"][5],       //impostoRendimento
          resposta["dados"][6],       //sobretaxaIRS
          resposta["dados"][7],       //segurancaSocial
          resposta["dados"][8],       //totalDescontos
          resposta["dados"][9]        //quotizacaoSindicais
        );

      return documento;

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