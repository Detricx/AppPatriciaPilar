import 'package:drh_project/services/http_connections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget feedbackBox(BuildContext context, String ctb, List items){

  var t = AppLocalizations.of(context)!;
  final controllerFeedback = TextEditingController();
  String? selected = items[0];

  String feedback = '';
  int ranking = 3;
  bool condicao = false;
  FocusNode focus = FocusNode();
  focus.requestFocus();

  carregarPagina(){
    Navigator.of(context).pop();
  }

  return StatefulBuilder(
    builder: (context, setState) {
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
              height: 570,
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    //Título 
                    const Text(
                      'Feedback', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                      fontFamily: 'DaysOne',
                        fontSize: 35,
                        color: Colors.black
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(t.feedBackTexto, 
                        textAlign: TextAlign.center, 
                        style: const TextStyle(
                          fontFamily: 'Gantari',
                          fontSize: 15,
                          color: Colors.black
                        ),
                      ),
                    ),
    
                    RatingBar(
                      glowColor: Colors.amber,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 5),
                      minRating: 0,
                      maxRating: 5,
                      initialRating: 3,
                      ratingWidget: RatingWidget(
                        full: const Icon(Icons.star, color: Colors.amber), 
                        half : const Icon(Icons.star, color: Colors.amber), 
                        empty : const Icon (Icons.star, color : Colors.grey),
                      ),
                      onRatingUpdate: (value){
                        ranking = value.toInt();
                      }
                    ),
    
                    Padding(  
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: InkWell(
                        child: Container(
                          height: 150.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration( 
                            border: Border.all(color: const Color.fromARGB(255, 102, 69, 62)),
                            color: const Color.fromARGB(255, 250, 250, 250),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              focusNode: focus,
                              controller: controllerFeedback,
                              style: const TextStyle(
                                color:Colors.black,
                                fontSize: 17.0,  
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              onChanged: (value){
                                feedback = value;
                              },
                            ), 
                          )
                        ),
                        onTap: (){
                          focus.requestFocus();
                        }
                      ),
                    ),
    
                    ListTileSwitch(  
                      value: condicao,  
                      leading: Icon(
                        condicao ? Icons.account_box : Icons.help_center,
                        size: 30,
                      ),  
                      onChanged: (value) {  
                        setState(() {  
                        condicao = value;  
                        });
                      },
                      visualDensity: VisualDensity.compact,
                      switchType: SwitchType.cupertino,
                      switchActiveColor: Colors.brown[800],  
                      title: Text(
                        condicao ? t.feedBackEscolha(0) : t.feedBackEscolha(1),
                        style: const TextStyle(
                          fontFamily: 'Gantari',
                          fontSize: 12,
                          color: Colors.black
                        ),
                      ),  
                    ),
    
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 40.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        decoration: BoxDecoration(
                          
                          border: Border.all(color: const Color.fromARGB(255, 102, 69, 62)),
                          color: const Color.fromARGB(255, 250, 250, 250),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          value: selected,
                          isExpanded: true,
                          items: items.map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                color:Colors.black,
                                fontSize: 20,  
                                fontFamily: 'Gantari'
                              ),
                            ),
                          )).toList(),
                          onChanged: (valor){
                            setState(() {
                              selected = valor;
                            });
                          }
                        )
                      ),
                    ),
                
                    const Spacer(),
    
                    //Botão
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.brown[800]),
                                enableFeedback: true,
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                minimumSize: MaterialStateProperty.all(const Size(150, 35)),
                              ),
    
                              child: Text(
                                t.escolhaSubmeter, 
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              onPressed: () async{ 
                                //Remover o fundo
                                if(feedback.isNotEmpty){
                                  if(await HttpServicesProject.storeFeedbackInDataBase(ctb, feedback, ranking, selected!, condicao)){
                                    carregarPagina();
                                  }
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(t.feedErroTexto),
                                    )
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.brown[800]),
                                enableFeedback: true,
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                minimumSize: MaterialStateProperty.all(const Size(150, 35)),
                              ),
    
                              child: Text(t.escolhaVoltar, 
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              onPressed: () { 
                                //Remover o fundo
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                        ],
                      ),
                    )                
                  ],
                ),
              ),
            ),
            
            Positioned(
              top: -60,
              child: CircleAvatar(
                backgroundColor: Colors.brown[800],
                radius: 60,
                child: const Icon(
                  Icons.feed, 
                  color: Colors.white, 
                  size: 65
                ),
              )
            ),
          ],
        )
      );
    }
  );
}