import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:drh_project/services/auth_bio.dart';
import 'package:drh_project/services/globals.dart' as globals;
import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart';
import 'package:drh_project/main.dart';
import 'package:drh_project/models/request_http.dart';
import 'package:drh_project/screens/Principal/equipa.dart';
import 'package:drh_project/screens/Principal/login.dart';
import 'package:drh_project/screens/Utilizador/Documents/menu_docs.dart';
import 'package:drh_project/services/awesome_notification.dart';
import 'package:drh_project/services/http_connections.dart';
import 'package:drh_project/services/shared_preferences.dart';

import 'package:drh_project/widgets/app_bar.dart';
import 'package:drh_project/widgets/decision_box.dart';
import 'package:drh_project/widgets/feedback_box.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:drh_project/screens/Utilizador/Calendario/menu.dart';
import 'package:drh_project/screens/Utilizador/feed.dart';
import 'package:drh_project/screens/Utilizador/parcerias.dart';
import 'package:drh_project/screens/Utilizador/perfil.dart';
import 'package:drh_project/screens/Utilizador/refeitorio.dart';

import 'package:drh_project/services/definir_url.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final RequestHttp info; 
  final String textAppBar;
  const HomeScreen({Key? key, required this.textAppBar, required this.info}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0, erroHttp = 200;
  DateTime lastPressed = DateTime.now();
  String nif = '', password = '';
  bool iconLogOut = true;

  //Desincriptação de password
  late String encrypt, iv16, chave, senha, textAppBar;
  late AesCrypt aes;

  late Timer tempo;
  final TextEditingController controllerPassword = TextEditingController();
  late final Future? myFuture;

  //Firebase
  late int totalNotifications;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState(){
    nif = widget.info.ctb;
    textAppBar = widget.textAppBar;
    myFuture = recolherDadosUtilizador();
  
    //Incorporo os serviços de notificação no dispositivo
    requestAndRegisterNotification();

    //Buscar o número de notificações ativas
    AwesomeNotifications().getGlobalBadgeCounter().then((value) => totalNotifications = value);

    //Verificar o token a cada 3 min
    refreshTimerToken(nif);

    super.initState();
  }

  @override
  void dispose() {
    //AwesomeNotifications().actionSink.close();
    //AwesomeNotifications().createdSink.close();
    super.dispose();
  }

  List<AssetImage> icons = const [
    AssetImage('assets/icons/menu/passivo/perfil.png'),
    AssetImage('assets/icons/menu/passivo/calendario.png'),
    AssetImage('assets/icons/menu/passivo/docs.png'),
    AssetImage('assets/icons/menu/passivo/feed.png'),
    AssetImage('assets/icons/menu/passivo/parcerias.png'),
    AssetImage('assets/icons/menu/passivo/refeitorio.png'),
    AssetImage('assets/icons/menu/ativo/perfil.png'),
    AssetImage('assets/icons/menu/ativo/calendario.png'),
    AssetImage('assets/icons/menu/ativo/docs.png'),
    AssetImage('assets/icons/menu/ativo/feed.png'),
    AssetImage('assets/icons/menu/ativo/parcerias.png'),
    AssetImage('assets/icons/menu/ativo/refeitorio.png'),
  ];

  late List<String> labelMenu, menuLabelLateral;

  List<IconData> menuIconsLateral = [
    Icons.group,
    //Icons.event_note,
    //Icons.help,
    Icons.question_answer,
    Icons.arrow_back,
    Icons.exit_to_app,
  ];

  @override
  //Carregar as imagens de forma rápida
  void didChangeDependencies() {
    super.didChangeDependencies();
    for(int i = 0; i < icons.length; i++){
      precacheImage(icons[i], context);
    }
    precacheImage(const AssetImage('assets/fundos/loading_screen.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    
    labelMenu = [
      t.labelMenuPerfil,
      t.labelMenuCalendarios,
      t.labelMenuDocumentos,
      t.labelMenuNoticias,
      t.labelMenuParceria,
      t.labelMenuRefeitorio,
    ];

    menuLabelLateral = [
      t.labelMenuEquipa,
      //t.labelMenuEventos,
      //t.labelMenuAjuda,
      t.labelMenuFeedback,
      t.labelMenuLogout,
      t.labelMenuSairApp,
    ];

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        //A parte superior disponibilizada pelo próprio telemóvel
        statusBarColor: Colors.brown[900],
        //systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.black
      )
    );
    
    //Widget direcionado para Android de quando retorna para trás
    return WillPopScope(
      onWillPop: () async{
        if(_currentIndex == 0){
          
          final Duration difference = DateTime.now().difference(lastPressed);
          final bool isExitWarning = difference >= const Duration(seconds: 2);

          lastPressed = DateTime.now();

          if(isExitWarning){
            Fluttertoast.showToast(
              msg: t.avisPressiona, 
              fontSize:15
            );
            return false;
          }
          else {
            Fluttertoast.cancel();
            return true;
          }
        }
        else{
          Fluttertoast.cancel();
          setState(() {
            textAppBar = t.labelMenuPerfil;
            _currentIndex = 0;
            iconLogOut = true;
          });
          return false;
        }
      },
      child: FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
            if(snapshot.hasError){
                return AlertDialog(
                title: Text(t.avisInesperado),
              );
            }
            else{
              if(snapshot.hasData){
                return retornoDeTelas(t);
              }
              return retornoDeTelas(t);
            }
            
            default:
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.green,
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ResizeImage(
                      AssetImage('assets/fundos/loading_screen.png'),
                      width: 720,
                      height: 1256
                    ),
                    fit: BoxFit.cover,
                    alignment: Alignment.center
                  )
                ),

                child:Center(
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
                )
              )
            );
          }
        }
      )
    );
  }

  Widget retornoDeTelas(AppLocalizations t){
    List<BottomNavigationBarItem> menu = [];
    //Gere a lista do menu para o utilizador
    List.generate(labelMenu.length, (index){
      menu.add(
        BottomNavigationBarItem( 
          icon: Badge(
            showBadge: false, //Desativa o badge
            animationDuration: const Duration(seconds: 1),
            //TODO contagem de notificações por fazer
            badgeContent: Text(
              totalNotifications.toString(),
              style: const TextStyle(
                fontFamily: 'DaysOne',
                fontSize: 15,
                color: Colors.white,
              )
            ),
            badgeColor: const Color.fromARGB(255, 0, 155, 62),
            child: CircleAvatar(
              radius: 25,
              //Fiz desta maneira porque no fim das contas, não contabilizo bem o "0", então caso dê 12 tenho de lhe dar um 11
              backgroundImage: (_currentIndex == index) ? icons[index] : icons[(index + 6) == 12 ?  11 : (index + 6)],
            ),
          ),
        label: labelMenu[index],
        )
      );
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(appBarText: textAppBar, tamanho: 30, condicao: true, tamanhoCaixa: 300),
      extendBody: true,
      body: Stack(
        //Ao invés de repetir o processo 6 vezes uso uma lista que fará a geração de todos os layouts
        children: List.generate(6,(index){
          var routeBuilders = _rotaSeleciona(context, index, t);

          //Retorna o layout selecionado no menu em baixo
          return Offstage(
            offstage: _currentIndex != index,
            child: FutureBuilder(
              //future: verificaToken(nif),
              builder: ((context, snapshot) {
                return Navigator(
                  //key: _navigatorKeys[index],
                  //Troco os widgets conforme o index (Vai "desaparecer" com os outros e mostrar o que está selecionado)
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) => routeBuilders[routeSettings.name]!(context),
                    );
                  },
                );
              }),
            ),
          );
        }),
      ),
      
      drawer: menuEsquerda(nif, widget.info.nome, widget.info.profissao, t),
      drawerEnableOpenDragGesture: true,
      bottomNavigationBar: menuBaixo(menu, t)
      
    );
  }

  //Recolher os dados do Utilizador associados ao contribuinte
  Future<bool> recolherDadosUtilizador() async {
    try{
      Uri url = definirUriGET('ctb_func.php', campo1: globals.id);
      http.Response data = await http.get(url);

      //Apenas verifico se está tudo a correr bem com o token
      switch(data.statusCode){
        case 200:
        return true;

        //Sessão expirada, deve dar refresh ao token
        case 401:
        return false;

        //Qualquer outro tipo de erro é suspeito e deve voltar para a tela de login
        default:
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginScreen(),
          ),
        );
        return false;
      }
    }
    catch(e){
      debugPrint(e.toString());
      return false;
    }
  }

  //Fechar o dialog
  void sairDialog(){
    return Navigator.of(context).pop();
  }

  //Retornar um SnackBar a indicar o problema
  dynamic retornarErro(String mensagem){
    return Flushbar(
      backgroundColor: Colors.brown[900]!,
      message: mensagem,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  //Criar uma mapeamento de listas das páginas
  Map<String, WidgetBuilder> _rotaSeleciona(BuildContext context, int index, AppLocalizations t) {
    RequestHttp info = widget.info;

    return {
      '/': (BuildContext context) {
        return [
          //! Colocar todas as variáveis necessárias
          PerfilScreen(info.empresa, nome: info.nome, cargo: info.area, profissao: info.profissao),
          MenuScreen(cargo: info.area),
          DocsScreen(info.empresa),
          const FeedScreen(),
          ParceriasScreen(info.empresa, nome: info.nome, numeroFuncionario: info.no.toString()),
          const RefeitorioScreen(),
        ].elementAt(index);
      },
    };
  }

  Widget menuBaixo(List<BottomNavigationBarItem> menu, AppLocalizations t) {
    return BottomNavigationBar(
      onTap: (index) async{
        //Verifica se o token está atualizado
        if(await verificarToken(nif)){
          autoRefreshToken(senha);
          setState(() {
            textAppBar = labelMenu[index];
            _currentIndex = index;
            iconLogOut = (index == 0) ? true : false;
          });
        }
        else{
          validarImpressaoDigital(senha);
          refreshToken(senha);
        }
      },

      currentIndex: _currentIndex,

      //Design
      elevation: 0,
      iconSize: 20.0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      
      backgroundColor: const Color(0x00ffffff),
      selectedItemColor: const Color.fromARGB(255, 72, 55, 41),

      //Opções
      items: menu
    );
  }

  Widget menuEsquerda(String nif, String nome, String profissao, AppLocalizations t){
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Parte de cima
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              color: Colors.brown[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  InkWell(
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 60),
                  Text(
                    t.tituloMenu,
                    style: const TextStyle(
                      fontFamily: 'DaysOne',
                      fontSize: 35,
                      color: Colors.white,
                    )
                  ),
                ],
              )
            ),
          ),
          
          //Body
          Expanded(
            flex: 9,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: ResizeImage(
                    AssetImage('assets/fundos/fundoNavBar.png'),
                    width: 608,
                    height: 1281,
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center
                )
              ),

              child: Column(
                children: [
                  Expanded(
                    flex: 0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:25, bottom: 0),
                          child: ClipOval(
                            child: Image.network(
                              HttpServicesProject.urlNif,
                              key: UniqueKey(),
                              fit: BoxFit.cover,
                              width: 200.0,
                              height: 200.0,
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

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            nome,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              fontSize: 30, 
                              color: Colors.black
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 5, thickness: 0), 
            
                  //!Menu
                  Expanded(
                    child: SingleChildScrollView(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: menuLabelLateral.length,
                          itemBuilder: (context, index){
                            return Visibility(
                              visible: (index == 0 ? widget.info.area != '' : true), //Equipa - Outros
                              child: ListTile(
                                leading: Icon(
                                  menuIconsLateral[index],
                                  color: const Color.fromARGB(255, 54, 54, 54),
                                  size: 35,
                                ),
                                title: Text(
                                  menuLabelLateral[index],
                                  style: const TextStyle(
                                    fontFamily: 'Gantari',
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                /*
                                trailing: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 54, 54, 54),
                                    border: Border.all(),
                                    borderRadius: const BorderRadius.all(Radius.circular(30))
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '+99',
                                      style: TextStyle(
                                        fontFamily: 'Gantari',
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ),
                                */
                                onTap: () async{
                                  switch(index){
                                    case 0:{
                                      //Muda para outra página
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EquipaScreen(condicaoAppBar: true, nif: nif)
                                        )
                                      );
                                      break;
                                    }
                                    /*
                                    case 1:{
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const EventoScreen()
                                        )
                                      );
                                      break;
                                    }
                                    
                                    case 2:{
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HelpScreen()
                                        )
                                      );
                                      break;
                                    }
                                    */

                                    case 1: {
                                      List categorias = await HttpServicesProject.capturarCategorias(t);
                                      showDialog(barrierDismissible: true, context: context, useRootNavigator: true, builder: (tela){
                                        return Scaffold(
                                          resizeToAvoidBottomInset: false,
                                          
                                          backgroundColor: Colors.transparent,
                                          body: SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 40),
                                              child: feedbackBox(tela, nif, categorias)
                                            ),
                                          ),
                                        );
                                    });
                                      break;
                                    }

                                    case 2:{
                                      showDialog(barrierDismissible: true, context: context, builder: (context){
                                        return decisionBox(context, t.avisLogOut, t.txtCertezaLogOut,  300, Icons.help, decisionBoxsim(), decisionBoxnao());
                                      });
                                      break;
                                    }

                                    case 3:{
                                      showDialog(barrierDismissible: true, context: context, builder: (context){
                                        return decisionBox(context, t.avisExit, t.txtCertezaExit,  300, Icons.help, (){
                                        Navigator.of(context).pop();
                                        if (Platform.isAndroid) {
                                          SystemNavigator.pop();
                                        } else if (Platform.isIOS) {
                                          exit(0);
                                        }}, decisionBoxnao());
                                      });
                                      break;
                                    }
                                  }
                                },
                              ),
                            );
                          }
                        ),
                      )   
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  void autoRefreshToken(String senha) async {
    var t = AppLocalizations.of(context)!;
    
    //Refresh ao token de acesso
    Uri url = definirUriGET('token/refresh_token.php', campo1: senha);
    http.Response data = await http.get(url);

    if(data.statusCode != 200){                                                  
      retornarErro(t.avisInesperado);
    }
  }
  
  void validarImpressaoDigital(String senha) async {
    var t = AppLocalizations.of(context)!;

    //Verifica se os dados biométricos estão registados no computador
    bool isAuthenticated = await AuthService.authenticateUser(context);

    if(isAuthenticated){
      
      //Refresh ao token de acesso
      Uri url = definirUriGET('token/refresh_token.php', campo1: senha);
      http.Response data = await http.get(url);

      if(data.statusCode == 200){                                                  
        setState(() {
          password = '';
          controllerPassword.clear;
        });
        
        sairDialog();
      }
      else{
        retornarErro(t.avisInesperado);
      }
    }
  }
  
  void refreshToken(String senha, {Timer? timer}) async{
    var t = AppLocalizations.of(context)!;
    timer?.cancel();
    
    //Mostra uma janela para o Utilizador colocar a password
    showDialog(barrierDismissible: false, context: context, useRootNavigator: true, builder: (context){
      return Builder(
        builder: (context){ 
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0)
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              //Caixa branca
              SizedBox(
                height: 310,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        //! Título
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.errPHP29, 
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'DaysOne',
                                fontSize: 29,
                                color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        
                        //! Mensagem
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text( 
                            t.errPHP30, 
                            textAlign: TextAlign.center, 
                            style: const TextStyle(
                              fontFamily: 'Gantari',
                              fontSize: 18,
                              color: Colors.black
                            ),
                          ),
                        ),
                        
                        //! Caixa de texto para colocar a password
                        Padding(  
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration( 
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color.fromARGB(255, 78, 52, 46))
                            ),
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return TextFormField(
                                  controller: controllerPassword,
                                  textAlign: TextAlign.center,
                                  //Esconder o texto da password
                                  obscureText: true,
                                  style: const TextStyle(
                                    color:Colors.black,
                                    fontSize: 17.0,  
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                            
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value){
                                    password = value;
                                  },
                                );
                              }
                            ),
                          ),
                        ),
              
                        //Botão
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                alignment: Alignment.center,
                                backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 78, 52, 46)),
                                enableFeedback: true,
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                minimumSize: MaterialStateProperty.all(Size(globals.bio ? 200 : 250, 35)),
                              ),
                                        
                              child: const Text('Ok', 
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              onPressed: () async{
                                //Validação de password
                                if(password.isNotEmpty){
                                  if(senha == password){
                                    //Refresh ao token de acesso 
                                    Uri url = Uri.parse("http://${globals.ip}:${globals.porta}/drh_project/token/refresh_token.php?ctb=$nif&campo1=$password");
                                    http.Response data = await http.get(url);
                                    if(data.statusCode == 200){
                                      setState((){
                                        password = '';
                                        controllerPassword.text = '';
                                        controllerPassword.clear();
                                      });
                                      refreshTimerToken(nif);
                                      sairDialog();
                                    }
                                    else{
                                      //Identidade bloquada!                                      
                                      mudancaTela(const LoginScreen());
                                      retornarErro(t.errPHP20);
                                    }
                                  }
                                  else{
                                    retornarErro(t.avisPasswordIncorreta);
                                  }
                                }
                                else{
                                  retornarErro(t.avisPasswordPorPreencher);
                                }
                              },
                            ),
                            Visibility(
                              visible: globals.bio,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.all(10),
                                child: SizedBox(
                                  height: 40.0,
                                  width: 50.0,
                                  child: FloatingActionButton.extended(
                                    heroTag: null,
                                    backgroundColor: Colors.brown[900],
                                    label: const Icon(
                                      Icons.fingerprint,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async{
                                      validarImpressaoDigital(senha);
                                    }
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Positioned(
                  top: -70,
                  child: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 78, 52, 46),
                    radius: 60,
                    child: Icon(
                      Icons.report, 
                      color: Colors.white, 
                      size: 65
                    ),
                  )
                ),

                Positioned(
                  bottom: 10,
                  child: Align(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        t.escolhaVoltarLogin,
                        style: TextStyle(
                          fontFamily: 'Gantari',
                          fontSize: 18,
                          color: Colors.brown[800]
                        ),
                      )
                    )
                  )
                ),
              ],
            )
          ),
        );
      });
    }
    ).then(
      (value){
        setState(() => erroHttp = 200);
      }
    );
  }

  //Instânciar ferramentas do Firebase
  void requestAndRegisterNotification() async{

    //Segura a mensagem no dispositivo após app fechada (Tem de estar no inicio do código)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
    //Captura dados a cerca da notificação
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Uri url = definirUriGET("state_notification.php", campo1: globals.id);
    http.Response data = await http.get(url);
    bool displayNotification = (data.statusCode == 204);

    bool condicaoMostrarNotificacoes(){
      return AwesomeNotificationService.showDialogRequestNotification(context);
    }

    //Verifica o estado da notificação
    switch(settings.authorizationStatus){
      case AuthorizationStatus.authorized:
      definicoesFirebase(globals.id ?? '', true);
      debugPrint("Concedeu permissão");
      break;

      case AuthorizationStatus.denied:

      if(displayNotification){
        bool condicao = condicaoMostrarNotificacoes();
        definicoesFirebase(globals.id ?? '', condicao);
      }
      else{
        debugPrint("Permissão negada");
        definicoesFirebase(globals.id ?? '', false);
      }
      break;

      //O Usuário ainda não escolheu conceder a permissão
      case AuthorizationStatus.notDetermined:

      if(displayNotification){
        bool condicao = condicaoMostrarNotificacoes();
        definicoesFirebase(globals.id ?? '', condicao);
      }
      else{
        debugPrint("Não está determinado a permissão");
        definicoesFirebase(globals.id ?? '', false);
      }
      break;

      case AuthorizationStatus.provisional:
      definicoesFirebase(globals.id ?? '', true);
      debugPrint("Concedeu permissão provisória");
      break;
    }
  }
  
  void definicoesFirebase(String idDispositivo, bool permissao) {
    //Salvar token e ID do dispositivo na BD + Línguagem do dispositivo
    HttpServicesProject.saveDataFromDevice(idDispositivo, permissao);

    //Criação dos canais caso não os tenha
    AwesomeNotificationService.initialize();
    
    //* *********************************
    // TAREFAS DO FIREBASE COM MESSAGING
    //* *********************************
    
    //Aplicação Fechada
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if(message != null){
        AwesomeNotificationService.showNotification(message: message);
      }
    });
    
    //Aplicação Aberta ou em 2º Plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //Contabilizar as notificações
      setState(() => totalNotifications++);
      
      //Acesso ao serviço de mandar uma notificação
      AwesomeNotificationService.showNotification(message: message);
    });
    
    //Click na notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //Remove a badge que existe no Ios pois não desaparece no click como o Android
      if(Platform.isIOS){
        AwesomeNotifications().getGlobalBadgeCounter().then((value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1));
      }
      AwesomeNotificationService.onSelectedNotification(message, context);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      HttpServicesProject.saveDataFromDevice(idDispositivo, permissao);
    }).onError((err) {
      debugPrint(err);
    });
  }

  VoidCallback decisionBoxnao() {
    return (){
      Navigator.of(context).pop();
    };
  }

  VoidCallback decisionBoxsim() {
    Future<void> removerCredenciais() async{
      List<String> utilizador = ['', 'false'];
      await GuardarPreferences.setValues(utilizador);
    }

    tempo.cancel();

    return (){
      //Remover o fundo
      removerCredenciais();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen()
        ),
        (route) => route.isFirst
      );
    };
  }

  Future<bool> verificarToken(String nif, {String? key}) async{
    Uri url = Uri.parse("http://${globals.ip}:${globals.porta}/drh_project/token/refresh_token.php?ctb=$nif");
    http.Response data = await http.get(url);

    Map<String, dynamic> resposta = jsonDecode(data.body);
    encrypt = resposta['encript'];
    iv16 = resposta['iv'];
    chave = resposta['chave'];

    //Desencripto a senha
    aes = AesCrypt(key: chave, padding: PaddingAES.pkcs7);
    senha = aes.gcm.decrypt(enc: encrypt, iv: iv16);
    
    if(data.statusCode == 200) {
      //Token ainda está válido, então segue apenas para um refresh
      return true;
    } else{
      //Token expirado, deve inserir novamente uma validação
      return false;
    }
  }
  
  void refreshTimerToken(String nif) {
    tempo = Timer.periodic(const Duration(minutes: 10), (timer) async{
      if(!(await verificarToken(nif))){
        validarImpressaoDigital(senha);
        refreshToken(senha, timer: timer);
      }
      //mytimer.cancel() //Para cancelar este timer
    });
  }
  
  void mudancaTela(var loginScreen) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => loginScreen
      )
    );
  }
}
