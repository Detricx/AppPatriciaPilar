import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, exit;
import 'package:drh_project/controllers/locale_provider.dart';
import 'package:drh_project/models/request_http.dart';
import 'package:drh_project/services/auth_bio.dart';
import 'package:drh_project/services/define_error_php.dart';
import 'package:drh_project/services/definir_url.dart';

import 'package:drh_project/screens/Principal/home.dart';
import 'package:drh_project/services/shared_preferences.dart';
import 'package:drh_project/widgets/dialog_box.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:drh_project/services/globals.dart' as globals;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
  String password = "", confirmacao = '', senha = '', tituloDialog = '', msg = '';

  //Variáveis para passagem
  String nome = '', profissao = '', area = '';

  DateTime timeBackPressed = DateTime.now();
  List<String> utilizador = [];

  //Variáveis para a comunicação http
  String? encrypt, iv16, chave, token, sn, chefe, lingua;
  bool? valido = false;
  CryptKey keyGen = CryptKey();
  late AesCrypt aes;
  Map<String, dynamic> resposta = {};
  late http.Response data;
  late List dados;

  //Variáveis para o design
  Color corCastanha = const Color.fromARGB(255, 62, 39, 35);
  Color corVerde = const Color.fromARGB(255, 0, 155, 62);

  List<String> listagemErros = List.generate(22, (int i) => i.toString());

  @override
  void initState() {
    
    _controllerContribuinte.text = globals.nif;

    //Guardo se o Utilizador inserir para guardar os dados
    stayAssign = globals.sharedPreferences;
    keepCredenciais = stayAssign;

    //Verifico se suporta impressão digital
    biometriaCompativel().then((value) => suportaBio = value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Iniciar a tradução desta
    var t = AppLocalizations.of(context)!;

    debugInvertOversizedImages = false;
    //Mudar a interface do Sistema Operativo
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: corCastanha));

    //Este Widget serve para a app não fechar de uma vez e sim dizer ao utilizador se quer realmente sair
    return WillPopScope(
      onWillPop: () async {
        final Duration difference = DateTime.now().difference(timeBackPressed);
        final bool isExitWarning = difference >= const Duration(seconds: 2);

        timeBackPressed = DateTime.now();

        if (isExitWarning) {
          Fluttertoast.showToast(msg: t.avisPressiona, fontSize: 15);
          return false;
        } else {
          Fluttertoast.cancel();
          return true;
        }
      },

      child: Scaffold(
        //Os Widgets que estiverem presentes não serão alterados conforme o teclado
        resizeToAvoidBottomInset: false,

        //Fundo do layout
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: ResizeImage(
                AssetImage('assets/fundos/fundo_login.png'),
                width: 700,
                height: 1300),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          )),
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 40),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 30),
                          child: Text(t.lbtitulo,
                              style: const TextStyle(
                                fontFamily: 'DaysOne',
                                fontSize: 30,
                                color: Colors.white,
                              )),
                        ),

                        //! Caixa de Texto do Número Contribuinte
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _controllerContribuinte,
                              style: const TextStyle(
                                color: Colors.black,
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
                              onChanged: (value) {
                                setState(() {
                                  globals.nif = value;
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
                            backgroundColor: Colors.brown[800],
                            heroTag: null,
                            label: Text(
                              t.btValidar,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white
                              )
                            ),
                            onPressed: () async {
                                if (globals.nif.isNotEmpty && globals.nif.length == 9) {
                                  //Recolhe as variáveis necessárias para o Login
                                  Uri url = definirUriGET('ctb_func.php', campo1: globals.id);
                                  data = await http.get(url);
                                  
                                  //Verifica se suporta dados biométricos
                                  globals.bio = await AuthService.isSupported();

                                  switch (data.statusCode) {
                                    case 200:
                                      //O token está válido, logo avança para as próximas páginas
                                      resposta = jsonDecode(data.body);
                                      dados = resposta['data'];
                                      lingua = resposta['lingua'];

                                      return telaSeguinte(dados, lingua, t);

                                    case 401:
                                      resposta = jsonDecode(data.body);

                                      //Preciso de validar o token para poder avançar
                                      encrypt = resposta['encript'];
                                      iv16 = resposta['iv'];
                                      chave = resposta['chave'];
                                      sn = resposta['id'];

                                      //Desencripto a senha
                                      aes = AesCrypt(key: chave!,padding:PaddingAES.pkcs7);
                                      senha = aes.gcm.decrypt(enc: encrypt!, iv: iv16!);
                                      setState(() => caixapassword = true);

                                      //Verifica se o serial number que usou para se registar é igual ao atual
                                      if (sn == globals.id) {
                                        //Selecinou que queria ficar logado?
                                        if (stayAssign) {
                                          //Suporta Biodados?
                                          if (suportaBio) {
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
                                      showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) {
                                          return dialogBox(
                                            context,
                                            t.errBemVindo,
                                            t.txtBemVindo,
                                            220,
                                            Icons.waving_hand
                                          );
                                        }
                                      );
                                    break;

                                    case 502:
                                    return showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return dialogBox(
                                          context,
                                          t.loginServidor,
                                          t.loginExpliServ,
                                          230,
                                          Icons.warning);
                                      }
                                    );

                                    case 403:
                                    return showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return dialogBox(
                                            context,
                                            t.loginPermissao,
                                            t.loginPermisServ,
                                            230,
                                            Icons.warning);
                                      }
                                    );

                                    //Deu algum tipo de erro inesperado
                                    default:
                                      setState(() => caixapassword = false);
                                      resposta = jsonDecode(data.body);
                                      tituloDialog = resposta['type'];
                                      msg = resposta['message'];

                                      List<String> erro = definirErroPhp(tituloDialog, msg, t);
                                      return showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) {
                                          return dialogBox(
                                            context,
                                            erro[0],
                                            erro[1],
                                            230,
                                            Icons.warning
                                          );
                                        }
                                      );
                                    }
                                  } 
                                  else {
                                    return showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return dialogBox(
                                          context,
                                          t.loginIncorreto,
                                          t.loginIncorrServr,
                                          230,
                                          Icons.warning
                                        );
                                      }
                                    );
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: Container(
                                    height: 40.0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(5),
                                    ),
                                    child: TextFormField(
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller: _controllerPassword,
                                      //Esconder o texto da password
                                      obscureText: isHiddenPassword,
                                      style: const TextStyle(
                                        color: Colors.black,
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
                                            onTap: () {
                                              setState(() {
                                                isHiddenPassword =
                                                    !isHiddenPassword;
                                              });
                                            },
                                            child: Icon(
                                              //Condição que mudará o icon
                                              (isHiddenPassword == false)
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: corVerde,
                                              size: 30,
                                            ),
                                          )),
                                      onChanged: (value) {
                                        password = value;
                                      },
                                    ),
                                  ),
                                ),

                                //! Caixa de Texto para colocar nova passoword
                                Visibility(
                                    visible: caixaConfirm,
                                    child: Column(children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Container(
                                          height: 40.0,
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType
                                                .visiblePassword,
                                            controller:
                                                _controllerConfirmPassowrd,
                                            //Esconder o texto da password
                                            obscureText: isHiddenPassword,
                                            //Desing do Texto
                                            style: const TextStyle(
                                              color: Colors.black,
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
                                              hintText:
                                                  t.tbConfirmarPassword,
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              confirmacao = value;
                                            },
                                          ),
                                        ),
                                      ),
                                    ])),

                                //! Check para guardar as credênciais
                                Visibility(
                                  visible: caixapassword,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          splashRadius: 15,
                                          shape: const CircleBorder(),
                                          value: keepCredenciais,
                                          checkColor: Colors.white,
                                          activeColor: corCastanha,
                                          onChanged: (bool? valor) {
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
                                              color: Colors.white)),
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
                                      child:
                                          FloatingActionButton.extended(
                                        heroTag: null,
                                        backgroundColor: corCastanha,
                                        label: Text(t.btConfirmar,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                        onPressed: () async {
                                          if (password.isNotEmpty && confirmacao.isNotEmpty) {
                                            if (password == confirmacao) {
                                              //Gera uma chave com 32 bytes
                                              String key32 = keyGen.genFortuna(len:32); 
                                              
                                              //Gero um IV para a criptografia AES
                                              iv16 = keyGen.genDart(len:16); 

                                              //Gero tipo AES de criptografia (chave + padding)
                                              aes = AesCrypt(key: key32,padding: PaddingAES.pkcs7); 

                                              //Encriptar a password para a guardar
                                              encrypt = aes.gcm.encrypt(inp: password,iv: iv16!); 

                                              //Cria um novo token
                                              if (await refreshToken(encrypt!,iv16!,key32,globals.id ?? '',t)) {
                                                //Verifica se quer guardar as credênciais
                                                userStayAssign(keepCredenciais);

                                                //Avança porque correu tudo como esperado
                                                telaSeguinte(dados, lingua, t);
                                              }
                                            } 
                                            else {
                                              showDialog(barrierDismissible: true, context: context, builder: (context) {
                                                return dialogBox(context, t.errErro, t.txtErroChave, 210, Icons.warning);
                                              });
                                            }
                                          } 
                                          else {
                                            showDialog( barrierDismissible: true, context: context, builder: (context) {
                                              return dialogBox(context, t.errCampoVazio(1), t.txtCampoVazio(1),210, Icons.warning);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets
                                                    .symmetric(
                                                horizontal: 10,
                                                vertical: 10),
                                            child: SizedBox(
                                                height: 40.0,
                                                width: 220.0,
                                                child: FloatingActionButton
                                                    .extended(
                                                        heroTag: null,
                                                        backgroundColor:
                                                            corCastanha,
                                                        label: Text(
                                                            t.btEntrar,
                                                            style: const TextStyle(
                                                                fontSize:
                                                                    20,
                                                                color: Colors
                                                                    .white)),
                                                        onPressed:
                                                            () async {
                                                          if (password.isNotEmpty) {
                                                            if (senha == password) {
                                                              //Refresh ao token
                                                              if (await refreshToken(encrypt!,iv16!,chave!,sn!,t)) {
                                                                //Verifica se quer guardar as credênciais
                                                                userStayAssign(keepCredenciais);

                                                                //Avança porque correu tudo como esperado
                                                                telaSeguinte(dados, lingua, t);
                                                              }
                                                            } else {
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return dialogBox(
                                                                        context,
                                                                        t.errPass,
                                                                        t.txtPass,
                                                                        200,
                                                                        Icons.warning);
                                                                  });
                                                            }
                                                          } else {
                                                            showDialog(
                                                                barrierDismissible:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return dialogBox(
                                                                      context,
                                                                      t.errCampoVazio(0),
                                                                      t.txtCampoVazio(0),
                                                                      220,
                                                                      Icons.warning);
                                                                });
                                                          }
                                                        }
                                                        )
                                                        ),
                                    ),

                                    //Apenas aparecerá caso consiga usar a impressão digital e anteriormente tenha guardado
                                    Visibility(
                                      visible: (suportaBio && stayAssign && sn == globals.id) ? true : false,
                                      child: Padding(
                                        padding:const EdgeInsetsDirectional.all(10),
                                        child: SizedBox(
                                          height: 40.0,
                                          width: 50.0,
                                          child: FloatingActionButton.extended(
                                            heroTag: null,
                                            backgroundColor: corCastanha,
                                            label: const Icon(
                                              Icons.fingerprint,
                                              color: Colors.white
                                            ),
                                            onPressed: () async {
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
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 40,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.brown[800],
                      child: const Icon(Icons.power_settings_new),
                      onPressed: () {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        }
                      }
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: Text(t.lbDevtech,
                      style: const TextStyle(
                          fontFamily: 'Gantari',
                          fontSize: 12,
                          color: Colors.black)),
                  onTap: () {},
                )
              ),
              const SizedBox(
                height: 20,
              )
            ],
          )
        )
      )
    );
  }

  void userStayAssign(bool condicao) async {
    if (condicao) {
      utilizador = [globals.nif, 'true'];
      await GuardarPreferences.setValues(utilizador);
    } else {
      utilizador = ['', 'false'];
      await GuardarPreferences.setValues(utilizador);
    }
  }

  Future<dynamic> telaSeguinte(List data, String? lingua, AppLocalizations t) {
    
    //Definir lingua do projeto
    lingua = lingua != null ? lingua.replaceAll(" ", "") : t.localeName;
    globals.linguaProjeto = lingua;
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final local = Locale(lingua);
    provider.setLocale(local);
    
    return Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) {
        //Verifica se das empresas disponíveis existe o logo delas inserido
        if (data[3] == '516303147' || data[3] == '517151561' || data[3] == '516911023' || data[3] == '517188848' || data[3] == '517040387' || data[3] == '517021358') {
          data[3] = 'null';
        }
  
        return HomeScreen(
          info: RequestHttp(data[0], data[1], data[2], data[3], data[4], data[5]),
          textAppBar: t.labelMenuPerfil,
        );
      })
    );
  }

  //Verifico se o hardware do dispositivo aceita dados biométricos
  Future<bool> biometriaCompativel() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  //Desenrasque para aparecer um layout de erro
  void displayDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title), content: Text(text)
      ),
    );
  }

  void impressaoDigital(AppLocalizations t) async {
    bool isAuthenticated = await AuthService.authenticateUser(context);

    void mostrarErroScaffold() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.avisImpressaoDigital),
        ),
      );
    }

    //Verifico se correu tudo bem
    if (isAuthenticated) {
      //Refresh ao token de acesso
      if (await refreshToken(encrypt!, iv16!, chave!, sn!, t)) {
        //Segue para a tela seguinte após fazer o login
        telaSeguinte(dados, lingua, t);
      } else {
        resposta = jsonDecode(data.body);
        tituloDialog = resposta['type'];
        msg = resposta['message'];

        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            List<String> erro = definirErroPhp(tituloDialog, msg, t);
            return dialogBox(context, erro[0], erro[1], 230, Icons.warning);
          }
        );
      }
    }
    else {
      mostrarErroScaffold();
    }
  }

  Future<bool> refreshToken(String encrypt, String iv16, String chave, String sn, AppLocalizations t) async {
    try{
      Uri url = definirUriGET('save_key.php', campo1: encrypt, campo2: iv16, campo3: chave, campo4: sn);
      data = await http.put(url);
      resposta = jsonDecode(data.body);

      dados = resposta["data"];
      lingua = resposta["lingua"];
      return data.statusCode == 200 ? true : false;

    } catch (e) {
      tituloDialog = resposta['type'] ?? 'Error';
      msg = resposta['message'] ?? 'Unexpected error';

      showDialog( barrierDismissible: true, context: context, builder: (context) {
        List<String> erro = definirErroPhp(tituloDialog, msg, t);
        return dialogBox(context, erro[0], erro[1], 230, Icons.warning);
      });

      return false;
    }
  }
}