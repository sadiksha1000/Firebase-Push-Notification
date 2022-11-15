import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifier/main_screen.dart';
import 'package:push_notifier/navigation.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingbackgroundHandler(RemoteMessage message) async {
  print("Handling a background message ${message.messageId}");
}

selectNotification(NotificationResponse notification) async {
  print("Notification ${notification}");

  print("Payload Input ${notification.input}");
  print("Payload ${notification.payload}");
  print("Action ID ${notification.actionId}");
  print("ID ${notification.id}");

  print("Here at select notification");
  try {
    if (notification.payload != null) {
      print("Payload clicked");
      _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => MainScreen(args: notification.payload)));
    } else {}
  } catch (e) {}
  return;
}

// Future<void> _firebaseMessagingforegroundHandler(RemoteMessage message) async {
//   print("Handling a foregroundmessage ${message.messageId}");
// }

initInfo() {
  var androidInitialize =
      const AndroidInitializationSettings('drawable/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: androidInitialize);
  flutterLocalNotificationPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: selectNotification,
    onDidReceiveNotificationResponse: selectNotification,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("--------------------On message------------------");
    print(
        "Message :${message.notification?.title}/${message.notification?.body}");

    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatContent: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pushnotifier',
      'pushnotifier',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: false,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    print(message.data.toString() + "payload");
    await flutterLocalNotificationPlugin.show(
        Random().nextInt(100),
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data));
  });
}

Future<void> setupInteractedMessage() async {
  print("I am setup interact message");
  // Get any messages which caused the application to open from
  // a terminated state.
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  print("Initial Message $initialMessage");
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  // Also handle any interaction when the app is in the background via a
  // Stream listener
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  _navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => MainScreen(args: message.notification!.body)));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onMessageOpenedApp;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingbackgroundHandler);
  setupInteractedMessage();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Mainscreen(),
        routes: {
          mainScreen: (context) => Mainscreen(),
        });
  }
}

class Mainscreen extends StatefulWidget {
  const Mainscreen({Key? key}) : super(key: key);

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  String? myToken = '';

  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        myToken = token;
        print("My token $myToken");
      });
      print("Got token");
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
      'token': token,
    });
    // await FirebaseDatabase.instance.reference.child('');
    print("Token saved");
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Provisional permission granted");
    } else {
      print('Permission declined');
    }
    print("Finished reading permission");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            GestureDetector(
              onTap: () async {
                String name = username.text.trim();
                String titleText = title.text;
                String bodyText = body.text;

                if (name != "") {
                  DocumentSnapshot snap = await FirebaseFirestore.instance
                      .collection("User Tokens")
                      .doc(name)
                      .get();
                  String token = snap['token'];
                  print("Token at gesture detector $token");
                }
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                    )
                  ],
                ),
                child: const Center(
                  child: Text('Submit', style: TextStyle(fontSize: 23)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
