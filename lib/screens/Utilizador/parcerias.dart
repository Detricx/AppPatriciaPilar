import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drh_project/models/descontos.dart';
import 'package:drh_project/models/parcerias.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ParceriasScreen extends StatefulWidget {
  final String nif, nifEmpresa, nome, numeroFuncionario;
  const ParceriasScreen(this.nifEmpresa, {Key? key, required this.nif, required this.nome, required this.numeroFuncionario}) : super(key: key);
  
  @override
  State<ParceriasScreen> createState() => _ParceriasScreenState();
}

class _ParceriasScreenState extends State<ParceriasScreen> {


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_parceria.png'), context);
  }

  @override
  void initState() {
    dataFuture = carregarParcerias(widget.nif);
    super.initState();
  }

  List<Parceria> parcerias = [];
  late List dadosParceria, dadosDesconto;
  late String erro, titulo;
  late Future<bool?> dataFuture;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return fundoApp(
      'assets/fundos/fundo_parceria.png', 
      10,
      Expanded(
        child: Column(
          children: [
            FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.brown[800],
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context){
                      var t = AppLocalizations.of(context)!;
                      List<String> nomes = widget.nome.split(" ");
                      return Scaffold(
                        resizeToAvoidBottomInset: false,
                        extendBodyBehindAppBar: true,
                        appBar: CustomAppBar(t.parCartao, 25, false, 200, explicacao: t.explicCartao),
                        body: fundoApp('assets/fundos/fundo_parceria.png', 40, 
                          Expanded(
                            child: Stack(
                              children: [
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 50),
                                    child: FlipCard(
                                      direction: FlipDirection.HORIZONTAL,
                                      front: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 0.8,
                                            color: Colors.black,
                                          )
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 80,
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Color.fromARGB(255, 149, 203, 73),
                                                    Color.fromARGB(255, 11, 76, 32),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20)
                                                ),
                                              ),
                                              margin: const EdgeInsets.all(20),
                                              
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '${nomes.first} ${nomes.last}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 12, 
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'DaysOne'
                                                          ),
                                                        ),
                                                        
                                                        const SizedBox(height: 3),

                                                        const Text(
                                                          'Frutas Patricia Pilar',
                                                          style: TextStyle(
                                                            fontSize: 12, 
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Gantari'
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Image.asset(
                                                      height: 80,
                                                      width: 80,
                                                      "assets/icons/logos/logos_pb/${widget.nifEmpresa}.png",
                                                      fit: BoxFit.contain,
                                                      alignment: Alignment.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text.rich(
                                                    TextSpan(
                                                      text: t.parColaborador,
                                                      style: TextStyle(
                                                        fontSize: 15, 
                                                        color: Colors.green[600],
                                                        fontFamily: 'DaysOne'
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: widget.numeroFuncionario,
                                                          style: TextStyle(
                                                            fontSize: 15, 
                                                            color: Colors.green[600],
                                                            fontFamily: 'DaysOne'
                                                          ),
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                                  Text.rich(
                                                    TextSpan(
                                                      text: t.parContribuinte,
                                                      style: TextStyle(
                                                        fontSize: 15, 
                                                        color: Colors.green[600],
                                                        fontFamily: 'DaysOne'
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: widget.nif,
                                                          style: TextStyle(
                                                            fontSize: 15, 
                                                            color: Colors.green[600],
                                                            fontFamily: 'DaysOne'
                                                          ),
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),

                                                  Text(
                                                    t.parCondicao,
                                                    style: TextStyle(
                                                      fontSize: 10, 
                                                      color: Colors.green[600],
                                                      fontFamily: 'DaysOne'
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),
                                                  
                                                  Text(
                                                    'Grupo Patricia Pilar',
                                                    style: TextStyle(
                                                      fontSize: 15, 
                                                      color: Colors.brown[900],
                                                      fontFamily: 'DaysOne'
                                                    ),
                                                  ),

                                                  const SizedBox(height: 5),

                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Rua Poço de Arroz, nº2, Casal da Lapa',
                                                              style: TextStyle(
                                                                fontSize: 10, 
                                                                color: Colors.brown[900],
                                                                fontFamily: 'Gantari'
                                                              ),
                                                            ),
                                                            Text(
                                                              '2560-030 A-dos-Cunhados, Torres Vedras',
                                                              style: TextStyle(
                                                                fontSize: 10, 
                                                                color: Colors.brown[900],
                                                                fontFamily: 'Gantari'
                                                              ),
                                                            ),
                                                            Text(
                                                              'geral@patriciapilar.pt | +351 261 982 465',
                                                              style: TextStyle(
                                                                fontSize: 10, 
                                                                color: Colors.brown[900],
                                                                fontFamily: 'Gantari'
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              'geral@patriciapilar.pt',
                                                              style: TextStyle(
                                                                fontSize: 15, 
                                                                color: Colors.brown[900],
                                                                fontFamily: 'Gantari'
                                                              ),
                                                            ),
                                                            Text(
                                                              'www.patriciapilar.pt',
                                                              style: TextStyle(
                                                                fontSize: 15, 
                                                                color: Colors.brown[900],
                                                                fontFamily: 'Gantari'
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      back: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 0.8,
                                            color: Colors.black,
                                          )
                                        ),
                                        child:Image.asset(
                                          "assets/fundos/cartaoColaborador.png",
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        )
                      );
                    }
                  )
                );
              },
              label: Text(
                t.showcard,
                style: const TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gantari'
                ),
              )
            ),

            const SizedBox(height: 10),
            FutureBuilder(
              future: dataFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState){
                  case ConnectionState.waiting:
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
                  
                  case ConnectionState.done:
                    return ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: parcerias.length,
                    itemBuilder: (context, i){
                      return SizedBox(
                        height: 120,
                        child:  FlipCard(
                          direction: FlipDirection.VERTICAL,
                          front: FrenteCartao(parceria: parcerias[i]),
                          back: TraseiraCartao(parceria: parcerias[i]),
                        ),
                      );
                    }
                  );

                  default:{
                    return Container();
                  }
                }
              }
            ),
          ],
        )
      )
    );    
  }
  
  Future<bool> carregarParcerias(String ctb) async{
    parcerias.clear();

    //Vai buscar dados das parcerias
    Uri urlParceria = Uri.parse("http://192.168.26.146/projects/flutter/drh_project/recursosHumanos/parceria/parcerias.php?ctb=$ctb");
    http.Response dataParceria = await http.get(urlParceria);
    Map<String, dynamic> respostaParceria = jsonDecode(dataParceria.body);
    
    String recolherLinguaTeclado(){
      return AppLocalizations.of(context)!.localeName;
    }
    //Verifica o estado do erro
    switch (dataParceria.statusCode){
      case 200:

        String lingua = recolherLinguaTeclado();

        //Recolhe todos os dados das parcerias
        dadosParceria = respostaParceria["data"];
        for(int i = 0; i <= dadosParceria.length - 1; i++){
          int id = respostaParceria["data"][i][0];
          String? logo = 'http://192.168.26.146/projects/flutter/drh_project/images/app/feed/parcerias/${respostaParceria["data"][i][1]}';
          bool estado = (respostaParceria["data"][i][2] == 1);
          String nome = respostaParceria["data"][i][3];
          String morada = respostaParceria["data"][i][4];
          List contacto = respostaParceria["data"][i][5];
          String destinatario = '', tipoServico = '', categoria = '';
          
          if(lingua == 'pt'){
            destinatario = respostaParceria["data"][i][6];
            tipoServico = respostaParceria["data"][i][7];
            categoria = respostaParceria["data"][i][8];
          }
          else{
            destinatario = respostaParceria["data"][i][11];
            tipoServico = respostaParceria["data"][i][9];
            categoria = respostaParceria["data"][i][10];
          }
          
          //Faz outro ciclo para capturar todos os descontos das parcerias
          Uri urlDesconto = Uri.parse("http://192.168.26.146/projects/flutter/drh_project/recursosHumanos/parceria/descontos.php?ctb=$ctb&id=$id");
          http.Response dataDesconto = await http.get(urlDesconto);

          switch(dataDesconto.statusCode){
            case 200:
              List<DescontoParceria> descontos = [];
              //Converto para código legivél mais cedo, pois se for antes ele não consegue aceitar null
              Map<String, dynamic> respostaDesconto = jsonDecode(dataDesconto.body);
              dadosDesconto = respostaDesconto["data"];
              
              if(lingua == 'pt'){
                for(int j = 0; j <= dadosDesconto.length - 1; j++){
                  int idDesconto = respostaDesconto["data"][j][0];
                  String descricao = respostaDesconto["data"][j][1];
                  String? detalhe = respostaDesconto["data"][j][2];
                  String? tipo = respostaDesconto["data"][j][7];
                  String? desconto = (tipo == ' ' ? '' : respostaDesconto["data"][j][3].toString());

                  //Coloca toda a info aqui
                  descontos.add(DescontoParceria(idDesconto, descricao, detalhe, desconto, tipo));
                }
              }
              else{
                for(int j = 0; j <= dadosDesconto.length - 1; j++){
                  int idDesconto = respostaDesconto["data"][j][0];
                  String descricao = respostaDesconto["data"][j][4];
                  String? detalhe = respostaDesconto["data"][j][5];
                  String? tipo = respostaDesconto["data"][j][7];
                  String? desconto = (tipo == ' ' ? '' : respostaDesconto["data"][j][6].toString());

                  //Coloca toda a info aqui
                  descontos.add(DescontoParceria(idDesconto, descricao, detalhe, desconto, tipo));
                }
              }
              parcerias.add(Parceria(id, logo, estado, nome, morada, contacto, destinatario, tipoServico, categoria, descontos));
              
            break;
            case 204:
              parcerias.add(Parceria(id, logo, estado, nome, morada, contacto, destinatario, tipoServico, categoria, []));
              //Não apresenta descontos
            break;
            default:
              Map<String, dynamic> respostaDesconto = jsonDecode(dataDesconto.body);
              titulo = respostaDesconto["type"];
              erro = respostaDesconto["message"];
            break; 
          }
          
        }
      return true;

      case 401:
        //!Validar o token
      return false;

      default:
        titulo = respostaParceria["type"];
        erro = respostaParceria["message"];
      return false;
    }
  }
}

