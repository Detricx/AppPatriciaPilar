// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:drh_project/models/funcionario.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:drh_project/widgets/tabelas/tabela_equipa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class EquipaScreen extends StatefulWidget {
  final bool condicaoAppBar;
  final String nif;
  const EquipaScreen({Key? key, required this.condicaoAppBar, required this.nif}) : super(key: key);

  @override
  State<EquipaScreen> createState() => _EquipaScreenState();
}

class _EquipaScreenState extends State<EquipaScreen > {
  
  //Mais tarde será onde irei colocar toda a data convertida em formato "DataGridSorce"
  late DataGridSource _datafuncionario;


  List<Funcionario> colaboradores = [];

  @override
  void initState() {
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar('Equipa', 25, widget.condicaoAppBar, 220),
      body: fundoApp(
        'assets/fundos/fundo_calendario.png',
        (widget.condicaoAppBar ? 60 : 40),
        Expanded(
          child: FutureBuilder(
            future: descarregaEquipaFuncionarios(widget.nif),
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
                return SfDataGrid(
                horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
                rowHeight: 90,
                //A data que quero incorporar aí dentro
                source: _datafuncionario,
                //Deverá coincindir com o número de campos de dados armazenados
                columns: [
                  GridColumn(
                    columnName: 'foto',
                    columnWidthMode: ColumnWidthMode.fill,
                    autoFitPadding: EdgeInsets.zero,
                    width: 90,
                    label: Container(
                      alignment: Alignment.bottomCenter,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Foto',
                          style: TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                      )
                    )
                  ),
                  GridColumn(
                    columnName: 'nome',
                    columnWidthMode: ColumnWidthMode.fill,
            
                    label: Container(
                      alignment: Alignment.bottomCenter,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Nome',
                          style: TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 20,
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
            }
          ),
        )
      )
    );
  }
  
  Future<bool> descarregaEquipaFuncionarios(String nif) async{
    colaboradores.clear();
    Uri url = definirUrl('recursosHumanos/utilizador/equipa.php', nif);
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);

    //Retornou uma lista de recibos
    if(data.statusCode == 200){
      List dados = resposta["data"];
      
      for(int i = 0; i <= dados.length - 1; i++){
        String nif = dados[i][0].replaceAll(" ", "");
        String nome = dados[i][1];
        colaboradores.add(Funcionario(nif, nome)); 
      }

      _datafuncionario = ListagemFuncionarios(lista: colaboradores);
      return true;
    }
    else{
      return false;
    }
  
  }
}

