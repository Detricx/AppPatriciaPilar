// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

Widget dialogBox(BuildContext context, String titulo, String msg, double largura, IconData icon ){
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 60, 15, 0),
            child: Column(
              children: [
                //! Título 
                Expanded(
                  flex: 0,
                  child: Text(
                    titulo, 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DaysOne',
                      fontSize: 25,
                      color: Colors.black
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Text( 
                      msg, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(
                        fontFamily: 'Gantari',
                        fontSize: 14,
                        color: Colors.black
                      ),
                    ),
                  )
                ),
                
                Expanded(
                  flex: 0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.brown[800]),
                      enableFeedback: true,
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      minimumSize: MaterialStateProperty.all(const Size(250, 35)),
                    ),

                    child: const Text('Ok', 
                      style: TextStyle(
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
          ),
        ),
        
        Positioned(
          top: -70,
          child: CircleAvatar(
            backgroundColor: Colors.brown[800],
            radius: 60,
            child: Icon(
              icon,
              color: Colors.white, 
              size: 80
            ),
          )
        ),
      ],
    )
  ); 
}
  