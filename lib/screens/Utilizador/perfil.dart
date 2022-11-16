import 'package:drh_project/services/http_connections.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PerfilScreen extends StatefulWidget {
  final String nome, profissao;
  final String? cargo;
  final String nifEmpresa;
  const PerfilScreen(this.nifEmpresa, { Key? key, required this.cargo, required this.nome, required this.profissao }) : super(key: key);
  
  
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  String nome = '', profissao = '', ctb = '';
  String? tituloErro, erro, area;
  late XFile documento;
  DefaultCacheManager manager = DefaultCacheManager();
  
  @override
  void initState() {
    nome = widget.nome;
    profissao = widget.profissao;
    area = widget.cargo;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/fundos/fundo_perfil.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return fundoApp(
      'assets/fundos/fundo_perfil.png', 
      10,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            //Nome
            Expanded(
              flex: 1,
              child: Align(
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    InkWell(
                      child: ClipOval(
                        child: Image.network(
                          HttpServicesProject.urlNif,
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

                      onTap: (){
                        showModalBottomSheet<void>(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                                borderRadius: const BorderRadius.all(Radius.circular(30))
                              ),
                              height: 300,
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 100),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    t.txtDefinicaoFotografia,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    t.txtAcaoFotografia,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Gantari',
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              t.btRemover,
                                              style: const TextStyle(
                                                fontFamily: 'Gantari',
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                            FloatingActionButton.small(
                                              heroTag: null,
                                              backgroundColor: Colors.brown[800],
                                              child: const Icon(Icons.delete),                                        
                                              onPressed: (){
                                                showDialog(barrierDismissible: true, context: context, builder: (context){
                                                  return retornarPergunta(context, t.txtEliminarFotografia, 2, '', t);
                                                }).then((value) => clearCache());
                                              }
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                                t.btCamara,
                                                style: const TextStyle(
                                                  fontFamily: 'Gantari',
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            FloatingActionButton.small(
                                              heroTag: null,
                                              backgroundColor: Colors.brown[800],
                                              child: const Icon(Icons.camera),
                                              onPressed:() async{
                                                final ImagePicker picker = ImagePicker();
                                                try{
                                                  //Dá para colocar em vez de galeria ser através da câmara
                                                  XFile? file = await picker.pickImage(source: ImageSource.camera);
                                                  
                                                  //Verifico se o documento retornar null para não dar erro
                                                  if(file != null){
                                                    documento = file;
                                                    //Guardar Fotografia
                                                    showDialog(barrierDismissible: true, context: context, builder: (context){
                                                      return retornarPergunta(context, t.txtAdicionarFotografia, 1, documento.path, t);
                                                    }).then((value) => clearCache());
                                                  } 
                                                }
                                                catch(e){
                                                  // ignore: avoid_print
                                                  print(e);
                                                }
                                              }
                                            )
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              t.btGaleria,
                                              style: const TextStyle(
                                                fontFamily: 'Gantari',
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),

                                            FloatingActionButton.small(
                                              heroTag: null,
                                              backgroundColor: Colors.brown[800],
                                              child: const Icon(Icons.collections),
                                              onPressed:() async{
                                                final ImagePicker picker = ImagePicker();
                                                try{
                                                  //Dá para colocar em vez de galeria ser através da câmara
                                                  XFile? file = await picker.pickImage(source: ImageSource.gallery);
                                                  
                                                  //Verifico se o documento retornar null para não dar erro
                                                  if(file != null){
                                                    documento = file;
                                                    //Guardar Fotografia
                                                    showDialog(barrierDismissible: true, context: context, builder: (context){
                                                      return retornarPergunta(context, t.txtAdicionarFotografia, 1, documento.path, t);
                                                    }).then((value) => clearCache());
                                                  } 
                                                }
                                                catch(e){
                                                  // ignore: avoid_print
                                                  print(e);
                                                }
                                              }
                                            )
                                          ],
                                        ),
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            );
                          },
                        );
                      },
                    ),
                    
                    Visibility(
                      visible: area != "",
                      child: Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                          width: 40,
                          height: 40,
                        )
                      ),
                    ),
                    
                    Visibility(
                      visible:  area != "",
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          child: const Icon(
                            Icons.verified,
                            size: 60,
                            color: Colors.blue,
                            shadows: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.5,
                              )
                            ]
                          ),
                          onTap: (){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(t.avsCoordenador(area!)),
                              )
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              flex: 0,
              child: Align(
                child: Text(
                  nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Gantari',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  )
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Align(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  width: double.infinity,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/icons/logos/${widget.nifEmpresa}.jpg')
                    ),
                  ),
                ),
              )
            ),
          ],
        )
      )
    );
  }

  Dialog retornarPergunta(BuildContext context, String msg, int tipo, String caminhoFoto, AppLocalizations t){
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
            height: 300,
            //Onde colocarei as imagens
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  //Título 
                  Text(
                    t.tituloConfirmacao, 
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

                            child: Text(t.sim, 
                              style: const TextStyle(
                                color: Colors.white
                              ),
                            ),
                            onPressed: () { 
                              //Adicionar uma fotografia
                              if(tipo == 1){
                                HttpServicesProject.storeImageSystem(ctb, caminhoFoto).then((value) {
                                  clearCache();
                                  Navigator.of(context).pop();
                                });
                              }
                              //Apagar fotografia
                              else{
                                HttpServicesProject.deleteImageSystem(ctb).then((value) {
                                  clearCache();
                                  Navigator.of(context).pop();
                                });
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

                            child: Text(t.nao, 
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
                Icons.contact_mail, 
                color: Colors.white, 
                size: 65
              ),
            )
          ),
        ],
      )
    ); 
  }

  void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    setState(() {});
  }
}