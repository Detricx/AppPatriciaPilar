import 'dart:convert';

import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/tabelas/tabela_recibo_venc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReciboVencimentoMenuScreen extends StatefulWidget {
  final String nifEmpresa;
  const ReciboVencimentoMenuScreen({ Key? key, required this.nifEmpresa }) : super(key: key);
  
  @override
  State<ReciboVencimentoMenuScreen> createState() => _ReciboVencimentoMenuScreenState();
}

class _ReciboVencimentoMenuScreenState extends State<ReciboVencimentoMenuScreen> {
  
  //Mais tarde será onde irei colocar toda a data convertida em formato "DataGridSorce"
  late DataGridSource _docsFuncionario;
  
  //HTTP variáveis
  late List recibos, erro;

  //Design
  var tipoColuna = ColumnWidthMode.fill;
  double linhasporPagina = 12.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_docs.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    const double dataPagerHeight = 80;
    var t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FutureBuilder(
            future: getDocuments(t.localeName, widget.nifEmpresa),
            builder: (context, snapshot) {
              if(!snapshot.hasData){
                return Center(
                  child: SpinKitCircle(
                    size: 140,
                    duration: const Duration(seconds: 3),
                    itemBuilder: (context, index){
                      final colors = [Colors.white, Colors.brown];
                      final color = colors[index % colors.length];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        )
                      );
                    },
                  )
                );
              }
              else{
                if(snapshot.data == true){
                  return LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraint) {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: constraint.maxHeight - dataPagerHeight,
                            width: constraint.maxWidth,
                            child: _colunas()
                          ),
                          Container(
                            height: dataPagerHeight,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                              border: Border(
                                top: BorderSide(
                                  width: 0,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)
                                )
                              )
                            ),
                            child: Align(
                              child: SfDataPager(
                                visibleItemsCount: 3,
                                initialPageIndex: 1,
                                availableRowsPerPage: const [12],
        
                                delegate: _docsFuncionario,
                                pageCount: (_docsFuncionario.rows.length / linhasporPagina).roundToDouble()
                              ),
                            )
                          )
                        ],
                      );
                    }
                  );
                }
                else{
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          t.errPHP25, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'DaysOne',
                            fontSize: 32,
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            }
          ),
        )
      ],
    );
  }

  Widget _colunas(){
    return SfDataGrid(
      //A data que quero incorporar aí dentro
      source: _docsFuncionario,
      horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
      //Deverá coincindir com o número de campos de dados armazenados
      columns: [
        GridColumn(
          columnName: 'mes',
          columnWidthMode: tipoColuna,
          autoFitPadding: EdgeInsets.zero,
          
          label: Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Mês',
                style: TextStyle(
                  fontFamily: 'Gantari',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
              ),
            )
          )
        ),
        GridColumn(
          columnName: 'doc',
          columnWidthMode: tipoColuna,
          label: Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Documento',
                style: TextStyle(
                  fontFamily: 'Gantari',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
              ),
            )
          )
        ),
      ],
    );
  }
  
  //Sacar ID's e recibos que o Utilizador tenha
  Future<bool> getDocuments(String lingua, String nifEmpresa) async{
    Uri url = definirUriGET('rv/recibos.php', campo1: (lingua == 'pt') ? 'pt-pt' : 'en-us');
    http.Response data = await http.get(url);
    
    switch(data.statusCode){
      case 200:
        recibos = jsonDecode(data.body)["recibos"];
        _docsFuncionario = DocsFuncionarioRV(lista: recibos, nifEmpresa: nifEmpresa);
      return true;
      
      case 204:
      return false;

      default:
        erro = [jsonDecode(data.body)["type"], jsonDecode(data.body)["message"]];
      return false;
    }
  }
}