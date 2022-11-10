import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget decisionBox(BuildContext context, String titulo, String msg, double largura, IconData icon, VoidCallback sim, VoidCallback nao, AppLocalizations t){
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
          height: largura,
          //Onde colocarei as imagens
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              children: [
                //Título 
                Text(
                  titulo, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                  fontFamily: 'DaysOne',
                    fontSize: 35,
                    color: Colors.black
                  ),
                ),
                Padding(padding: const EdgeInsets.all(20),
                  child: Text( msg, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontFamily: 'Gantari',
                      fontSize: 15,
                      color: Colors.black
                    ),
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
                          
                          onPressed: sim,

                          child: Text(t.sim, 
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          )
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
                          onPressed: nao,

                          child: Text(t.nao, 
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          )
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
            child: Icon(
              icon, 
              color: Colors.white, 
              size: 65
            ),
          )
        ),
      ],
    )
  ); 
}