import 'dart:convert';

import 'package:drh_project/screens/Utilizador/marcar_ementa.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class RefeitorioScreen extends StatefulWidget {
  final String nif;
  const RefeitorioScreen({ Key? key, required this.nif }) : super(key: key);
  
  @override
  State<RefeitorioScreen> createState() => _RefeitorioScreenState();
}

class _RefeitorioScreenState extends State<RefeitorioScreen> {
  
  DateTime now = DateTime.now();
  late int diaSemana;
  late List<DateTime> diasMes;
  late List<List<dynamic>> ementa = []; 

  @override
  void initState() {
    diaSemana = now.weekday;
    diasMes = marcarDiasEmenta(now);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_refeitorio.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    List<String> diasSemana = [
      t.smnSegunda,
      t.smnTerca,
      t.smnQuarta,
      t.smnQuinta,
      t.smnSexta,
    ];

    List<String> pratos = [
      t.ptSopa,
      t.ptPeixe,
      t.ptCarne,
      t.ptOutro,
    ];

    return fundoApp(
      'assets/fundos/fundo_refeitorio.png',
      10,
      Expanded(
        child: Column(
          children: [ 
            Visibility(
              visible: widget.nif == '288941837',
              child: FloatingActionButton.extended(
                heroTag: null,
                label: const Text(
                  '📝 Marcar Ementa 📝',
                  style: TextStyle(
                    fontFamily: 'DaysOne',
                    fontSize: 20,
                    color: Colors.white
                  )
                ),
                backgroundColor: Colors.brown[900],
                onPressed: () async{
                  await buscarEmentaSemana(diasMes); 
                  if (!context.mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MarcarEmentaScreen(nif: widget.nif, diasMes: diasMes, ementa: ementa))).then((value){setState((){});});
                }
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: buscarEmentaSemana(diasMes),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                      shrinkWrap: true,
                      itemCount: diasSemana.length,
                      itemBuilder: (context, index){
                        bool condicao = condicaoEmenta(index);
                        return Card(
                          elevation: 8,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: IgnorePointer(
                            ignoring: !condicao,
                            child: ExpansionTile(
                              initiallyExpanded: (diaSemana - 1) <= index ? condicao : false,
                              trailing: condicao ? null : Icon(Icons.warning, color: Colors.brown[800]),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    //! Semana
                                    diasSemana[index],
                                    style: TextStyle(
                                      fontFamily: 'DaysOne',
                                      fontSize: 20,
                                      color: Colors.brown[900],
                                    )
                                  ),
                                  Text(
                                    //! Semana
                                    ('${diasMes[index].day} / ${diasMes[index].month}'),
                                    style: TextStyle(
                                      fontFamily: 'DaysOne',
                                      fontSize: 15,
                                      color: Colors.brown[900],
                                    )
                                  ),
                                ],
                              ),
                                
                              onExpansionChanged: (value){
                              },
                              
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: 4, 
                                      itemBuilder: (context, i){
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (ementa[index][i] != null && ementa[index][i] != "") ? pratos[i] : '',
                                              style: const TextStyle(
                                                fontFamily: 'DaysOne',
                                                fontSize: 15,
                                                color: Color.fromARGB(255, 0, 155, 62),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              //! Prato
                                              ementa[index][i] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Gantari',
                                                fontSize: 14,
                                                color: Colors.black
                                              ),
                                            ),
                                          )
                                        ]
                                      );
                                    }
                                  ),
                                )
                              ]
                            ),
                          ),
                        );
                      }
                    );
                  }
                  else{
                    return Container();
                  }
                }
              ),
            ),
          ],
        ),
      )
    );
  }
  
  //Método para agarrar os dias da semana
  List<DateTime> marcarDiasEmenta(DateTime diaAtual){
    int diaSemanaAtual = diaAtual.weekday;
    DateTime segunda = diaAtual.subtract(Duration(days: diaSemanaAtual - 1));
    List<DateTime> marcarDiasEmenta = [];
    for(int i = 0; i <= 4; i++){
      marcarDiasEmenta.add(segunda.add(Duration(days: i)));
    }
    return marcarDiasEmenta;
  }
  
  Future<bool> buscarEmentaSemana(List<DateTime> periodo) async{
    String primeiroDia = periodo.first.toIso8601String();
    String ultimoDia = periodo.last.add(const Duration(days: 14)).toIso8601String();

    Uri url = definirUrl('rf/get_ementa_week.php', widget.nif, campo2: primeiroDia, campo3: ultimoDia);
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta =jsonDecode(data.body);

    //Retornou a lista da semana atual
    if(data.statusCode == 200){
      List data = resposta["data"];
      ementa.clear();
      for(int i = 0; i < data.length; i++){
        ementa.add(data[i]);
      }
      while(ementa.length <= 13){
        ementa.add(['','','','']);
      }
      return true;
    }
    else{
      showDialog(barrierDismissible: true, context: context, builder: (context){
        return dialogBox(context, 'Algo correu mal aqui', 'Contacte a área de TI', 230, Icons.warning);
      });
      return false;
    }
  }
  
  bool condicaoEmenta(int index) {
    if(ementa[index][0] == null || ementa[index][1] == null || ementa[index][2] == null){
      return false;
    }
    else{
      return true;
    }
  }
}