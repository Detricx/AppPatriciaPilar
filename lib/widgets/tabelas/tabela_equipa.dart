import 'package:drh_project/models/funcionario.dart';
import 'package:drh_project/services/globals.dart' as globals;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

//Classe que servirá para converter dados para "DataGridSource"
class ListagemFuncionarios extends DataGridSource{

  final List<Funcionario> lista;
  ListagemFuncionarios({required this.lista});

  //Organizo o construtor Empleyee de forma que o consiga converter para formato DataGridCell
  @override
  List<DataGridRow> get rows => lista
  .map<DataGridRow>((dataRow){
    return DataGridRow(
    cells: [
      DataGridCell<String>(columnName: 'foto', value: dataRow.nif),
      DataGridCell<String>(columnName: 'Nome', value: dataRow.nome),
    ] 
    );
  }).toList();
  
  //Irá retornar o formato em como o texto dos dados será exposto
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>(
        (dataCell){
          return Container(
            alignment: Alignment.center,
            child: dataCell.columnName == 'foto' ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'http://${globals.ip}/projects/flutter/drh_project/images/app/pessoal/${dataCell.value}.jpg',
                      key: UniqueKey(),
                      fit: BoxFit.cover,
                      width: 200.0,
                      height: 200.0,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null){
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                          ),
                        );
                      },
                      errorBuilder:   (context, url, error){
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage(
                              'assets/icons/error/foto_null.png'
                              ), 
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ); 
              }
            ) 
            : 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                dataCell.value.toString(),
                textAlign: TextAlign.center,
                style: const  TextStyle(
                  fontFamily: 'Gantari',
                  fontSize: 15,
                  overflow: TextOverflow.clip,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 0.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                )
              )
            )
            
          );
        }
      ).toList()
      
    );
  }
}