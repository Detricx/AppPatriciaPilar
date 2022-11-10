import 'dart:async';
import 'dart:convert';
import 'package:drh_project/models/request_http.dart';
import 'package:drh_project/services/auth_bio.dart';
import 'package:drh_project/services/define_error_php.dart';
import 'package:drh_project/services/definir_url.dart';

import 'package:drh_project/screens/Principal/ajuda.dart';
import 'package:drh_project/screens/Principal/home.dart';
import 'package:drh_project/services/shared_preferences.dart';
import 'package:drh_project/widgets/dialog_box.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  //Caixas de texto
  final TextEditingController _controllerContribuinte = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassowrd = TextEditingController();

  //Armazenar dados biométricos
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController loginButtonController;

  // Variáveis da APP
  bool isHiddenPassword = true, caixapassword = false, caixaConfirm = false, stayAssign = false, suportaBio = false, keepCredenciais = false;
  String ctb = "", password = "", confirmacao = '', senha = '', tituloDialog = '', msg = '';

  //Variáveis para passagem
  String nome = '', profissao = '', area= '';

  DateTime timeBackPressed = DateTime.now();
  List<String> utilizador = [];

  //Variáveis para a comunicação http
  String? encrypt, iv16, chave, token, sn, chefe;
  bool? valido = false;
  CryptKey keyGen = CryptKey();
  late AesCrypt aes;
  late Map<String, dynamic> resposta;
  late http.Response data;
  late dynamic snDispositivo;
  late List dados;

  //Variáveis para o design
  Color corCastanha = const Color.fromARGB(255, 72, 55, 41);
  Color corVerde = const Color.fromARGB(255, 0, 155, 62);
  
  List<String> listagemErros = List.generate(22, (int i) => i.toString());

  @override
  void initState() {

    //Agarra nos valores guardados caso o tenha e coloca dentro de variáveis (nif e se colocou para guardar as credênciais)
    List<String> utilizador = GuardarPreferences.getValues() ?? ['', 'false'];
    
    //Inserir por defeito o último contribuinte inserido
    ctb = utilizador[0];
    _controllerContribuinte.text = ctb;

    //Guardo se o Utilizador inserir para guardar os dados
    stayAssign = (utilizador[1] == 'true') ? true : false;
    keepCredenciais = stayAssign;

    //Verifico se suporta impressão digital
    biometriaCompativel().then((value) => suportaBio = value);

    snDispositivo = agarraIdDispositivo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Iniciar a tradução desta
    var t = AppLocalizations.of(context)!;
    
    debugInvertOversizedImages = false;
    //Mudar a interface do Sistema Operativo
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: corCastanha
    ));

    //Este Widget serve para a app não fechar de uma vez e sim dizer ao utilizador se quer realmente sair
    return WillPopScope(
      onWillPop: () async{
        final Duration difference = DateTime.now().difference(timeBackPressed);
        final bool isExitWarning = difference >= const Duration(seconds: 2);

        timeBackPressed = DateTime.now();

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
      },

      child: Scaffold(
        //Os Widgets que estiverem presentes não serão alterados conforme o teclado
        resizeToAvoidBottomInset: false,

        //Fundo do layout
        body:Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: ResizeImage(
                AssetImage('assets/fundos/fundo_login.png'),
                width: 700,
                height: 1300 
              ),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
          ),

          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Logotipo
                    Image.asset(
                      'assets/icons/logo.png',
                      width: 230,
                      height: 210,
                    ),
                    
                    //Título
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        t.lbtitulo,
                        style: const TextStyle(
                          fontFamily: 'DaysOne',
                          fontSize: 30,
                          color: Colors.white,
                        )
                      ),
                    ),
                    
                    //! Caixa de Texto do Número Contribuinte
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        height: 40.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _controllerContribuinte,
                          style: const TextStyle(
                            color:Colors.black,
                            fontSize: 17.0,  
                          ),
                          inputFormatters: [ 
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: InputDecoration(
                            //Propriedade que bloqueia o corte das palavras por debaixo
                            isDense: true,
                            icon: Icon(
                              Icons.person,
                              color: corVerde,
                              size: 30,
                            ),
                            hintText: t.tbNumeroContribuinte,
                            border: InputBorder.none,
                          ),
                          onChanged: (value){
                            setState(() {
                              ctb = value;
                              caixaConfirm = false;
                              caixapassword = false;
                              _controllerPassword.text = '';
                              _controllerConfirmPassowrd.text = '';
                              password = _controllerConfirmPassowrd.text;
                              confirmacao = _controllerConfirmPassowrd.text;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    //! Butão de validação de contribuinte
                    Visibility(
                      visible: !caixapassword,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(10),
                        child: SizedBox(
                          height: 40.0,
                          width: 220.0,
                          child: FloatingActionButton.extended(
                            backgroundColor: corCastanha,
                            heroTag: null,
                            label: Text(
                              t.btValidar,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white
                              )
                            ),
                            onPressed: () async {
                              if(ctb.isNotEmpty && ctb.length == 9){
                                //Recolhe as variáveis necessárias para o Login
                                Uri url = definirUrl('ctb_func.php', ctb);
                                data = await http.get(url);

                                switch (data.statusCode){
                                  case 200:
                                  //O token está válido, logo avança para as próximas páginas
                                  resposta = jsonDecode(data.body);
                                  dados = resposta['data'];
                                  return telaSeguinte(dados, t);

                                  case 401:
                                  resposta = jsonDecode(data.body);

                                  //Preciso de validar o token para poder avançar
                                  encrypt = resposta['encript'];
                                  iv16 = resposta['iv'];
                                  chave = resposta['chave'];
                                  sn = resposta['id'];

                                  //Desencripto a senha
                                  aes = AesCrypt(key: chave!, padding: PaddingAES.pkcs7);
                                  senha = aes.gcm.decrypt(enc: encrypt!, iv: iv16!);
                                  setState(() => caixapassword = true);

                                  //Verifica se o serial number que usou para se registar é igual ao atual
                                  if(sn == snDispositivo){
                                    //Selecinou que queria ficar logado?
                                    if(stayAssign){
                                      //Suporta Biodados?
                                      if(suportaBio){
                                        //Faz o login pela Impressão digital
                                        impressaoDigital(t);
                                      }
                                    }
                                  }
                                  break;

                                  case 204:
                                  //Nunca se registou
                                  setState(() {
                                    caixapassword = true;
                                    caixaConfirm = true;
                                  });

                                  //Dispõem um dialog de boas vindas
                                  showDialog(barrierDismissible: true, context: context, builder: (context){
                                    return dialogBox(context, t.errBemVindo, t.txtBemVindo,  220, Icons.waving_hand);
                                  });
                                  break;

                                  case 502:
                                  return showDialog(barrierDismissible: true, context: context, builder: (context){
                                    return dialogBox(context, t.loginServidor, t.loginExpliServ, 230, Icons.warning);
                                  });

                                  case 403:
                                  return showDialog(barrierDismissible: true, context: context, builder: (context){
                                    return dialogBox(context, t.loginPermissao, t.loginPermisServ, 230, Icons.warning);
                                  });

                                  //Deu algum tipo de erro inesperado
                                  default:
                                  setState(() => caixapassword = false);
                                  resposta = jsonDecode(data.body);
                                  tituloDialog = resposta['type'];
                                  msg = resposta['message'];

                                  List<String> erro = definirErroPhp(tituloDialog, msg, t);
                                  return showDialog(barrierDismissible: true, context: context, builder: (context){
                                    return dialogBox(context, erro[0], erro[1], 230, Icons.warning);
                                  });
                                }
                              }
                              else{
                                return showDialog(barrierDismissible: true, context: context, builder: (context){
                                  return dialogBox(context, t.loginIncorreto, t.loginIncorrServr, 230, Icons.warning);
                                });
                              }
                            }
                          )
                        ),
                      ),
                    ),

                    Visibility(
                      visible: caixapassword,
                      child: Column(
                        children: [
                          //! Caixa de Texto da Password
                          Padding(  
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              height: 40.0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration( 
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                controller: _controllerPassword,
                                //Esconder o texto da password
                                obscureText: isHiddenPassword,
                                style: const TextStyle(
                                  color:Colors.black,
                                  fontSize: 17.0,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  icon: Icon(
                                    Icons.lock_outline,
                                    color: corVerde,
                                    size: 30,
                                  ),
                                  hintText: "Password",
                                  border: InputBorder.none,
                                  suffixIcon: InkWell(
                                    onTap: (){
                                      setState(() {
                                        isHiddenPassword = !isHiddenPassword;
                                      });
                                    },
                                    child: Icon(
                                      //Condição que mudará o icon
                                      (isHiddenPassword == false) ? Icons.visibility : Icons.visibility_off,
                                      color: corVerde,
                                      size: 30,
                                    ),
                                  )
                                ),
                                onChanged: (value){
                                  password = value;
                                },
                              ),
                            ),
                          ),

                          //! Caixa de Texto para colocar nova passoword
                          Visibility(
                            visible: caixaConfirm,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Container(
                                    height: 40.0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration( 
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.visiblePassword,
                                      controller: _controllerConfirmPassowrd,
                                      //Esconder o texto da password
                                      obscureText: isHiddenPassword,
                                      //Desing do Texto
                                      style: const TextStyle(
                                        color:Colors.black,
                                        fontSize: 17.0,  
                                      ),
                                      //Desing da caixa de texto
                                      decoration: InputDecoration(
                                        isDense: true,
                                        icon: Icon(
                                          Icons.vpn_lock,
                                          color: corVerde,
                                          size: 30,
                                        ),
                                        hintText: t.tbConfirmarPassword,
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value){
                                        confirmacao = value;
                                      },
                                    ),
                                  ),
                                ),
                              ]
                            )
                          ),

                          //! Check para guardar as credênciais
                          Visibility(
                            visible: caixapassword,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(scale: 1.5,
                                  child: Checkbox(
                                    splashRadius: 15,
                                    shape: const CircleBorder(),
                                    value: keepCredenciais,
                                    checkColor: Colors.white,
                                    activeColor:  corCastanha,
                                    onChanged: (bool ?valor) {
                                      setState(() {
                                        keepCredenciais = valor!;
                                      });
                                    },
                                  ),
                                ),
                                Text(t.rbGuardar,
                                  style: const TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white
                                  )
                                ),
                              ],
                            ),
                          ),

                          //! Butão de validação de uma nova password
                          Visibility(
                            visible: caixaConfirm,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.all(10),
                              child: SizedBox(
                                height: 40.0,
                                width: 220.0,
                                child: FloatingActionButton.extended(
                                  heroTag: null,
                                  backgroundColor: corCastanha,
                                  label: Text(
                                    t.btConfirmar,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                    )
                                  ),
                                  onPressed: () async {
                                    if(password.isNotEmpty && confirmacao.isNotEmpty){
                                      if(password == confirmacao){

                                        String key32 = keyGen.genFortuna(len: 32); //Gera uma chave com 32 bytes
                                        iv16 = keyGen.genDart(len: 16); //Gero um IV para a criptografia AES
                                        aes = AesCrypt(key: key32, padding: PaddingAES.pkcs7); //Gero tipo AES de criptografia (chave + padding)
                                        encrypt = aes.gcm.encrypt(inp: password, iv: iv16!); //Encriptar a password para a guardar
                                        
                                        //Cria um novo token
                                        if(await refreshToken(ctb, encrypt!, iv16!, key32, snDispositivo, t)){
                                          //Verifica se quer guardar as credênciais
                                          userStayAssign(keepCredenciais);

                                          //Avança porque correu tudo como esperado
                                          telaSeguinte(dados, t);
                                        }
                                      }
                                      else{
                                        showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, t.errErro, t.txtErroChave, 210, Icons.warning);
                                        });
                                      }
                                    }
                                    else{
                                      showDialog(barrierDismissible: true, context: context, builder: (context){
                                          return dialogBox(context, t.errCampoVazio(1), t.txtCampoVazio(1), 210, Icons.warning);
                                      });
                                    }
                                  },
                                )
                              ),
                            ),
                          ),

                          //! Butão de entrada na app
                          Visibility(
                            visible: !caixaConfirm,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 220.0,
                                    child: FloatingActionButton.extended(
                                      heroTag: null,
                                      backgroundColor: corCastanha,
                                      label: Text(
                                        t.btEntrar,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white
                                        )
                                      ),
                                      onPressed: () async {
                                        if(password.isNotEmpty){
                                          if(senha == password){
                                            //Refresh ao token
                                            if(await refreshToken(ctb, encrypt!, iv16!, chave!, sn!, t)){
                                              //Verifica se quer guardar as credênciais
                                              userStayAssign(keepCredenciais);

                                              //Avança porque correu tudo como esperado
                                              telaSeguinte(dados, t);
                                            }
                                          }
                                          else{
                                            showDialog(barrierDismissible: true, context: context, builder: (context){
                                              return dialogBox(context, t.errPass, t.txtPass, 200, Icons.warning);
                                            });
                                          }
                                        }
                                        else{
                                          showDialog(barrierDismissible: true, context: context, builder: (context){
                                            return dialogBox(context, t.errCampoVazio(0), t.txtCampoVazio(0), 220, Icons.warning);
                                          });
                                        }
                                      }
                                    )
                                  ),
                                ),
                                //Apenas aparecerá caso consiga usar a impressão digital e anteriormente tenha guardado
                                Visibility(
                                  visible: (suportaBio && stayAssign && sn == snDispositivo) ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.all(10),
                                    child: SizedBox(
                                      height: 40.0,
                                      width: 50.0,
                                      child: FloatingActionButton.extended(
                                        heroTag: null,
                                        backgroundColor: corCastanha,
                                        label: const Icon(
                                          Icons.fingerprint,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async{
                                          impressaoDigital(t);
                                        }
                                      )
                                    ),
                                  ),
                                )
                              ]
                            )
                          ),
                        ],
                      )
                    ),
                    
                    //! Caso o Utilizador tenha algumas dificuldades
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.lbDificuldades,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white
                            )
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context, MaterialPageRoute(
                                  builder: (context){
                                    return const HelpScreen();
                                  }
                                )
                              );
                            },
                            child: Text(
                              ' ${t.lbContacto}',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: corCastanha
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: Text(
                    t.lbDevtech,
                    style: const TextStyle(
                      fontFamily: 'Gantari',
                      fontSize: 12,
                      color: Colors.black
                    )
                  ),
                  onTap: () {
                    
                  },
                )
              )
            ],
          )
          
          
        )
      )
    );
  }
  void userStayAssign(bool condicao) async{
    if(condicao){
      utilizador = [ctb, 'true'];
      await GuardarPreferences.setValues(utilizador);
    }
    else{
      utilizador = ['', 'false'];
      await GuardarPreferences.setValues(utilizador);
    }
  }

  Future<dynamic> telaSeguinte(List data, AppLocalizations t){
    return Navigator.pushReplacement(
      context, MaterialPageRoute(
        builder: (context){
          //Verifica se a empresa tem logotipo
          if(data[3] == '516303147' || data[3] == '517151561' || data[3] == '516911023' || data[3] == '517188848' || data[3] == '517040387' || data[3] == '517021358'){
            data[3] = 'null';
          }
          return HomeScreen(info: RequestHttp(data[0], data[1], data[2], data[3], data[4], data[5]), textAppBar: t.labelMenuPerfil);
        }
      )
    );
  }
  
  //Verifico se o hardware do dispositivo aceita dados biométricos
  Future<bool> biometriaCompativel () async{ 
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<String?> agarraIdDispositivo () async{
    return snDispositivo = await PlatformDeviceId.getDeviceId;
  }

  //Desenrasque para aparecer um layout de erro
  void displayDialog(BuildContext context, String title, String text){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text)
      ),
    );
  }

  void impressaoDigital(AppLocalizations t) async{
    bool isAuthenticated = await AuthService.authenticateUser();

    void mostrarErroScaffold(){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.avisImpressaoDigital),
        ),
      );
    }

    //Verifico se correu tudo bem
    if(isAuthenticated) {
      //Refresh ao token de acesso 
      if(await refreshToken(ctb, encrypt!, iv16!, chave!, sn!, t)){
        //Segue para a tela seguinte após fazer o login
        telaSeguinte(dados, t);
      }
      else{
        resposta = jsonDecode(data.body);
        tituloDialog = resposta['type'];
        msg = resposta['message'];

        showDialog(barrierDismissible: true, context: context, builder: (context){
          List<String> erro = definirErroPhp(tituloDialog, msg, t);
          return dialogBox(context, erro[0], erro[1], 230, Icons.warning);
        });
      }
    } 
    else{
      mostrarErroScaffold();
    }
  }
 
  Future<bool> refreshToken(String ctb, String encrypt, String iv16, String chave, String sn, AppLocalizations t) async{
    try{
      Uri url = definirUrl('save_key.php', ctb, campo2: encrypt, campo3: iv16, campo4: chave, campo5: sn);
      data = await http.put(url);
      resposta = jsonDecode(data.body);

      dados = resposta["data"];
      return data.statusCode == 200 ? true : false;
    }
    catch(e){

      tituloDialog = resposta['type'];
      msg = resposta['message'];

      showDialog(barrierDismissible: true, context: context, builder: (context){
        List<String> erro = definirErroPhp(tituloDialog, msg, t);
        return dialogBox(context, erro[0], erro[1], 230, Icons.warning);
      });

      return false;
    }
  }
}

