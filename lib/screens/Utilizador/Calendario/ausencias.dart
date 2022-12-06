import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:drh_project/models/ausencia.dart';
import 'package:drh_project/screens/Utilizador/Calendario/detalhes_foto.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/decision_box.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:drh_project/services/globals.dart' as globals;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AusenciasScreen extends StatefulWidget {
  final Ausencia? ausencia;
  const AusenciasScreen({Key? key, required this.ausencia}) : super(key: key);
  
  @override
  State<AusenciasScreen> createState() => _AusenciasScreenState();
}

class _AusenciasScreenState extends State<AusenciasScreen> {
  
  final _controllerMotivo = TextEditingController();
  
  final List<DateTime> feriados = [
    DateTime(2022, 06, 22),
    DateTime(2022, 06, 12),
    DateTime(2022, 06, 14)
  ];

  //Onde irei armazenar o documento
  List<File> documento = [];
  
  String categoria = '', descontoString = '', dataI = '', dataF = '', motivo = '', explicacaoCategoria = '';
  int ficheirosAnexados = 0;
  bool condicaoMostrarRelogio = false;

  late String dataFinal, erroTitulo, erroBody, categoriaAtualizada, descontoStringAtualizada;
  late List<String> opcoesAusencia, descontos;
  late int idAusencia;
  
  //Design
  FocusNode focus = FocusNode();

