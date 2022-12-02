import 'dart:convert';

import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/services/http_connections.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/decision_box.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeriasScreen extends StatefulWidget {
  const FeriasScreen({Key? key}) : super(key: key);

  @override
  State<FeriasScreen> createState() => _FeriasScreenState();
}

class _FeriasScreenState extends State<FeriasScreen> {
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => carregarDiasFerias());
    super.initState();
  }

  final List<DateTime> feriados = [
    DateTime(2022, 06, 22),
    DateTime(2022, 06, 12),
    DateTime(2022, 06, 14)
  ];

  final DateRangePickerController datePickerController = DateRangePickerController();
  
  bool validacao = false;
  String msgErro= '', titulo = '', dataI = '', dataF = '';
  DateTime data = DateTime.now();
  late int total = 0, totalDisponiveis = 0, totalUsadas= 0;
  PickerDateRange periodo = const PickerDateRange(null, null);
  late VoidCallback sim, nao;

  @override
  Widget build(BuildContext context3) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(t.menuFeria, 25, false, 300, explicacao: t.explicFerias),
      body: fundoApp(
        'assets/fundos/fundo_calendario.png',
        65,
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    style:  const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17,
                                      color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: total.toString(), 
                                        style: const TextStyle(
                                          fontFamily: 'Daysone',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        )
                                      ),
                                      TextSpan(text: t.feriasTotal),
                                    ],
                                  ),
                                ),
                          
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17,
                                      color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: totalDisponiveis.toString(), 
                                        style: const TextStyle(
                                          fontFamily: 'Daysone',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        )
                                      ),
                                      TextSpan(text: t.feriasDisponivel),
                                    ],
                                  ),
                                ),
                          
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17,
                                      color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: totalUsadas.toString(), 
                                        style: const TextStyle(
                                          fontFamily: 'Daysone',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        )
                                      ),
                                      TextSpan(text: t.feriasUtilizados),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                )
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SfDateRangePickerTheme(
                    data: SfDateRangePickerThemeData(),
                    child: Container(
                      color: Colors.white,
                      child: AbsorbPointer(
                        absorbing: totalDisponiveis == 0 ? true : false,
                        child: SfDateRangePicker(
                          
                          selectionMode: DateRangePickerSelectionMode.range,
                          
                          showActionButtons: false,
                          enablePastDates: true,
                          enableMultiView: true,
                          
                          
                          navigationDirection:DateRangePickerNavigationDirection.vertical,
                          navigationMode: DateRangePickerNavigationMode.scroll,
                                          
                          //Permitir que o usuário marque férias só no próprio ano
                          maxDate: DateTime(data.year + 1),
                                          
                          //Selecionar os dias que não são para ser considerados
                          monthViewSettings: DateRangePickerMonthViewSettings(
                            showTrailingAndLeadingDates: false,
                            //Mostrar os fins-de-semana
                            weekendDays: const [7,6],
                            //Mostrar os feriados e para isso tenho de recolher uma lista de datas
                            specialDates: feriados
                          ),
                          
                          //Desing
                          monthCellStyle: DateRangePickerMonthCellStyle(
                            weekendDatesDecoration: BoxDecoration(
                              color: Colors.blueGrey,
                              border: Border.all(color: Colors.black, width: 1),
                              shape: BoxShape.circle
                            ),
                            specialDatesDecoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(color: Colors.black, width: 1),
                              shape: BoxShape.circle
                            ),
                          ),
                          
                          controller: datePickerController,
                                          
                          //Programação
                          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                            periodo = args.value;
                            setState(() {
                              DateTime inicio = periodo.startDate!;
                              DateTime? fim = periodo.endDate;

                              dataI= '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')}/${inicio.year.toString().padLeft(2, '0')}';
                              dataF = (fim != null ? '${fim.day.toString().padLeft(2, '0')}/${fim.month.toString().padLeft(2, '0')}/${fim.year.toString().padLeft(2, '0')}' : dataI);
                            });
                          },
                        ),
                      )
                    )
                  ),
                )
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: t.ausPeriodo,
                          style: const TextStyle(
                            fontFamily: 'DaysOne',
                            fontSize: 20, 
                            color: Colors.black
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: dataI,
                              style: const TextStyle(
                                fontFamily: 'Gantari',
                                fontSize: 15, 
                                color: Colors.black
                              ),
                            ),
                            TextSpan(
                              text: (dataF.isEmpty && dataI.isEmpty) ? t.feriasSelecione : ' - ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Gantari',
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: dataF,
                              style: const TextStyle(
                                fontFamily: 'Gantari',
                                fontSize: 15, 
                                color: Colors.black
                              ),
                            )
                          ]
                        ),
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.brown[800],
                        heroTag: null,
                        onPressed: (){
                          if(periodo.startDate == null && periodo.endDate == null){
                            showDialog(barrierDismissible: true, context: context, builder: (context){
                              return dialogBox(context, t.feriasInsuficiente, t.feriasInsufExplicao, 200, Icons.warning);
                            });
                          }
                          else{
                            //Verifica os pormenores dos dados
                            statusError(periodo, totalDisponiveis, datePickerController, t);
                          }
                        },
                        child: Icon(
                          (dataI != '' && dataF != '') ? Icons.done : Icons.error
                        )
                      )
                    ],
                  ),
                )
              ),
              const SizedBox(height: 40)
            ],  
          ),
        ),
      )
    );
  }

  void statusError(PickerDateRange ranges, int tirarDias, DateRangePickerController datePickerController, AppLocalizations t){
    //Data inicial e final
    DateTime inicio = ranges.startDate!;
    DateTime fim = ranges.endDate ?? ranges.startDate!;
  
    int total = 0; //Diferença entre uma data e a outra

    if(inicio.compareTo(fim) != 0){
      //Capturo a diferença entre as datas
      Duration diferenca = (fim.difference(inicio));

      //Recolho os dias + 1 porque por defeito não agarra o selecionado
      int diferencaDias = diferenca.inDays + 1;

      //Recolho fins de semana e feriados e retiro nos dias selecionados
      total = diferencaDias - retornaFinsSemana(inicio, fim) - retornaFeriados(inicio, fim);
    }
  
    //Verifico se o total de dias selecinados é <= que os dias que tem direito
    if(total <= tirarDias) {
      titulo = t.escolhaSubmeter;
      msgErro = t.feriasSubmeterExplic;
      mostrarShowDialog(inicio, fim, 240, Icons.help, );
    }
    else {
      //Coloco dentro de outra variável para não o afetar
      if(tirarDias == 1){
        fim = inicio;
      }
      else{
        fim = addDuration(inicio, Duration(days: tirarDias + 1));
      }
      
      String fimFormat = DateFormat('dd-MM-yyyy').format(fim).toString();

      msgErro = t.feriasUltrapassou(total, tirarDias, fimFormat);
      titulo = t.feriasTotalUltrapassado;

      mostrarShowDialog(inicio, fim, 330, Icons.help);
    }
  }

  void mostrarShowDialog(DateTime inicio, DateTime fim, double tamanhoLayout, IconData icon){
    showDialog(barrierDismissible: true, context: context, builder: (telaAtual){
      nao = (){
        Navigator.pop(telaAtual);
      };

      sim = () async{
        // ano-mes-dia ano-mes-dia
        Navigator.pop(telaAtual);
        String data = '${inicio.year}-${inicio.month}-${inicio.day} ${fim.year}-${fim.month}-${fim.day}';
        HttpServicesProject.armazenarDadosFerias(data, context);
      };

      return decisionBox(
        context, 
        titulo,
        msgErro, 
        tamanhoLayout,
        icon, 
        sim, 
        nao,
      );
    });
  }

  //Função que retornará o número de fins de semana selecionados
  int retornaFinsSemana(DateTime inicio, DateTime fim) {
    //2022/06/24 -> 2022/06/27 -> 4
    int result = 0;
    int diaInicial = inicio.day;
    int diaFinal = fim.day;
    
    //Faço um ciclo que correrá a quantidade de vezes que a diferença de dias entre eles
    for (int i = diaInicial; i <= diaFinal; i++) {
      fim = DateTime(fim.year, fim.month, i);
      if (fim.weekday == DateTime.saturday || fim.weekday == DateTime.sunday) {
        result++;
      }
    }
    return result;
  }

  //Função que retorará o número de feriados selecionados
  int retornaFeriados(DateTime inicio, DateTime fim) {
    //2022/06/24 -> 2022/06/27 -> 4
    int result = 0;
    int diaInicial = inicio.day;
    int diaFinal = fim.day;
    
    //Faço um ciclo que correrá a quantidade de vezes que a diferença de dias entre eles
    for (int i = diaInicial; i <= diaFinal; i++) {
      fim = DateTime(fim.year, fim.month, i);
      if (feriados.contains(fim) && (fim.weekday != DateTime.saturday && fim.weekday != DateTime.sunday)) {
        result++;
      }
    }
    return result;
  }
  
  
  void carregarDiasFerias() async{
    int ano = DateTime.now().year;
    Uri url = definirUriGET('ausencias/get_days_ferias.php', campo1: ano.toString());
    
    http.Response data = await http.get(url);
    Map<String, dynamic> resposta = jsonDecode(data.body);

    //Retornou a lista da semana atual
    if(data.statusCode == 200){
      List data = resposta["data"];
      if(data.isNotEmpty){
        total = data[0];
        totalDisponiveis = double.parse(data[2]).round();
        totalUsadas = double.parse(data[1]).round();
      }
      else{
        total = 10;
        totalDisponiveis = 5;
        totalUsadas = 5;
      }
      setState(() {});
    }
    else{
      showDialog(barrierDismissible: true, context: context, builder: (context){
        return dialogBox(context, 'Algo correu mal', 'Contacte a área de TI', 230, Icons.warning);
      });
    }
  }
}

