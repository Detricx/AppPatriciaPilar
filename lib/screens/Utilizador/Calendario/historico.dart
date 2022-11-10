import 'dart:convert';
import 'package:drh_project/models/ausencia.dart';
import 'package:drh_project/screens/Utilizador/calendario/ausencias.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/decision_box.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HistoricoScreen extends StatefulWidget {
  final String nif;
  const HistoricoScreen(this.nif, { Key? key }) : super(key: key);
  
  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  
  

  //Conta tanto para férias como para as ausências
  late List<Ausencia> ausencias = [];
  List<String> meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
  late TextEditingController controllerMotivo;
  late VoidCallback sim, nao;
  late String type, msg;
  String descontoString = '';
  String categoriaHistorico = '';

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(t.menuHistorico, 25, false, 300, explicacao: t.explicHist),
          body: fundoApp(
            'assets/fundos/fundo_calendario.png',
            60,
            Expanded(
              child: FutureBuilder(
                future: preencherListas(widget.nif),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return Column(
                      children: <Widget>[
                        TabBar(  
                          tabs: [  
                            Text(t.historicoPendente),
                            Text(t.historicoConfirmado),  
                            Text(t.historicoRecusado)
                          ],  
                        ),

                        const SizedBox(height: 10),
                        
                        Expanded(
                          child: TabBarView(
                            children: [
                              //!Explicação de níveis
                              /// 1- Ausência por aprovar pelo coordenador
                              /// 2- Ausência por aprovar pelos RH
                              /// 3- Ausência Aprovada
                              /// 4- Recusamento pelo coordenador
                              /// 5- Recusamento pelos RH
                              /// 6- Recusamento Aprovado

                              //Aprovações em Espera no nível para os coordenadores
                              estadoHistorico(ausencias.where((element) => (element.nivel == 1 || element.nivel == 4 )).toList(), widget.nif, t),

                              //Aprovações confirmadas
                              estadoHistorico(ausencias.where((element) => (element.nivel == 3 || element.nivel == 6)).toList(), widget.nif, t),
                              
                              //Aprovações recusadas
                              estadoHistorico(ausencias.where((element) => (element.nivel == 0 || element.nivel == 7)).toList(), widget.nif, t),
                            ],
                          ),
                        )
                      ]
                    );
                  }
                  else{
                    return Center(
                      child: SpinKitCircle(
                        size: 180,
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
                }
              )
            ),
          ),
        ),
    );
  }
  
  Future<bool> preencherListas(String nif) async{
    ausencias.clear();
    try{
      Uri url = definirUrl('recursosHumanos/utilizador/historico.php', nif);
    
      http.Response data = await http.get(url);
      
      //Retornou a lista da semana atual
      if(data.statusCode == 200){
        Map<String, dynamic> resposta = jsonDecode(data.body);
        List lista = resposta["data"];

        for(int i = 0; i < lista.length; i++){
          List ausencia = lista[i];
          ausencias.add(
            Ausencia(
              PickerDateRange(DateTime.parse(ausencia[4]["date"]), DateTime.parse(ausencia[5]["date"])), 
              ausencia[1], 
              ausencia[2], 
              ausencia[3], 
              ausencia[0], 
              ausencia[7],
              nivel: ausencia[6],
            )
          );
        }
        return true;
      }
      else if(data.statusCode == 204){
        return true;
      }
      else{
        showDialog(barrierDismissible: true, context: context, builder: (context){
          return dialogBox(context, 'Algo correu mal', 'Contacte a área de TI', 230, Icons.warning);
        });
        return false;
      }
    }
    catch(e){
      return false;
    }
    
  }
  
  Widget estadoHistorico(List<Ausencia> ausencias, String nif, AppLocalizations t) {

    Widget mostrarDocuments(List documentos, BuildContext context, AppLocalizations t) {
      return StatefulBuilder(
        builder: (context,setState){
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0)
            ),
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
                        itemCount: documentos.length,
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0.80,
                          childAspectRatio: 0.75,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemBuilder: ((context, index){
                          String path = documentos[index];
                          String ext = p.extension(path);
                          return InkWell(
                            child: GridTile(
                              child: ext == '.jpg' ?
                              Container(
                                margin: const EdgeInsets.all(5),
                                child: Stack(
                                  children:[
                                    Image.network(
                                      path
                                    ),
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
                                  builder: (context) => Scaffold(
                                    resizeToAvoidBottomInset: false,
                                    backgroundColor: const Color.fromARGB(227, 255, 255, 255),
                                    body: ext == '.pdf' 
                                    ?
                                    //!Para o caso de ser um PDF
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Stack(
                                        children: <Widget>[
                                          SfPdfViewer.network(
                                            path,
                                          ),
                                          
                                          FutureBuilder(
                                            future: Future<dynamic>.delayed(const Duration(seconds: 5)).then((dynamic value) {return;}),
                                            builder: (context, snapshot) {
                                              if(snapshot.connectionState != ConnectionState.done){
                                                return Center(
                                                  child: SpinKitCircle(
                                                    size: 180,
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
                                                return Container();
                                              }
                                            },
                                          ),
                                    
                                          Padding(
                                            padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                                            child: FloatingActionButton(
                                              heroTag: null,  
                                              backgroundColor: Colors.brown[800],
                                              child: const Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                              ),
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              }
                                            )
                                          )
                                        ],
                                      ),
                                    )

                                    :
                                    //!Para o caso de ser uma imagem
                                    Stack(
                                      children: <Widget>[
                                        InteractiveViewer(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Hero(
                                                  tag: 'logo$index',
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(path),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                                          child: FloatingActionButton(
                                            heroTag: null,  
                                            backgroundColor: Colors.brown[800],
                                            child: const Icon(
                                              Icons.arrow_back,
                                              color: Colors.white,
                                            ),
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            }
                                          )
                                        )
                                      ],
                                    ),
                                  )
                                )
                              );
                            },
                          );
                        })
                      )
                    )
                  ),
                ]
              )
            )
          );
        }
      );
    }

    Future<bool> recusaAusencia(Ausencia ausencia, AppLocalizations t, int nivel) async{
      try{
        var url = Uri.parse("http://192.168.26.146/projects/flutter/drh_project/ausencias/delete_ausencia.php?ctb=${widget.nif}&idAusencia=${ausencia.id}&nivel=$nivel");
        var request = http.Request('DELETE', url);

        http.StreamedResponse response = await request.send();
        String resultado = await response.stream.bytesToString();
        
        Map<String, dynamic> resposta = jsonDecode(resultado);
        type = resposta["type"];
        msg = resposta ["message"];

        return response.statusCode == 200 ? true : false;
      }
      catch(e){
        return false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: ListView.builder(
              itemCount: ausencias.length,
              itemBuilder: (context, index){
                Ausencia ausencia = ausencias[index]; 
                DateTime periodoInicial = ausencia.periodo.startDate!;
                DateTime periodoFinal = ausencia.periodo.endDate!;
                bool horas = '${periodoInicial.day}/${periodoInicial.month}/${periodoInicial.year}' == '${periodoFinal.day}/${periodoFinal.month}/${periodoFinal.year}';
                String periodohoras = '${periodoInicial.hour.toString().padLeft(2, '0')}:${periodoInicial.minute.toString().padLeft(2, '0')} ${periodoFinal.hour.toString().padLeft(2, '0')}:${periodoFinal.minute.toString().padLeft(2, '0')}';
                controllerMotivo = TextEditingController(text: ausencia.motivo == '' ? t.aprovaNaoMotivo : ausencia.motivo);

                condicaoCategoria(ausencia.categoria, t);
                traduzDesconto(ausencia.desconto, t);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: IgnorePointer(
                    ignoring: !(ausencia.nivel != 6),
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                                )
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    meses[ausencia.periodo.startDate!.month],
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 12,
                                      color: Colors.black,
                                    )
                                  ),
                      
                                  Text(
                                    ausencia.periodo.startDate!.day.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 20,
                                      color: Colors.black,
                                    )
                                  )
                                ],
                              ),
                            ),
                      
                            Visibility(
                              visible: true,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.swap_horiz
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          meses[ausencia.periodo.endDate!.month],
                                          style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            fontSize: 12,
                                            color: Colors.black,
                                          )
                                        ),
                      
                                        Text(
                                          ausencia.periodo.endDate!.day.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            fontSize: 20,
                                            color: Colors.black,
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ), 
                      
                            const SizedBox(
                              width: 20,
                            ),
                      
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (ausencia.nivel == 4 || ausencia.nivel == 5 ? 'Recusamento' : ausencia.categoria != 'Férias' ? t.historicoAusencia : t.historicoFerias),
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 15,
                                      color: Colors.black,
                                    )
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    horas ?  periodohoras : t.historicoPeriodo,
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 12,
                                      color: Colors.black,
                                    )
                                  ),
                                ],
                              )
                            ),
                          ] 
                        ),
                      
                        expandedAlignment: Alignment.centerLeft,
                      
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: ausencia.categoria != 'Férias',
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: t.aprovaCategoria,
                                          style: const TextStyle(
                                            fontFamily: 'DaysOne',
                                            fontSize: 13,
                                            color: Colors.black
                                          ),
                                        ),
                                        TextSpan(
                                          text: categoriaHistorico,
                                          style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            fontSize: 15,
                                            color: Colors.black
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      
                                Visibility(
                                  visible: ausencia.categoria != 'Férias',
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: t.aprovaDesconto,
                                          style: const TextStyle(
                                            fontFamily: 'DaysOne',
                                            fontSize: 13,
                                            color: Colors.black
                                          ),
                                        ),
                                        TextSpan(
                                          text: descontoString,
                                          style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            fontSize: 15,
                                            color: Colors.black
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      
                                Visibility(
                                  visible: ausencia.categoria != 'Férias',
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.aprovaMotivo,
                                          style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            fontSize: 15,
                                            color: Colors.black
                                          ),
                                        ),
                                        Container(
                                          height: 80.0,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration( 
                                            border: Border.all(color: const Color.fromARGB(255, 102, 69, 62)),
                                            color: const Color.fromARGB(255, 250, 250, 250),
                                          ),
                                          child: SingleChildScrollView(
                                            child: TextFormField(
                                              keyboardType: TextInputType.multiline,
                                              maxLines: null,
                                              readOnly: true,
                                              controller: controllerMotivo,
                                              style: const TextStyle(
                                                color:Colors.black,
                                                fontFamily: 'Gantari',
                                                fontSize: 14.0,  
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                              ),
                                            ), 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          //!BUTÕES _____________________________
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //!VER DOCUMENTOS
                                      Visibility(
                                        visible: ausencia.documentos!.isNotEmpty,
                                        child: FloatingActionButton.small(
                                          heroTag: null,
                                          backgroundColor: Colors.brown[800],
                                          child: const Icon(
                                            Icons.description,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          onPressed: (){
                                            showDialog(barrierDismissible: true, context: context, builder: (context){
                                              return mostrarDocuments(ausencia.documentos!, context, t);
                                            });
                                          },
                                        ),
                                      ),
                      
                                      Visibility(
                                        visible: ausencia.documentos!.isNotEmpty, 
                                        child: const SizedBox(width: 40)
                                      ),
                      
                                      Visibility(
                                        visible: ausencia.nivel == 1 && ausencia.categoria != 'Férias',
                                        child: FloatingActionButton.small(
                                          heroTag: null,
                                          backgroundColor: Colors.brown[800],
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          onPressed: (){
                                            Navigator.push(context,
                                              MaterialPageRoute(
                                                builder: (context) => AusenciasScreen(nif: widget.nif, ausencia: ausencia)
                                              )
                                            ).then((value) => setState((){}));
                                          },
                                        ),
                                      ),
                      
                                      Visibility(
                                        visible: ausencia.nivel == 1 && ausencia.categoria != 'Férias',
                                        child: const SizedBox(width: 40)
                                      ),
                    
                                      Visibility(
                                        visible: ausencia.nivel != 6,
                                        child: FloatingActionButton.small(
                                          heroTag: null,
                                          backgroundColor: Colors.brown[800],
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                    
                                          onPressed: (){
                                            showDialog(barrierDismissible: false, context: context, builder: (context){
                                              String titulo;
                                              String msg;
                                      
                                              nao = (){
                                                Navigator.pop(context);
                                              };
                                      
                                              // Caso já tenha sido confirmada, vai para o processo de cancelamento
                                              if(ausencia.nivel == 3){
                                                titulo = '';
                                                msg = '';
                    
                                                sim = () async{
                                                  // ano-mes-dia ano-mes-dia
                                                  Navigator.pop(context);
                                                  recusaAusencia(ausencia, t, 4);
                                                };
                                              }
                                              // Está no processo de cancelamento e volta para o nível 3
                                              else if(ausencia.nivel == 4 || ausencia.nivel == 7){
                                                titulo = '';
                                                msg = '';
                                      
                                                sim = () async{
                                                  // ano-mes-dia ano-mes-dia
                                                  Navigator.pop(context);
                                                  recusaAusencia(ausencia, t, 3);
                                                };
                                              }
                                              // A ausência não foi aprovada (0- 1 - 2)
                                              else{
                                                titulo = t.historicoEliminar;
                                                msg = t.historicoEliminarPergunta;
                                      
                                                sim = () async{
                                                  // ano-mes-dia ano-mes-dia
                                                  Navigator.pop(context);
                                                  recusaAusencia(ausencia, t, 0);
                                                };
                                              }
                    
                                              return decisionBox(context, titulo, msg, 250, Icons.warning, sim, nao, t);
                                            }).then((value) => setState((){}));
                                          },
                                        ),
                                      )
                                    ],
                                  ),       
                                )         
                              ],
                            )
                          )                        
                        ]
                      ),
                    ),
                  ) 
                );
              }
            )
          ),
        )
      ],
    );
  } 
  
  void condicaoCategoria(String categoria, AppLocalizations t){
    if(categoria == t.ausCasamento || categoria == 'Casamento'){
      categoriaHistorico = t.ausCasamento;
    }
    else if(categoria == t.ausFalecimento || categoria == 'Falecimento'){
      categoriaHistorico = t.ausFalecimento;
    }
    else if(categoria == t.ausProvas || categoria == 'Provas de Avaliação'){
      categoriaHistorico = t.ausProvas;
    }
    else if(categoria == t.ausSaude || categoria == 'Saúde'){
      categoriaHistorico = t.ausSaude;
    } 
    else if(categoria == t.ausAcidente || categoria == 'Acidente'){
      categoriaHistorico = t.ausAcidente;
    }
    else if(categoria == t.ausReuniao || categoria == 'Casamento'){
      categoriaHistorico = t.ausReuniao;
    }
    else if(categoria == t.ausOutro || categoria == 'Outro'){
      categoriaHistorico = t.ausOutro;
    }
    else if(categoria == t.ausMotivosPessoais || categoria == 'Motivos Pessoais'){
      categoriaHistorico = t.ausMotivosPessoais;
    }
    else if(categoria == t.ausMotivosPessoais || categoria == 'Férias'){
      categoriaHistorico = t.menuFeria;
    }
    else{
      categoriaHistorico = 'Sem categoria';
    }
  }

  //O mesmo se aplica ao caso de cima
  void traduzDesconto(String? desconto, AppLocalizations t) {
    if(desconto == t.ausBanco || desconto == 'Banco de Horas'){
      descontoString = t.ausBanco;
    }
    else if(desconto == t.ausOrdenando || desconto == 'Ordenado'){
      descontoString = t.ausOrdenando;
    }
    else{
      descontoString = t.menuFeria;
    }
  }
  
  bool verificaConflito(Ausencia ausencia) {
    DateTime now = DateTime.now();

    //Pergunta se o agora é antes do acontecimento
    if(now.compareTo(ausencia.periodo.startDate!) < 0 && now.compareTo(ausencia.periodo.startDate!) < 0){
      return true;
    }
    else{
      return false;
    } 
  }
}


