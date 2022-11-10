import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AwesomeNotificationService {

  static void initialize() async{
    AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher.png',
      [
        NotificationChannel(
          channelKey: 'geral_channel',
          channelName: 'Geral',
          channelDescription: 'Canal geral que serve para avisar a cerca dos eventos',
          importance: NotificationImportance.High,
          channelShowBadge: true,  
        ),
        NotificationChannel(
          channelKey: 'noticia_channel',
          channelName: 'Notícias',
          channelDescription: 'Canal que o irá notificar com o nosso feed',
          importance: NotificationImportance.High,
          channelShowBadge: true,  
        ),
        NotificationChannel(
          channelKey: 'parceria_channel',
          channelName: 'Parcerias',
          channelDescription: 'Canal de mostrará novos patrocínios',
          importance: NotificationImportance.High,
          channelShowBadge: true,  
        ),
        NotificationChannel(
          channelKey: 'submissao_channel',
          channelName: 'Ausências e Férias',
          channelDescription: 'Canal que o notificará a cerca das suas marcações tanto em férias como nas suas ausências',
          importance: NotificationImportance.High,
          channelShowBadge: true,  
        ),
        NotificationChannel(
          channelKey: 'document_channel',
          channelName: 'Documentos',
          channelDescription: 'Canal que indicará quando algum documento novo ficar disponibilizado',
          importance: NotificationImportance.High,
          channelShowBadge: true,  
        ),
      ]
    );
  }

  static void onSelectedNotification(RemoteMessage payload, BuildContext context) async{
    //String tela = "/${payload.data["tela"]}";
    //Navigator.of(context).pushNamed(tela);

    Navigator.of(context).pushNamed("parcerias");
  }

  static Future<void> showNotification({required RemoteMessage message}) async{
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: message.data["key"],
        title: message.notification!.title,
        body: message.notification!.body,
        /*
        bigPicture: 'asset://assets/notification_map.png',
        notificationLayout: NotificationLayout.BigPicture,
        */
      ),
    );
  }

  static bool condicao = false;
  
  static bool showDialogRequestNotification(BuildContext context){
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed){
        if (!isAllowed) {
          showDialog(
            barrierDismissible: true, 
            context: context, 
            builder: (context) => Dialog(
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
                    height: 290,
                    //Onde colocarei as imagens
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Column(
                        children: [
                          //Título 
                          const Text(
                            'Permição de notificação', 
                            textAlign: TextAlign.center, 
                            style: TextStyle(
                            fontFamily: 'DaysOne',
                              fontSize: 35,
                              color: Colors.black
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text( 
                              'A nossa aplicação gostaria de lhe enviar notificações', 
                              textAlign: TextAlign.center, 
                              style: TextStyle(
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

                                    child: const Text('Permitir', 
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                    ),
                                    onPressed: () {
                                      AwesomeNotifications().requestPermissionToSendNotifications().then((resposta){
                                        condicao = resposta;
                                        Navigator.pop(context);
                                      });
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

                                    child: const Text('Não permitir', 
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
                        Icons.notifications_active, 
                        color: Colors.white, 
                        size: 65
                      ),
                    )
                  ),
                ],
              )
            )
          );
        }
      }
    );
    return condicao;
  }

/*
  //Inicializar o plugin para mexer com dados no Dispositivo
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  //Criar um canal por defeito
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "channel_geral",
    "Geral",
    groupId: "default_notification_channel_id",
    enableVibration: true,
    importance: Importance.max,
    playSound: true,
  );

  //Quando clica na notificação
  static void onSelectedNotification(String? payload) async{
    try{
      debugPrint('Notification payload: $payload');

      if(payload != null && payload.isNotEmpty){
        Navigator.of(Routes.navigatorKey!.currentContext!).pushReplacementNamed(payload);
      }
    }
    catch(e){
      debugPrint('Erro ao enviar o payload: $e');
    }
  }

  static void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {

  }

  //! Função que será chamada na para a inicialização do serviço
  static void initialize() async{

    //Inicializo o Android
    const AndroidInitializationSettings androidinitializationSettings = AndroidInitializationSettings('ic_launcher');

    //Inicializo o Ios
    const IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    //Inicializo os inicializadores
    const InitializationSettings settings = InitializationSettings(
      android: androidinitializationSettings,
      iOS: iosInitializationSettings
    );

    //Incorporar as inicializações no dispositivo corrente
    await _notificationsPlugin.initialize(
      settings,
      onSelectNotification: onSelectedNotification
    );
  }
  
  //! 
  static Future<void> showNotification({required RemoteMessage message}) async{
    
    String titulo = message.notification?.title ?? 'Algo correu mal no título';
    String body = message.notification?.body ?? 'Algo correu mal com o contribuinte';
    
    //Verifica se as notificações ativas
    final List<ActiveNotification>? activeNotification = await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.getActiveNotifications();
    StyleInformation? estilo;

    //Agrupamento de mensagens na mesma notificação
    if(activeNotification != null && activeNotification.isNotEmpty){
      
      debugPrint("Lista de notificações ativas: ${activeNotification.length}");

      List<String> lines = activeNotification.map((e) => e.title.toString()).toList();
      
      //Design de como ficará agrupado
      estilo = InboxStyleInformation(
        lines, 
        contentTitle: "Parcerias ${activeNotification.length} messages", 
        summaryText: "${activeNotification.length} messages"
      );
    }
    else{
      //Caso a notificação seja para ir sozinha (Sem grupo)
      estilo = BigTextStyleInformation(
        body, 
        htmlFormatBigText: true,
        contentTitle: titulo,
        htmlFormatContentTitle: true,
      );
    }

    //Estrutura da notificação do android
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      groupKey: channel.groupId,
      styleInformation: estilo,
      enableVibration: channel.enableVibration,
      importance: channel.importance,
      playSound: channel.playSound,
      setAsGroupSummary: true,
      priority: Priority.high,
      //onlyAlertOnce: true
    );

    //Estrutura da notificação do Ios
    const IOSNotificationDetails iosNotificationDetail = IOSNotificationDetails();

    //Incorporar o design na notificação
    final details =  NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetail,
    );
    
    //Mostra a notificação no dispositivo com os dados recebidos do firebase e o design anteriormente criado
    await _notificationsPlugin.show(
      0, 
      titulo, 
      body, 
      details, 
      payload: message.data['pagina']
    );
  } 
  */
}