import 'package:drh_project/models/recibo_irs.dart';
import 'package:drh_project/screens/Utilizador/Documents/irs/irs.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

//Classe que servirá para converter dados para "DataGridSource"
class DocsFuncionarioIRS extends DataGridSource{
  final String nif, nifEmpresa;
  final List lista; //Esta lista pode ser tanto um erro como uma listagem de documentos (Ps: A listagem de erro só coloquei por ser um campo obrigatório)
  DocsFuncionarioIRS(this.nifEmpresa, {required this.nif, required this.lista});

  @override
  List<DataGridRow> get rows => lista
    .map<DataGridRow>((dataRow) => DataGridRow(
    cells: [
      DataGridCell<String>(columnName: 'Ano', value: dataRow[1]),
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
                    //!Colocar aqui os valores do documento selecionado
                    DeclaracaoIRS documento = DeclaracaoIRS('empresaNome', 'empresaMorada', 'empresaCodPostal', 'empresaContribuinte', 
                    'funcionarioNome', 'funcionarioMorada', 'funcionariocodPostal', 'funcionarioContribuinte', 'funcionarioNumero', 'ano', 
                    'rendimentoAno', 'rendimentoAnosAnteriores', 'totalRendimentos', 'impostoRendimento', 'sobretaxaIRS', 'segurancaSocial', 'totalDescontos', 'quotizacaoSindicais');

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
  Future<Object> getDataFromDocument(String ctb, dynamic tempo) async{
    return [];
  }
}