class FrenteCartao extends StatelessWidget {
  final Parceria parceria;
  const FrenteCartao({Key? key, required this.parceria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CachedNetworkImage(
                imageUrl: '${parceria.logo}',
                memCacheWidth: 500,
                memCacheHeight: 200,
                maxHeightDiskCache: 200,
                maxWidthDiskCache: 200,
                imageBuilder: (context, imageProvider) => Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider, 
                      fit: BoxFit.contain
                    ),
                  ),
                ),
                // Enquanto que espero que a imagem carregue
                placeholder: (context, url){
                  return Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                        
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey[400],
                      ),
                    )
                  );
                },
                errorWidget: (context, url, error) {
                  return const Image(
                    image: AssetImage('assets/icons/foto_null.png'),
                  );
                }
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      parceria.nome,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gantari'
                      ),
                    ),
                    Text(
                      parceria.categoria,
                      style: const TextStyle(
                        fontSize: 10, 
                        fontFamily: 'Gantari'
                      ),
                    ),
                    Text(
                      parceria.tipoServico,
                      style: const TextStyle(
                        fontSize: 10, 
                        fontFamily: 'Gantari'
                      ),
                    ),
                    Text(
                      parceria.morada,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 8, 
                        fontFamily: 'Gantari'
                      ),
                    ),
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class TraseiraCartao extends StatelessWidget {
  final Parceria parceria;
  const TraseiraCartao({Key? key, required this.parceria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown[800],
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    backgroundColor: Colors.white,
                    onPressed: (){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text(parceria.destinatario),
                        )
                      );
                    },
                    child: Icon(
                      ((parceria.destinatario == 'Todos os Colaboradores' || parceria.destinatario == 'All Employees') ? Icons.person : 
                      (parceria.destinatario == 'Todos os Colaboradores e elementos do agregado familiar' || parceria.destinatario == 'All Employees and members of the household') ? Icons.group : 
                      Icons.family_restroom),
                      color: Colors.brown[800],
                    ),
                  ),
                ]
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: parceria.descontos.length,
                      itemBuilder: (context, index){
                        String? detalhe = parceria.descontos[index]!.detalhe;
                        String? desconto = parceria.descontos[index]!.desconto;
                        String? tipo = parceria.descontos[index]!.tipo;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  parceria.descontos[index]!.descricao,
                                  style: const TextStyle(
                                    fontSize: 10, 
                                    color: Colors.white,
                                    fontFamily: 'Gantari'
                                  ),
                                ),
                              ),
                              
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: desconto,
                                          style: const TextStyle(
                                            fontSize: 15, 
                                            color: Colors.white,
                                            fontFamily: 'DaysOne'
                                          ),
                                        ),
                                        TextSpan(
                                          text: detalhe,
                                          style: const TextStyle(
                                            fontSize: 15, 
                                            color: Colors.white,
                                            fontFamily: 'DaysOne'
                                          ),
                                          recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                          }
                                        ),
                                        
                                        TextSpan(
                                          text: tipo,
                                          style: const TextStyle(
                                            fontSize: 15, 
                                            color: Colors.white,
                                          ),
                                        ),
                                      ]
                                    )
                                  )
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

