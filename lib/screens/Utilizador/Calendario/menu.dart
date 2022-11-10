import 'package:drh_project/screens/Utilizador/Calendario/Equipa/aprovacoes.dart';
import 'package:drh_project/screens/Utilizador/Calendario/historico.dart';
import 'package:drh_project/screens/Utilizador/Calendario/ferias.dart';
import 'package:drh_project/screens/Utilizador/calendario/ausencias.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuScreen extends StatefulWidget {
  final String nif; 
  final String? cargo;
  const MenuScreen({ Key? key, required this.cargo, required this.nif}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  int contagemLista = 0;
  bool roda = false;

  //Listagens para manipular dados em cartões
  final List<FlipCardController> _controllerFlip = List.generate(4, (index) => FlipCardController());
  List<bool> virado = List.generate(4, (index) => false);
  List<double> tamanho = List.generate(4, (index) => 120);

  List<String> imagens = [
    'assets/icons/calendario/ausencia.png',
    'assets/icons/calendario/ferias.png',
    'assets/icons/calendario/historico.png',
    'assets/icons/calendario/equipa.png'
  ];

  @override
  void initState() {
    contagemLista = widget.cargo != '' ? 4 : 3;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_calendario.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    List<String> titulo = [
      t.menuAusencia1,
      t.menuFeria2,
      t.menuHistorico3,
      t.menuAprovacoes4
    ];

    List<String> explicacao = [
      t.explicAprov,
      t.explicFerias,
      t.explicHist,
      t.explicAprov
    ];

    return fundoApp(
      'assets/fundos/fundo_calendario.png',
      10,
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: contagemLista,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.all(5),
              child: FlipCard(
                controller: _controllerFlip[index],
                flipOnTouch: roda,
                front: InkWell(
                  child: Container(
                    color: Colors.white,
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Row(
                        children: <Widget> [
                          Image.asset(   
                            imagens[index],
                          ),
                          const SizedBox(width: 20),
                          //Título
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  child: SizedBox(
                                    width: 140,
                                    child: Text(
                                      titulo[index],
                                      style: TextStyle(
                                        fontFamily: 'DaysOne',
                                        fontSize: 20,
                                        color: Colors.brown[900],
                                      )
                                    ),
                                  ),
                                ),
                                //Butão da parte da frente que gira
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton.small(
                                    heroTag: null,
                                    backgroundColor: Colors.brown[800],
                                    child: const Icon(
                                      Icons.info
                                    ),
                                    onPressed: (){
                                      if(virado.contains(true)){
                                        for(int i = 0; i < virado.length; i++){
                                          if(virado[i] == true){
                                            _controllerFlip[i].toggleCard();
                                            virado[i] = false;
                                            setState(() => tamanho[i] = 120);
                                          }
                                          else{
                                            setState(() {
                                              switch(index){
                                                case 0:
                                                tamanho[index] = 150;
                                                break;

                                                case 1:
                                                tamanho[index] = 180;
                                                break;

                                                case 2:
                                                tamanho[index] = 120;
                                                break;

                                                default:
                                                tamanho[index] = 130;
                                                break;
                                              }
                                            });
                                          }
                                        }
                                      }
                                      roda = false;
                                      virado[index] = true;
                                      _controllerFlip[index].toggleCard();
                                    } 
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, 
                      animacaoTela(index)
                    );
                  },
                ),
                back: InkWell(
                  child: Container(
                    color: Colors.white,
                    height: tamanho[index],
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget> [
                          Expanded(
                            flex: 0,
                            child: Text(
                              titulo[index],
                              style: TextStyle(
                                fontFamily: 'DaysOne',
                                fontSize: 30,
                                color: Colors.brown[900],
                              )
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 0,
                            child: Text(
                              explicacao[index],
                              style: const TextStyle(
                                fontFamily: 'Gantari',
                                fontSize: 15,
                                color: Colors.black,
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: (){
                    //!Qualquer parte do layout de trás do cartão
                    roda = true;
                    virado[index] = false;
                    _controllerFlip[index].toggleCard();
                  },
                ),
                onFlip: (){
                  if(roda){
                    setState(() => tamanho[index] = 120);
                  }
                  else{
                    setState(() {
                      switch(index){
                        case 0:
                        tamanho[index] = 150;
                        break;

                        case 1:
                        tamanho[index] = 180;
                        break;

                        case 2:
                        tamanho[index] = 120;
                        break;

                        default:
                        tamanho[index] = 130;
                        break;
                      }
                    });
                  }
                },
              ),
            );
          }
        ),
      )
    );
  }
  
  PageTransition animacaoTela(int i){
    int duracao = 500;

    List<Widget> tela = [
      AusenciasScreen(nif: widget.nif, ausencia: null),
      FeriasScreen(ctb: widget.nif),
      HistoricoScreen(widget.nif),
      AprovacoesScreen(nif: widget.nif, feriados: const []),
    ];

    return PageTransition(
      child: tela[i],
      type: PageTransitionType.fade,
      alignment: Alignment.topCenter,
      duration: Duration(milliseconds: duracao),
      reverseDuration: Duration(milliseconds: duracao),
    );
  }
}

