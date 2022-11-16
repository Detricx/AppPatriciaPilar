import 'package:drh_project/services/http_connections.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/dialog_box.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';

class MarcarEmentaScreen extends StatefulWidget {
  final String nif;
  final List<DateTime> diasMes;
  final List<List<dynamic>> ementa;
  const MarcarEmentaScreen({ Key? key, required this.nif, required this.diasMes, required this.ementa }) : super(key: key);
  
  @override
  State<MarcarEmentaScreen> createState() => _MarcarEmentaScreenState();
}

class _MarcarEmentaScreenState extends State<MarcarEmentaScreen> {
  
  DateTime now = DateTime.now();
  late List<DateTime> diasMes;

  //Crio uma listagem de 5 controladores + Uma listagem das
  late final List<TextEditingController> _controladorSegunda, _controladorTerca, _controladorQuarta, _controladorQuinta, _controladorSexta;
  late final List<List<List<TextEditingController>>> controladorSemana;
  late int pagina, selected = 0;
  late List<FocusNode> listFocusNode;
  bool condicao = false;

  @override
  void initState() {
    listFocusNode = List.generate(4, (index) => FocusNode());
    diasMes = widget.diasMes;
    _controladorSegunda = List.generate(4, (i) => TextEditingController(text: widget.ementa[0][i]));
    _controladorTerca = List.generate(4, (i) => TextEditingController(text: widget.ementa[1][i]));
    _controladorQuarta = List.generate(4, (i) => TextEditingController(text: widget.ementa[2][i]));
    _controladorQuinta = List.generate(4, (i) => TextEditingController(text: widget.ementa[3][i]));
    _controladorSexta = List.generate(4, (i) => TextEditingController(text: widget.ementa[4][i]));
    controladorSemana = [
      [
        _controladorSegunda, 
        _controladorTerca, 
        _controladorQuarta, 
        _controladorQuinta,
         _controladorSexta
      ],
      [
        List.generate(4, (i) => TextEditingController(text: widget.ementa[4][i] ?? '')),List.generate(4, (i) => TextEditingController(text: widget.ementa[5][i] ?? '')), 
        List.generate(4, (i) => TextEditingController(text: widget.ementa[6][i] ?? '')), List.generate(4, (i) => TextEditingController(text: widget.ementa[7][i] ?? '')), 
        List.generate(4, (i) => TextEditingController(text: widget.ementa[8][i] ?? ''))
      ],
      [
        List.generate(4, (i) => TextEditingController(text: widget.ementa[9][i] ?? '')),List.generate(4, (i) => TextEditingController(text: widget.ementa[10][i] ?? '')), 
        List.generate(4, (i) => TextEditingController(text: widget.ementa[11][i] ?? '')), List.generate(4, (i) => TextEditingController(text: widget.ementa[12][i] ?? '')), 
        List.generate(4, (i) => TextEditingController(text: widget.ementa[13][i] ?? ''))
      ],
    ];

    if(diasMes.first.isBefore(now)){
      pagina = 0;
    }
    else{
      if(now.add(const Duration(days: 7)).isAfter(diasMes.first)){
        pagina = 1;
      }
      else{
        pagina = 2;
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_refeitorio.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar('Ementa', 25, false, 300),
      body: fundoApp(
        'assets/fundos/fundo_calendario.png',
        60,
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Visibility(
                      visible: now.isBefore(diasMes.first),
                      child: FloatingActionButton.small(
                        heroTag: null,
                        backgroundColor: Colors.brown[800],
                        child: const Icon(Icons.chevron_left),
                        onPressed: (){
                          DateTime segunda = diasMes.first;
                          //0 -> Segunda | 4 -> Sexta
                          for(int i = 0; i <= 4; i++){
                            diasMes[i] = segunda.subtract(Duration(days: 7 - i));
                          }
                          pagina--;
                          setState((){});
                        }
                      ),
                    ),
                    
                    RichText(
                      text: TextSpan(
                        text: '${diasMes.first.day} / ${diasMes.first.month}',
                        style: const TextStyle(
                          fontFamily: 'Gantari',
                          fontSize: 25,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: ' - ', 
                          ),
                          TextSpan(
                            text: '${diasMes.last.day} / ${diasMes.last.month}',
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      //Mostra caso a data selecionada seja apenas mais que o agora + 7 dias
                      visible: diasMes.first.isBefore(now.add(const Duration(days: 7))),
                      child: FloatingActionButton.small(
                        heroTag: null,
                        backgroundColor: Colors.brown[800],
                        child: const Icon(Icons.chevron_right),
                        onPressed: (){
                          DateTime segunda = diasMes.first;
                          //0 -> Segunda | 4 -> Sexta
                          for(int i = 0; i <= 4; i++){
                            diasMes[i] = segunda.add(Duration(days: 7 + i));
                          }
                          pagina++;
                          setState((){});
                        }
                      ),
                    )
                  ],
                )
              ),
              Expanded(
              child: ListView.builder(
                key: Key('builder ${selected.toString()}'),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index){
                  return Card(
                    elevation: 8,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: ExpansionTile(
                      key: Key(index.toString()),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            //! Semana
                            ['Segunda-feira','Terça-feira','Quarta-feira','Quinta-feira', 'Sexta-feira'][index],
                            style: TextStyle(
                              fontFamily: 'DaysOne',
                              fontSize: 20,
                              color: Colors.brown[900],
                            )
                          ),
                          Text(
                            //! Semana
                            '${diasMes[index].day} / ${diasMes[index].month}',
                            style: TextStyle(
                              fontFamily: 'DaysOne',
                              fontSize: 15,
                              color: Colors.brown[900],
                            )
                          ),
                        ],
                      ),

                      trailing: (
                        controladorSemana[pagina][index][0].text.isNotEmpty && 
                        controladorSemana[pagina][index][1].text.isNotEmpty && 
                        controladorSemana[pagina][index][2].text.isNotEmpty) ? 
                        null : Icon(Icons.warning, color: Colors.brown[800]
                      ),

                      //Caso se abra vai buscar a ementa, no contrário limpa os dados
                      onExpansionChanged: (value) {
                        condicao = value;
                      },
                      
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15, bottom: 20),
                          child: Column(
                            children: <Widget>[
                              TextBoxEmenta(controlador: controladorSemana[pagina][index][0], icon: Icons.soup_kitchen, prato: 'Sopa', focus: listFocusNode[0]),
                              TextBoxEmenta(controlador: controladorSemana[pagina][index][1], icon: Icons.kebab_dining, prato: 'Carne', focus: listFocusNode[1]),
                              TextBoxEmenta(controlador: controladorSemana[pagina][index][2], icon: Icons.set_meal, prato: 'Peixe', focus: listFocusNode[2]),
                              TextBoxEmenta(controlador: controladorSemana[pagina][index][3], icon: Icons.help, prato: 'Outro', focus: listFocusNode[3]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FloatingActionButton.extended(
                                    heroTag: null,
                                    backgroundColor: Colors.brown[800],
                                    label: const Text(
                                      'Guardar',
                                      style: TextStyle(
                                      fontFamily: 'DaysOne',
                                      fontSize: 15,
                                      color: Colors.white
                                      ),
                                    ),
                                    onPressed: () async{  
                                      for(int i = 0; i < listFocusNode.length; i++){
                                        listFocusNode[i].unfocus();
                                      }
    
                                      List<TextEditingController> lista = controladorSemana[pagina][index];
                                      List<String> ementaSemana = [lista[0].text, lista[1].text, lista[2].text, lista[3].text];
                                      DateTime dia = diasMes[index];
                                      if(await HttpServicesProject.updateEmenta(dia, ementaSemana)){
                                        showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, 'Sucesso', 'Dia ${dia.day} / ${dia.month} com ementa!', 170, Icons.thumb_up);
                                        });
                                      }
                                      else{
                                        showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, 'Algo correu mal', 'Verifique se não ficaram parâmetros por preencher', 230, Icons.warning);
                                        });
                                      }
                                      setState(() {
                                        if(condicao){
                                          selected--;
                                        }
                                        else{
                                          selected = index;
                                        }
                                      });
                                    }
                                  )
                                ],
                              )
                            ]
                          ),
                        )
                      ]
                    ),
                  );
                }
              ),
            ),
            ],
          ),
        )
      )
    );
  }
}

class TextBoxEmenta extends StatelessWidget {
  final IconData icon;
  final String prato;
  final FocusNode focus;
  final TextEditingController _controlador;

  const TextBoxEmenta({super.key, required TextEditingController controlador, required this.icon, required this.prato, required this.focus}) : _controlador = controlador;

  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration( 
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          focusNode: focus,
          keyboardType: TextInputType.visiblePassword,
          controller: _controlador,
          style: const TextStyle(
            color:Colors.black,
            fontSize: 17.0,
          ),
          decoration: InputDecoration(
            isDense: true,
            icon: Icon(
              icon,
              color: Colors.green[700],
              size: 30,
            ),
            hintText: prato,
            border: InputBorder.none,
          ),
          onChanged: (value){
            
          },
        ),
      ),
    );
  }
}