  //Períodos de tempo
  PickerDateRange periodoAusencia = const PickerDateRange(null, null);
  TimeOfDay tempoI = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay tempoF = const TimeOfDay(hour: 18, minute: 0);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  initState(){
    if(widget.ausencia != null){
      WidgetsBinding.instance.addPostFrameCallback((_) => setState((){recolherDadosAusencia(widget.ausencia!, context);}));
    }
    else{
      categoriaAtualizada = 'Casamento';
      descontoStringAtualizada = 'Banco de Horas';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    //Nenhum dos valores pode ser iguais
    opcoesAusencia = [
      t.ausSaude,
      t.ausFalecimento,
      t.ausCasamento,
      t.ausProvas,
      t.ausAcidente,
      t.ausReuniao,
      t.ausMotivosPessoais,
      t.ausOutro,
    ];

    descontos = [
      t.ausBanco,
      t.menuFeria,
      t.ausOrdenando,
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(t.menuAusencia, 25, false, 300, explicacao: t.explicAusec),
      body: fundoApp(
        'assets/fundos/fundo_calendario.png',
        60,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          t.ausCondicao,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 16, 
                            color: Colors.black
                          ),
                        ),
                      ),
                    
                      //! COMBO-BOX de selecionar uma categoria
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              //Espaçamento dentro da caixa
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, 
                              ),
                              decoration: BoxDecoration( 
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const <BoxShadow>[ 
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), 
                                    blurRadius: 5
                                  ) 
                                ]
                              ),
                              child: DropdownButton<String>(
                                value: categoria.isEmpty ? opcoesAusencia[0] : categoria,
                                items: opcoesAusencia.map((String value){
                                  return DropdownMenuItem<String>(
                                    alignment: AlignmentDirectional.centerStart,
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontFamily: 'Gantari',
                                        fontSize: 15, 
                                        color: Colors.black
                                      ),
                                    ),
          
                                    //Substitui o valor alterado pela chave selecionada
                                    onTap: (){
                                      setState(() {
                                        categoria = value;
                                      });
                                    },
                                  );
                                }).toList(),
          
                                underline: Container(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
          
                                isExpanded: true,           
          
                                //Muda conforme a categoria seleciona
                                onChanged: (String? newValue) {
                                  condicaoCategoria(newValue!, t);
                                },    
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 10),
          
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.brown[700],
                              child: const Icon(
                                Icons.info
                              ),
                              onPressed: (){
                                condicaoCategoria(categoria, t);
                              },
                            ),
                          )
                        ],
                      ),
          
                      const SizedBox(height: 20),
          
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          t.ausDescontar,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 16, 
                            color: Colors.black
                          ),
                        ),
                      ),
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              //Espaçamento dentro da caixa
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, 
                              ),
                              decoration: BoxDecoration( 
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const <BoxShadow>[ 
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), 
                                    blurRadius: 5
                                  ) 
                                ]
                              ),
                              child: DropdownButton<String>(
                                value: descontoString.isEmpty ? descontos[0] : descontoString,
                                items: descontos.map((item) => 
                                  DropdownMenuItem<String>(
                                    value: item,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontFamily: 'Gantari',
                                        fontSize: 15, 
                                        color: Colors.black
                                      ),
                                    ),
                                  )
                                ).toList(),
          
                                underline: Container(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
          
                                isExpanded: true,           
          
                                //Muda conforme a categoria seleciona
                                onChanged: (String? newValue) {
                                  setState(() {
                                    traduzDesconto(newValue, t);
                                    descontoString = newValue!;    
                                    if(descontoString == t.menuFeria || descontoString == 'Férias'){
                                      condicaoMostrarRelogio = false;
                                      if(dataF.contains("(")){
                                        dataF = dataI;
                                      }
                                    }
                                    else{
                                      condicaoMostrarRelogio = true;
                                      if(dataI == dataF){
                                        dataF = '(00:00 - 00:00)';
                                      }
                                    }                 
                                  });
                                },    
                              )
                            ),
                          ),
                          
                          const SizedBox(width: 10),
          
                          Badge(
                            badgeColor: (documento.isNotEmpty ? Colors.white : Colors.red),
                            toAnimate: true,
                            position: BadgePosition.topStart(top: -10, start: 30),
                            badgeContent: Text(
                              ficheirosAnexados.toString(),
                              style: const TextStyle(
                                fontFamily: 'Gantari',
                                fontSize: 18, 
                                color: Colors.black
                              ),
                            ),
                        
                            child: FloatingActionButton.small(
                              heroTag: null,
                              backgroundColor: Colors.brown[800],
                              child: const Icon(
                                Icons.description,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                focus.unfocus();
                                galeriaFotos(context).then((value) {setState(() {});});
                              }
                            ),
                          )
                        ],
                      ),
          
                      const SizedBox(height: 10),
                      //Caixa de Texto para o motivo da
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Text(
                          t.ausMotivo,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 16, 
                            color: Colors.black
                          ),
                        ),
                      ),
                      Padding(  
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: InkWell(
                          child: Container(
                            height: 150.0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration( 
                              border: Border.all(color: const Color.fromARGB(255, 102, 69, 62)),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SingleChildScrollView(
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                focusNode: focus,
                                controller: _controllerMotivo,
                                style: const TextStyle(
                                  color:Colors.black,
                                  fontSize: 17.0,  
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                onChanged: (value){
                                  motivo = value;
                                },
                              ), 
                            )
                          ),
                          onTap: (){
                            focus.requestFocus();
                          }
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            FloatingActionButton.extended(
                              heroTag: null,
                              backgroundColor: Colors.brown[800], 
                              label: const Icon(Icons.date_range),
                              onPressed: () {
                                focus.unfocus();
                                mostrarCalendario(context).then((value) {setState(() {});});
                              }
                            ),
          
                            const SizedBox(width: 10),
          
                            Visibility(
                              visible: condicaoMostrarRelogio,
                              child: FloatingActionButton.extended(
                                heroTag: null,
                                backgroundColor: Colors.brown[800], 
                                label: const Icon(Icons.schedule),
                                onPressed: () async{
                                  focus.unfocus();
                                  await showTimePicker(
                                    context: context, 
                                    initialTime: tempoI
                                  ).then((tempoInicial) async{
                                    if(tempoInicial != null) {
                                      await showTimePicker(
                                        context: context, 
                                        initialTime: tempoF
                                      ).then((tempoFinal){
                                        if(tempoFinal != null){
                                          tempoI = tempoInicial;
                                          tempoF = tempoFinal;
                                          
                                          //Marcação de horas iniciais
                                          String horaI = tempoI.hour.toString();
                                          String minutoI = tempoI.minute.toString();
          
                                          //Marcação de horas finais
                                          String horaF = tempoF.hour.toString();
                                          String minutoF = tempoF.minute.toString();
          
                                          horaI = horaI.length == 2 ? horaI : horaI.padLeft(2, '0');
                                          minutoI = minutoI.length == 2 ? minutoI : minutoI.padLeft(2, '0');
          
                                          horaF = horaF.length == 2 ? horaF : horaF.padLeft(2, '0');
                                          minutoF = minutoF.length == 2 ? minutoF : minutoF.padLeft(2, '0');
          
                                          setState(() => dataF = '($horaI:$minutoI - $horaF:$minutoF)');
                                        }
                                        else{ 
                                          setState(() => dataF = '(00:09 - 18:00)');
                                        }
                                      });
                                    }
                                    else{
                                      setState(() => dataF = '(00:09 - 18:00)');
                                    }
                                  });
                                }
                              ),
                            ),
          
                            const SizedBox(width: 10),
          
                            Expanded(
                              child: FloatingActionButton.extended(
                                heroTag: null,
                                backgroundColor: Colors.brown[800], 
                                label: Text(t.ausIntervalo,
                                  style: const TextStyle(
                                    fontFamily: 'Gantari',
                                    fontSize: 15, 
                                    color: Colors.white
                                  ),
                                ),
                                onPressed: () async{
                                  focus.unfocus();
                                  //Verifico se o horário é válido
                                  if(periodoAusencia.startDate == null && periodoAusencia.endDate == null){
                                    showDialog(barrierDismissible: true, context: context, builder: (context){
                                      return dialogBox(context, t.ausIncompleto, t.ausDefina, 230, Icons.warning);
                                    });
                                  }
                                  else{
                                    //Verifico se a data inicial == data finalfinal
                                    if(periodoAusencia.startDate!.compareTo(periodoAusencia.endDate ?? periodoAusencia.startDate!) == 0){
                                      //! Guardar com horário
                                      String relogio = dataF.substring(1, dataF.length-1); //00:00 - 00:00
                                      String data = '${periodoAusencia.startDate!.year}-${periodoAusencia.startDate!.month}-${periodoAusencia.startDate!.day}';
                                      dataFinal = '$data $relogio'; // ano-mes-dia 00:00 - 00:00
                                    }
                                    else{
                                      //! Apenas Guardar com Datas
                                      String dataI = '${periodoAusencia.startDate!.year}-${periodoAusencia.startDate!.month.toString().padLeft(2, '0')}-${periodoAusencia.startDate!.day.toString().padLeft(2, '0')}';
                                      String dataF = '${periodoAusencia.endDate!.year}-${periodoAusencia.endDate!.month.toString().padLeft(2, '0')}-${periodoAusencia.endDate!.day.toString().padLeft(2, '0')}'; 
                                      dataFinal = '$dataI $dataF'; // ano-mes-dia ano-mes-dia
                                    }
                                    if(documento.isNotEmpty){
                                      List<String> caminhoDocumentos = [];
                                      for(int i = 0; i < documento.length; i++){
                                        caminhoDocumentos.add(documento[i].path);
                                      }
                                      if(await guardarDadosBaseDados(dataFinal, caminhoDocumentos, ausencia: (widget.ausencia))){
                                        showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, t.errPHP7, t.ausAprovacao, 180, Icons.thumb_up);
                                        }).then((value) => Navigator.pop(context));
                                      }
                                      else{
                                        showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, erroTitulo, erroBody, 500, Icons.warning);
                                        });
                                      }
                                    }
                                    else{
                                      showDialog(barrierDismissible: false, context: context, builder: (primeiraTela){
                                        return decisionBox(primeiraTela, t.ausDocuments, t.ausDeseja, 350, Icons.warning, repondeuSim(primeiraTela, t, ausencia: widget.ausencia), respondeuNao(primeiraTela));
                                      });
                                    }
                                  }
                                }
                              ),
                            ),
                          ],
                        )
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    text: dataI.isEmpty ? t.ausPeriodoInicial : dataI,
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17, 
                                      color: Colors.black
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' - ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: dataF.isEmpty ? t.ausPeriodoFinal : dataF,
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17, 
                                      color: Colors.black
                                    ),
                                  )
                                ]
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ),
                const SizedBox(
                  height: 150,
                  width: 10
                )
              ],
            ),
          ),
        )
      )
    );
  }

  //! Calendário que farão a seleção de datas
  Future<void> mostrarCalendario(BuildContext context) async{
    var t = AppLocalizations.of(context)!;
    DateTime data = DateTime.now();
    final DateRangePickerController datePickerController = DateRangePickerController();
    
    return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (context,setState){
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: SfDateRangePickerTheme(
                          data: SfDateRangePickerThemeData(
                          ),
                          child: Container(
                            color: Colors.white,
                            child: SfDateRangePicker(

                              selectionMode: DateRangePickerSelectionMode.range,
                              showActionButtons: true,
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
                              confirmText: t.btConfirmar,
                              onSubmit: (args) {
                                if(args != null){
                                  periodoAusencia = args as PickerDateRange;
                                  dataI = '${periodoAusencia.startDate!.day.toString().padLeft(2, '0')} / ${periodoAusencia.startDate!.month.toString().padLeft(2, '0')} / ${periodoAusencia.startDate!.year}';
                                  
                                  //Verifico se a data marcada foi para apenas um dia
                                  if((periodoAusencia.endDate == null || periodoAusencia.startDate == periodoAusencia.endDate) && (descontoString != t.menuFeria && descontoString != 'Férias')){
                                    dataF = '(00:09 - 18:00)';
                                    condicaoMostrarRelogio = true;
                                  }
                                  else{
                                    if((descontoString == t.menuFeria || descontoString == 'Férias') && periodoAusencia.endDate == null){
                                      dataF = dataI;
                                    }
                                    else{
                                      dataF = '${periodoAusencia.endDate!.day.toString().padLeft(2, '0')} / ${periodoAusencia.endDate!.month.toString().padLeft(2, '0')} / ${periodoAusencia.endDate!.year}';
                                      condicaoMostrarRelogio = false;
                                    }
                                    
                                  }
                                } 
                                Navigator.pop(context);
                              },

                              cancelText: t.btCancelar,
                              onCancel: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ),
                      ),
                    ),
                  ],
                )
              )
            );
          }
        );
      }
    );
  }

  //! Disponibilizará uma categoria no meio das condições
  Future<void> galeriaFotos(BuildContext context) async{
    var t = AppLocalizations.of(context)!;
    return await showDialog(context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (context, setState){
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Text(
                          t.ausGaleria,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 16, 
                            color: Colors.black
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        //! Galeria de documentos
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GridView.builder(
                            itemCount: documento.length,
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0.80,
                              childAspectRatio: 0.75,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemBuilder: ((context, index){
                              final item = documento[index];
                              final ext = p.extension(item.path);
                              return InkWell(
                                child: GridTile(
                                  child: ext == '.jpg' ?
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    child: Stack(
                                      children:[
                                        item.path.substring(0, 4) != 'http' ?
                                        Image.file(
                                          File(item.path)
                                        )
                                        :
                                        Image.network(
                                          item.path
                                        ),

                                        FloatingActionButton.small(
                                          backgroundColor: Colors.brown[800],
                                          heroTag: null,
                                          child: const Icon(Icons.delete),
                                          onPressed: (){
                                            setState(() {
                                              documento.removeAt(index);
                                            });
                                            this.setState(() {
                                              ficheirosAnexados--;
                                            });
                                          }
                                        )
                                      ]
                                      
                                    )
                                  ) :
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: ext == '.pdf' ?
                                            Image.asset(
                                              'assets/icons/calendario/pdf.png'
                                            ) :
                                            Image.asset(
                                              'assets/icons/calendario/unknow.png'
                                            )
                                          ),
                                        ),
                                        const Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: Text(
                                            'File',
                                            style: TextStyle(
                                              fontFamily: 'Gantari',
                                              fontSize: 20, 
                                              color: Colors.black
                                            ),
                                          )
                                        ),
                                        FloatingActionButton.small(
                                          backgroundColor: Colors.brown[800],
                                          heroTag: null,
                                          child: const Icon(Icons.delete),
                                          onPressed: (){
                                            setState(() {
                                              documento.removeAt(index);
                                            });
                                            this.setState(() {
                                              ficheirosAnexados--;
                                            });
                                          }
                                        )
                                      ],
                                    ),
                                  )
                                ),

                                //! Mostrar a imagem em ponto grande
                                onTap: (){
                                  //Muda para outra página
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsPage(documento: File(item.path), index: index, extensao: ext, caminho: item.path)
                                    )
                                  );
                                },
                                
                                //! Mandar a imagem para o lixo
                                onLongPress: (){

                                },
                              );
                            })
                          )
                        )
                      ),

                      //! Butões de ação
                      Expanded(
                        flex: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //! TODO Sacar da drive qualquer tipo de documento
                            FloatingActionButton(
                              backgroundColor: Colors.brown[800], 
                              heroTag: null,
                              child: const Icon(Icons.library_books),
                              onPressed: () async{
                                try{
                                  final FilePickerResult? picker = await FilePicker.platform.pickFiles();
                                  if(picker != null){
                                    File file = File(picker.files.single.path!);
                                    setState((){
                                      documento.add(file);
                                      ficheirosAnexados = documento.length;
                                    });
                                  }
                                }
                                catch(e){
                                  debugPrint('$e');
                                }
                              }
                            ),

                            //! TODO Capturar uma fotografia
                            FloatingActionButton(
                              backgroundColor: Colors.brown[800], 
                              heroTag: null,
                              child: const Icon(Icons.camera),
                              onPressed: () async{
                                final ImagePicker picker = ImagePicker();
                                try{
                                  //Dá para colocar em vez de galeria ser através da câmara
                                  XFile? file = await picker.pickImage(source: ImageSource.camera);
                                  setState(() {
                                    //Verifico se o documento retornar null para não dar erro
                                    (file != null ? documento.add(File(file.path)) : null);
                                    ficheirosAnexados = documento.length;
                                  });
                                }
                                catch(e){
                                  // ignore: avoid_print
                                  print(e);
                                }
                              }
                            ),

                            FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.brown[800], 
                              child: const Icon(Icons.close),
                              onPressed: () async{
                                //! Cancelar a operação
                                documento.clear();
                                ficheirosAnexados = 0;
                                Navigator.of(context).pop();
                              }
                            ),
                            FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.brown[800], 
                              child: const Icon(Icons.done),
                              onPressed: () async{
                                //! Dar por concluído a operação
                                Navigator.of(context).pop();
                              }
                            ),
                          ],
                        )
                      )
                    ]
                  )
                )
              )
            );
          }
        );
      }
    );
  }

  //Tive de fazer desta forma porque ele não aceitava constantes
  Map<String, dynamic> condicaoCategoria(String categoria, AppLocalizations t){
    if(categoria == t.ausCasamento || categoria == 'Casamento'){
      explicacaoCategoria = 'Tem direito a 15 dias consecutivos';
      categoriaAtualizada = 'Casamento';
      categoria = t.ausCasamento;
    }
    else if(categoria == t.ausFalecimento || categoria == 'Falecimento'){
      explicacaoCategoria = 'Depende dos casos:';
      categoriaAtualizada = 'Falecimento';
      categoria = t.ausFalecimento;
    }
    else if(categoria == t.ausProvas || categoria == 'Provas de Avaliação'){
      explicacaoCategoria = 'Tem direito a 2 dias consecutivos (Um dia anterior ao teste o no próprio dia)';
      categoriaAtualizada = 'Provas de Avaliação';
      categoria = t.ausProvas;
    }
    else if(categoria == t.ausSaude || categoria == 'Saúde'){
      explicacaoCategoria = 'Dependente de Atestado Médico';
      categoriaAtualizada = 'Saúde';
      categoria = t.ausSaude;
    } 
    else if(categoria == t.ausAcidente || categoria == 'Acidente'){
      explicacaoCategoria = 'Não sei';
      categoriaAtualizada = 'Acidente';
      categoria = t.ausAcidente;
    }
    else if(categoria == t.ausReuniao || categoria == 'Casamento'){
      explicacaoCategoria = 'Tem direito a 4 horas por trimeste para ir as reuniões';
      categoriaAtualizada = 'Reunião como Enc. Educação';
      categoria = t.ausReuniao;
    }
    else if(categoria == t.ausOutro || categoria == 'Outro'){
      explicacaoCategoria = 'Sem descrição';
      categoriaAtualizada = 'Outro';
      categoria = t.ausOutro;
    }
    else if(categoria == t.ausMotivosPessoais || categoria == 'Motivos Pessoais'){
      explicacaoCategoria = 'Não sei';
      categoriaAtualizada = 'Motivos Pessoais';
      categoria = t.ausMotivosPessoais;
    }
    else{
      explicacaoCategoria = '';
      categoriaAtualizada = '';
      categoria = t.ausCasamento;
    }

    return {
      'Explicacao' : explicacaoCategoria,
      'Condicao' : categoria
    };
  }

  //O mesmo se aplica ao caso de cima
  void traduzDesconto(String? desconto, AppLocalizations t) {
    if(desconto == t.ausBanco || desconto == 'Banco de Horas'){
      descontoStringAtualizada = 'Banco de Horas';
      descontoString = t.ausBanco;

    }
    else if(desconto == t.ausOrdenando || desconto == 'Ordenado'){
      descontoStringAtualizada = 'Ordenado';
      descontoString = t.ausOrdenando;
    }
    else{
      descontoStringAtualizada = 'Férias';
      descontoString = t.menuFeria;
    }
  }
  
  Future<bool> guardarDadosBaseDados(String periodo, List<String>? documentos, {Ausencia? ausencia}) async{
    String baseImage;
    
    try{
      documentos = documentos ?? [];
      Map<String, dynamic> data = {
        "ctb" : globals.nif,
        "categoria" : categoriaAtualizada,
        "desconto" : descontoStringAtualizada,
        "motivo" : motivo,
        "data": periodo,
        "quantidade" : documentos.length.toString(),
      };

      for(int i=0; i<documentos.length; i++){
        baseImage = '';

        if(documentos[i].substring(0, 4) != 'http'){
          File ficheiro = File(documentos[i]);
          List<int> imageBytes = ficheiro.readAsBytesSync();
          baseImage = base64Encode(imageBytes);
        }
        
        data.addAll({"document$i": documentos[i].substring(0, 4) != 'http' ? baseImage : documentos[i]});
      }

      for(int i=0; i<documentos.length; i++){
        data.addAll({"path$i": documentos[i]});
      }

      if(ausencia != null){
        data.addAll({"idAusencia": '${ausencia.id}'});

        var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/ausencias/change_ausencia.php");
        http.Response response = await http.post(url, body:data);
        Map<String, dynamic> resposta = jsonDecode(response.body);
        
        erroTitulo = resposta['type'] ?? 'Algo inesperado aconteceu';
        erroBody = resposta['message'] ?? 'Contacte os serviços administrativos';

        return response.statusCode == 200 ? true : false;
      }
      else{
        var url = Uri.parse("http://${globals.ip}/projects/flutter/drh_project/ausencias/save_ausencia.php");
        http.Response response = await http.post(url, body:data);
        Map<String, dynamic> resposta = jsonDecode(response.body);
        
        erroTitulo = resposta['type'] ?? 'Algo inesperado aconteceu';
        erroBody = resposta['message'] ?? 'Contacte os serviços administrativos';

        return response.statusCode == 200 ? true : false;
      }
    }
    catch(e){
      return false;
    }
  }

  VoidCallback repondeuSim(BuildContext telaAtual, AppLocalizations t, {Ausencia? ausencia}){
    return (){
      Navigator.pop(telaAtual);
      guardarDadosBaseDados(dataFinal, null, ausencia: ausencia);
      
      showDialog(barrierDismissible: true, context: context, builder: (segundaTela){
        return dialogBox(segundaTela, t.errPHP7, t.ausAprovacao, 190, Icons.thumb_up);
      }).then((value) => Navigator.pop(context));
    };
  }
  
  VoidCallback respondeuNao(BuildContext telaAtual) {
    return (){
      Navigator.pop(telaAtual);
    };
  }
  
  void recolherDadosAusencia(Ausencia ausencia, BuildContext context){
    var t = AppLocalizations.of(context)!;
    
    //!motivo
    _controllerMotivo.text = ausencia.motivo ?? 'Não apresenta motivo';
    motivo = ausencia.motivo ?? 'Não apresenta motivo';
    
    //!periodo de tempo
    DateTime inicio = ausencia.periodo.startDate!;
    DateTime fim = ausencia.periodo.endDate!;
    periodoAusencia = PickerDateRange(inicio, fim);

    if('${inicio.day}-${inicio.month}-${inicio.year}' == '${fim.day}-${fim.month}-${fim.year}'){
      dataI = '${inicio.day.toString().padLeft(2, '0')}-${inicio.month.toString().padLeft(2, '0')}-${inicio.year}'; // ano-mes-dia
      dataF = '(${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')} - ${fim.hour.toString().padLeft(2, '0')}:${fim.minute.toString().padLeft(2, '0')})'; //00:00 - 00:00
    }
    else{
      dataI = '${inicio.day.toString().padLeft(2, '0')}-${inicio.month.toString().padLeft(2, '0')}-${inicio.year}';
      dataF = '${fim.day.toString().padLeft(2, '0')}-${fim.month.toString().padLeft(2, '0')}-${fim.year}'; 
    }

    //!documentos
    ficheirosAnexados = ausencia.documentos!.length;

    for(int i = 0; i < ficheirosAnexados; i++){
      documento.add(File(ausencia.documentos![i]));
    }

    //!categoria
    categoria = condicaoCategoria(ausencia.categoria, t)["Condicao"];

    //!desconto
    traduzDesconto(ausencia.desconto, t);

    //!id
    idAusencia = ausencia.id;
  }

  /*
  //! Disponibilizará uma categoria no meio das condições
  Future<void> escolherCategoria(BuildContext context) async{
    return await showDialog(context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (context,setState){
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
              ),
              child: Form(
                key: _formKey,
                //! Modificar o layout dos radiobuttons
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < opcoes.length; i++)
                      ListTile(
                        tileColor: (valorEscolhido == opcoes[i]) ? Colors.green : Colors.white,
                        title: Text(
                          opcoes[i],
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            fontSize: 16, 
                            color: Colors.black
                          ),
                        ),
                        onTap: (){
                          valorEscolhido = opcoes[i];
                          Navigator.of(context).pop();
                        },
                      ),
                    ]
                  )
                )
              )
            );
          }
        );
      }
    );
  }
  */
}