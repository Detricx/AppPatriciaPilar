import 'dart:convert';
import 'package:drh_project/models/ausencia.dart';
import 'package:drh_project/models/funcionario.dart';
import 'package:drh_project/services/definir_url.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/decision_box.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AprovacoesScreen extends StatefulWidget {
  final String nif;
  final List<DateTime> feriados;
  const AprovacoesScreen({Key? key, required this.nif, required this.feriados}) : super(key: key);

  @override
  State<AprovacoesScreen> createState() => _AprovacoesScreenState();
}

class _AprovacoesScreenState extends State<AprovacoesScreen> {
  
  late List<Funcionario> equipaFerias = [];
  late List<Funcionario> equipaAusencias = [];
  late List<Funcionario> equipaRecusacoes = [];
  late final Key orderKey;

  @override
  void initState() {
    orderKey = ObjectKey(equipaFerias);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(t.menuAprovacoes, 25, false, 260, explicacao: t.explicAprov),
        body: fundoApp(
          'assets/fundos/fundo_calendario.png',
          60,
          Expanded(
            child: Column(
              children: [
                /*//!FUTURE UPDATE 
                Expanded(
                  flex: 0,
                  child: Row(
                    children: [
                      
                      Expanded(
                        child: FloatingActionButton.extended(
                          heroTag: null,
                          backgroundColor: Colors.brown[800],
                          label: const Text('Criar regras'),
                          onPressed: (){
                            Navigator.push(context, animacaoTela(RegrasScreen(listagemFuncionarios: equipa)));
                          }
                        ),
                      ),
                
                      const SizedBox(width: 10),
                      
                      Expanded(
                        child: FloatingActionButton.extended(
                          heroTag: null,
                          backgroundColor: Colors.brown[800],
                          label: const Text('Exibir equipa'),
                          onPressed: (){
                            Navigator.push(context, animacaoTela(EquipaScreen(condicaoAppBar: false, nif: widget.nif)));
                          }
                        ),
                      )
                      
                    ],
                  ),
                ),
                */
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: TabBar(  
                      tabs: [
                        Text(
                          t.menuFeria,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            color: Colors.black,
                            fontSize: 14,
                          )
                        ),
                        Text(
                          t.menuAusencia,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            color: Colors.black,
                            fontSize: 14,
                          )
                        ),  
                        Text(
                          t.menuRecusacao,
                          style: const TextStyle(
                            fontFamily: 'Gantari',
                            color: Colors.black,
                            fontSize: 14,
                          )
                        ),
                      ],  
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          key: ObjectKey(orderKey),
                          future: receberDadosEquipa(t),
                          builder:(context, snapshot){
                            switch(snapshot.connectionState){
                              case ConnectionState.done:
                              if(snapshot.hasData){
                                return TabBarView(
                                  children: [
                                    equipaFerias.isNotEmpty ?
                                    RefreshIndicator(
                                      onRefresh: swipeup,
                                      child: aprovaFalta(equipaFerias, widget.feriados, nifchefe: widget.nif)
                                    ) : 
                                    naoApresentaDados(t.menuFeria, t),

                                    equipaAusencias.isNotEmpty ?
                                    RefreshIndicator(
                                      onRefresh: swipeup,
                                      child: aprovaFalta(equipaAusencias, widget.feriados, nifchefe: widget.nif)
                                    ) :
                                    naoApresentaDados(t.menuAusencia, t),

                                    equipaRecusacoes.isNotEmpty ?
                                    RefreshIndicator(
                                      onRefresh: swipeup,
                                      child: aprovaFalta(equipaRecusacoes, widget.feriados, nifchefe: widget.nif)
                                    ) : 
                                    naoApresentaDados('Recusações', t),
                                  ],
                                );
                              }
                              //Caso não haja nem ausências, nem férias
                              else{
                                return naoApresentaDados(t.menuAprovacoes, t);
                              }
                      
                              default:
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
                          }
                        ),
                      )
                    ]
                  ),
                ),
              ]
            )
          ),
        )
      )
    );
  }

  Future<bool> receberDadosEquipa(AppLocalizations t) async{
    equipaFerias.clear();
    equipaAusencias.clear();
    equipaRecusacoes.clear();
    
    //Vai retornar uma lista de aprovações que ainda não passou por aprovação
    Uri url = definirUrl('ausencias/aprovacoes.php', widget.nif);
    http.Response data = await http.get(url);
    
    //Retornou utilizadores que precisam que lhes validem férias
    if(data.statusCode == 200){
      Map<String, dynamic> resposta = jsonDecode(data.body);
      List info = [];
      info = resposta['data'];
      
      for(int i = 0; i < info.length; i++){    
        //Variáveis para Utilizador
        String ncont = info[i][0].replaceAll(" ", "");
        String nome = info[i][1];
        List periodoFerias= info[i][2];

        //Lista de ausências de utilizador expecífico
        List<Ausencia> faltaFerias = [];
        List<Ausencia> faltaAusencias = [];
        List<Ausencia> faltaRecusacoes = [];


        for(int j = 0; j < periodoFerias.length; j++){
          String categoria = periodoFerias[j][0];
          String desconto = periodoFerias[j][1];
          String? motivo = periodoFerias[j][2];

          DateTime periodoInicial = DateTime.parse(periodoFerias[j][3]["date"]);
          DateTime periodoFinal = DateTime.parse(periodoFerias[j][4]["date"]);
          PickerDateRange periodo = PickerDateRange(periodoInicial, periodoFinal);
          
          int id = periodoFerias[j][5];
          List<dynamic>? documentos = periodoFerias[j][6];
          List<String> valores = agarrarCategoriaMaisDesconto(categoria, desconto, t);
          int nivel = periodoFerias[j][7];

          //! RECUSAR ESTA PARTE
          if(nivel == 4){
            faltaRecusacoes.add(Ausencia(periodo, valores[0], valores[1], motivo, id, documentos, nivel: nivel));
          }
          else{
            if(categoria == 'Férias' && (motivo == null || motivo == '')){
              faltaFerias.add(Ausencia(periodo, valores[0], valores[1], motivo, id, documentos, nivel: nivel));
            }
            else{
              faltaAusencias.add(Ausencia(periodo, valores[0], valores[1], motivo, id, documentos, nivel: nivel));
            }
          }
        }        
        
        //Adiciono a lista de funcionários com Férias
        if(faltaFerias.isNotEmpty){
          equipaFerias.add(
            Funcionario(
              ncont,
              nome,
              periodoAusencias: faltaFerias,
            )
          );
        }
      
        //Adiciono a lista de funcionários com Ausências
        if(faltaAusencias.isNotEmpty){
          equipaAusencias.add(
            Funcionario(
              ncont,
              nome,
              periodoAusencias: faltaAusencias,
            )
          );
        } 

        //Adiciono a lista de funcionários com Recusações
        if(faltaAusencias.isNotEmpty){
          equipaRecusacoes.add(
            Funcionario(
              ncont,
              nome,
              periodoAusencias: faltaRecusacoes,
            )
          );
        } 
      }

      return true;
    }
    else if(data.statusCode == 204){
      //Sem aprovações por fazer
      return false;
    }
    else{
      //Algo correu mal a verificar utilizadores que precisam de aprovação
      showDialog(barrierDismissible: true, context: context, builder: (context){
        return dialogBox(context, t.avisInesperado, t.errPHP23, 230, Icons.warning);
      });
      return false;
    }
  }

  List<String> agarrarCategoriaMaisDesconto(String categoria, String desconto, AppLocalizations t) {
    String categoriaHistorico, descontoString;

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
    else{
      categoriaHistorico = t.ausCasamento;
    }

    if(desconto == t.ausBanco || desconto == 'Banco de Horas'){
      descontoString = t.ausBanco;
    }
    else if(desconto == t.ausOrdenando || desconto == 'Ordenado'){
      descontoString = t.ausOrdenando;
    }
    else{
      descontoString = t.menuFeria;
    }

    return [categoriaHistorico, descontoString];
  }

  //O mesmo se aplica ao caso de cima
  void traduzDesconto(String? desconto, AppLocalizations t) {
    
  }

  Route<Object?> animacaoTela(tela) {
    int duracao = 300;
    return PageTransition(
      child: tela,
      type: PageTransitionType.fade,
      alignment: Alignment.topCenter,
      duration: Duration(milliseconds: duracao),
      reverseDuration: Duration(milliseconds: duracao),
    );
  }

  Future<void> swipeup() async{
    setState(() {
      
    });
  }
  
  Widget naoApresentaDados(String titulo, AppLocalizations t) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          width: 150,
          height: 150,
          child: Image.asset(
            'assets/icons/calendario/happy_face.png'
          ),
        ),
        const SizedBox(height: 20),
        Text(
          t.aprovaSemRegisto(titulo),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DaysOne',
            color: Colors.black,
            fontSize: 22,
          )
        ),
        const SizedBox(height: 20),
        Text(
          t.aprovaSemRegistoExplic,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Gantari',
            color: Colors.black,
            fontSize: 20,
          )
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: Text(
            t.aprovaAtualizar,
            style: TextStyle(
              fontFamily: 'Gantari',
              color: Colors.brown[800],
              fontSize: 20,
            )
          ),
          onTap: (){
            setState(() {});
          },
        ),
      ],
    );
  }
  
  aprovaFalta(List<Funcionario> equipaFerias, List<DateTime> feriados, {required String nifchefe}) {
    
    int diasParaTirar(PickerDateRange periodo) {
      DateTime inicio = periodo.startDate!;
      DateTime fim = periodo.endDate!;

      //Recebo a duração de diferença entre essas duas datas
      int diferencaDias = fim.difference(inicio).inDays; 
      int resultado = 0;

      //Captura feriados e fins-de-semana
      for(int i = 0; i < diferencaDias; i++){
        DateTime diaAtual = DateTime(inicio.year, inicio.month, inicio.day + i);
        if (diaAtual.weekday == DateTime.saturday || diaAtual.weekday == DateTime.sunday || widget.feriados.contains(diaAtual)) {
          resultado++;
        }
      }
      return (diferencaDias - resultado) + 1;
    }

    var t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MediaQuery.removeViewPadding(
            removeTop: true,
            removeBottom: false,
            context: context,
            child: ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: equipaFerias.length,
              itemBuilder: (context, i){
                Funcionario funcionario = equipaFerias[i];
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: funcionario.periodoAusencias!.length,
                  itemBuilder: (context, j){
                    Ausencia periodoAusencias = funcionario.periodoAusencias![j];
                    PickerDateRange periodo = periodoAusencias.periodo;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: funcionario.periodoAusencias!.length == 1 ? 25 : 0),
                      height: 420,
                      //! FAZER VERIFICAÇÃO CASO HAJA DUAS DATAS A COINCIDIREM
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        flipOnTouch: false,
                        front: cartaoFrente(funcionario, diasParaTirar(periodo), periodoAusencias, j, nifchefe, t),
                        back: cartaoTraz(),
                      ),
                    );
                  
                  }
                );
              }
            ),
          ),
        )
      ]
    ); 
  }
  
  Widget cartaoFrente(Funcionario funcionario, int diasParaTirar, Ausencia periodoAusencias, int index, String nifchefe, AppLocalizations t) {

    String periodoTempoString = '';
    bool temHoras = false;
    DateTime startDate = periodoAusencias.periodo.startDate!;
    DateTime endDate = periodoAusencias.periodo.endDate!;
  
    if('${startDate.day}-${startDate.month}-${startDate.year}' == '${endDate.day}-${endDate.month}-${endDate.year}'){
      temHoras = true;
      periodoTempoString = '${startDate.day}-${startDate.month}-${startDate.year} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}-${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
    }
    else{
      temHoras = false;
      periodoTempoString = '${startDate.day}-${startDate.month}-${startDate.year} ${endDate.day}-${endDate.month}-${endDate.year}';   
    }

    VoidCallback funcaoSim(String nif, int id, int nivel, AppLocalizations t, BuildContext tela, int nivelAusencia){
      //Mudar o nível da aprovação para o próximo (2)
      return () async{
        try{
          late Uri url;
          //No caso de estar a confirmar uma ausência ( 1 - 3 )
          if(nivelAusencia == 1){
            //O pedido foi recusado
            if(nivel == 0){
              url = definirUrl('ausencias/alter_nivel.php', nif, campo2: '$id', campo3: '$nivel');
            }
            else{
              url = definirUrl('ausencias/alter_nivel.php', nif, campo2: '$id', campo3: '2');
            }
          }
          //No caso de estar a confirmar uma recusação
          else{ 
            if(nivel == 0){
              url = definirUrl('ausencias/alter_nivel.php', nif, campo2: '$id', campo3: '7');
            }
            else{
              url = definirUrl('ausencias/alter_nivel.php', nif, campo2: '$id', campo3: '5');
            }
          }
          
          var request = http.Request('PUT', url);

          http.StreamedResponse response = await request.send();
          
          if(response.statusCode == 200){
            showDialog(barrierDismissible: true, context: context, builder: (tela){
              return dialogBox(tela, t.errPHP7, t.aprovaSalva, 180, Icons.thumb_up);
            }).then((value) =>  Navigator.pop(tela));
          }
          else{
            showDialog(barrierDismissible: true, context: context, builder: (tela){
              Navigator.pop(context);
              return dialogBox(tela, t.errErro, t.errPHP23, 230, Icons.thumb_up);
            });
          }
          
        }
        catch(e){
          debugPrint(e.toString());
        }
      };
    }

    VoidCallback funcaoNao(BuildContext context){
      //Colocar nível 0 para o Utilizador ver
      return (){
        Navigator.pop(context);
        
      };
    }
    
    Widget expecificDialog(Ausencia ausencia, BuildContext context, AppLocalizations t, String periodo) {

      TextEditingController controllerMotivo = TextEditingController(text: ausencia.motivo != '' ? ausencia.motivo : t.aprovaNaoMotivo);
      List<dynamic> documento = ausencia.documentos!;
      
      Future<void> galeriaFotos(BuildContext context) async{
        return await showDialog(context: context,
          builder: (context){
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
                              itemCount: documento.length,
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0.80,
                                childAspectRatio: 0.75,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              itemBuilder: ((context, index){
                                String path = documento[index];
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
        );
      }

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
          
        child: Stack(
          //Fará o alinhamento com a imagem que aparecerá
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            //Caixa branca
            SizedBox(
              height: 385,
              width: 400,
              //Onde colocarei as imagens
              child: Padding(
                padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Título 
                    Align(
                      child: Text(
                        t.aprovaAusencia,
                        textAlign: TextAlign.center, 
                        style: const TextStyle(
                        fontFamily: 'DaysOne',
                          fontSize: 24,
                          color: Colors.black
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      child: Text(
                        periodo,
                        textAlign: TextAlign.center, 
                        style: const TextStyle(
                        fontFamily: 'Gantari',
                          fontSize: 18,
                          color: Colors.black
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    RichText(
                      text: TextSpan(
                        text: t.aprovaCategoria,
                        style: const TextStyle(
                          fontFamily: 'DaysOne',
                          fontSize: 18,
                          color: Colors.black
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ausencia.categoria, 
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              fontSize: 15,
                              color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        text: t.aprovaDesconto,
                        style: const TextStyle(
                          fontFamily: 'DaysOne',
                          fontSize: 18,
                          color: Colors.black
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ausencia.desconto, 
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              fontSize: 15,
                              color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    Align(
                      child: Text(
                        t.aprovaMotivo,
                        style: const TextStyle(
                          fontFamily: 'DaysOne',
                          fontSize: 18,
                          color: Colors.black
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5), 
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: SingleChildScrollView(
                          child: TextFormField(
                            readOnly: true,
                            enabled: false,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: controllerMotivo,
                            style: const TextStyle(
                              color:Colors.black,
                              fontSize: 14.0,  
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ), 
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            Positioned(
              top: -30,
              right: -15,
              child: CircleAvatar(
                backgroundColor: Colors.brown[800],
                radius: 40,
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white, 
                  size: 45
                ),
              )
            ),

            Positioned(
              bottom: -20,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.brown[800],
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text('Ok')
                ),
                onPressed: (){
                  Navigator.pop(context);
                }
              ),
            ),

            Positioned(
              top: 0,
              left: 1,
              child: Row(
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    backgroundColor: Colors.brown[800],
                    child: const Icon(Icons.description),
                    onPressed: (){
                      if(ausencia.documentos != null && ausencia.documentos!.isNotEmpty){
                        galeriaFotos(context).then((value) {setState(() {});});
                      } 
                    }
                  ),
                  const SizedBox(width: 5),
                  Text(
                    t.aprovaDocs(ausencia.documentos!.length, ausencia.documentos!.length),
                    style: const TextStyle(
                      fontFamily: 'Gantari',
                      color: Colors.black,
                      fontSize: 15,
                    )
                  )
                ],
              )
            ),
          ],
        )
      ); 
    }

    return Card(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipOval(
                      child: Image.network(
                        'http://192.168.26.146/projects/flutter/drh_project/images/app/pessoal/${funcionario.nif}.jpg',
                        key: UniqueKey(),
                        fit: BoxFit.cover,
                        width: 250.0,
                        height: 250.0,
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
                          return ClipOval(
                            child: Image.asset(
                              'assets/icons/foto_null.png',
                              width: 250.0,
                              height: 250.0,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            periodoTempoString,
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              color: Colors.black,
                              fontSize: 13,
                            )
                          ),
                    
                          Text(
                            funcionario.nome,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                    
                          Text(
                            t.aprovaDias(diasParaTirar, diasParaTirar),
                            style: const TextStyle(
                              fontSize: 15, 
                            ),
                          ),
                    
                          //! Quando o Coordenador confirma a marcação
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: FloatingActionButton.small(
                                  heroTag: null,
                                  backgroundColor: Colors.brown[800],
                                  onPressed: (){
                                    showDialog(barrierDismissible: true, context: context, builder: (context){
                                      return decisionBox(context, t.aprovaAprovar, t.aprovaFeriasUtilizador(funcionario.nome), 280, Icons.help, funcaoSim(nifchefe, funcionario.periodoAusencias![index].id, 2, t, context, funcionario.periodoAusencias![index].nivel), funcaoNao(context), t);
                                    }).then((value) => setState((){}));
                                  },
                                  child: const Icon(Icons.done)
                                ),
                              ),
                    
                              //! Pedido Recusado e deve voltar para o Utilizador
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: FloatingActionButton.small(
                                  heroTag: null,
                                  backgroundColor: Colors.brown[800],
                                  onPressed: (){
                                    showDialog(barrierDismissible: true, context: context, builder: (context){
                                      return decisionBox(context, t.aprovaRecusar, t.aprovaMarcarNovo(funcionario.nome), 280, Icons.help, funcaoSim(nifchefe, funcionario.periodoAusencias![index].id, 0, t, context, funcionario.periodoAusencias![index].nivel), funcaoNao(context), t);
                                    }).then((value) => setState((){}));
                                  },
                                  child: const Icon(Icons.close)
                                ),
                              ),

                              Visibility(
                                visible: periodoAusencias.motivo != null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: FloatingActionButton.small(
                                    heroTag: null,
                                    backgroundColor: Colors.brown[800],
                                    onPressed: (){
                                      showDialog(barrierDismissible: true, context: context, builder: (context){
                                        return expecificDialog(periodoAusencias, context, t, periodoTempoString);
                                      });
                                    },
                                    child: const Icon(Icons.info_outline)
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ),
                ]
              ),
            ),
            const SizedBox(height: 0),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: SfDateRangePickerTheme(
                  data: SfDateRangePickerThemeData(),
                  child: AbsorbPointer(
                    child: SfDateRangePicker(
                      selectionMode: DateRangePickerSelectionMode.range,
                      minDate: startDate,
                      maxDate: temHoras ? startDate.add(const Duration(seconds: 1)) : endDate,
  
                      toggleDaySelection: false,
                      showActionButtons: false,
                      
                      enableMultiView: (startDate.month != endDate.month),
                      
                      navigationDirection:DateRangePickerNavigationDirection.horizontal,
                      navigationMode: DateRangePickerNavigationMode.scroll,
  
                      //Desaparecer com as semanas em cima
                      monthViewSettings: const DateRangePickerMonthViewSettings(viewHeaderHeight: 0),
                      
                      //Data inicial instânciada
                      initialSelectedRange: periodoAusencias.periodo,
  
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
                    ),
                  )
                )
              ),
            ),
          ],
        )
      )
    );
  }
  
  Widget cartaoTraz() {
    return Container();
  }
}