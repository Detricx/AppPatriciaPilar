import 'package:drh_project/models/funcionario.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';

class RegrasScreen extends StatefulWidget {
  final List<Funcionario> listagemFuncionarios;
  const RegrasScreen({Key? key, required this.listagemFuncionarios}) : super(key: key);


  @override
  State<RegrasScreen> createState() => _RegrasScreenState();
}

class _RegrasScreenState extends State<RegrasScreen> {
  
  String? _value;
  List<Funcionario> equipa = [];
  List<String> nomesEquipa = [];
  List<DropdownMenuItem<String>> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    equipa = widget.listagemFuncionarios;

    //! Converter os dados dos Funcionários em lista de DropdownMenuItem
    dropdownItems = List.generate(
      (equipa.length - nomesEquipa.length),
      (index){
        return DropdownMenuItem(
          value: equipa[index].nome,
          child: Text(
            equipa[index].nome,
          ),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
  
    String explicacao = 'Defina uma regra onde na validação de férias seja notificado caso os Utilizadores coincidem'; 

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(appBarText: 'Regras', tamanho: 25, condicao:false, tamanhoCaixa: 300, explicacao: explicacao),
      body: fundoApp(
        'assets/fundos/fundo_calendario.png',
        70,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Expanded(
                flex: 0,
                child: Row(
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
                          value: _value,
                          items: dropdownItems,
                          hint: const Text(
                            'Selecione Utilizador',
                            style: TextStyle(
                              fontFamily: 'Gantari',
                              color: Colors.grey,
                              fontSize: 16,
                            )
                          ),
                          underline: Container(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),

                          isExpanded: true,           

                          //Muda conforme a categoria seleciona
                          onChanged: (newValue) {
                            setState(() {
                              _value = newValue;
                            });
                          },    
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: FloatingActionButton.small(
                        heroTag: null,
                        backgroundColor: Colors.brown[800],
                        child: const Icon(Icons.person_add),
                        onPressed: (){
                          if(_value != null){
                            nomesEquipa.add(_value!);
                            setState(() {
                              //Não vai permitir valores repetidos
                              nomesEquipa = nomesEquipa.toSet().toList();
                            });
                          } 
                        }
                      )
                    )                  
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [
                      (nomesEquipa.isNotEmpty ? 
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Text(
                            'Lista de Usuários Selecionados',
                            style: TextStyle(
                              fontFamily: 'DaysOne',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ) : Container()
                      ), 
                      MediaQuery.removePadding(
                        context: context, 
                        removeBottom: true,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: nomesEquipa.length,
                          itemBuilder: (context, i){
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      //Espaçamento dentro da caixa
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 12 
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
                                      child: Text(
                                        nomesEquipa[i],
                                        style: const TextStyle(
                                            fontFamily: 'Gantari',
                                            color: Colors.black,
                                            fontSize: 16,
                                          )
                                      )
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: FloatingActionButton.small(
                                      heroTag: null,
                                      backgroundColor: Colors.brown[800],
                                      child: const Icon(Icons.close),
                                      onPressed: (){
                                        setState(() {
                                          nomesEquipa.removeAt(i);
                                        });
                                      }
                                    )
                                  )                  
                                ],
                              )
                            );
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: FloatingActionButton.extended(
                                heroTag: null,
                                backgroundColor: Colors.brown[800],
                                label: const Text('Incorporar Regra'),
                                onPressed: (){

                                }
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FloatingActionButton.extended(
                                heroTag: null,
                                backgroundColor: Colors.brown[800],
                                label: const Text('Limpar Utilizadores'),
                                onPressed: (){
                                  setState(() {
                                    nomesEquipa.clear();                                   
                                  });
                                } 
                              ),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                )
              ),
            ],
          )
        ),
      )
    );
  }
}

