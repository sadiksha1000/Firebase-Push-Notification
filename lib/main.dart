import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifier/main_screen.dart';
import 'package:push_notifier/navigation.dart';
import 'package:push_notifier/user.dart';
import 'package:push_notifier/weather.dart';
import 'package:push_notifier/weather_details.dart';

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
  var payloadResponse = notification.payload;

  Map<String, dynamic> weatherMap = json.decode(payloadResponse!);

  WeatherForecast weather = WeatherForecast.fromJson(weatherMap);
  String latitude = weather.latitude!;
  String longitude = weather.longitude!;
  print("Lat $latitude");
  print("Long $longitude");
  APICall(latitude, longitude);
  return;
}

void APICall(String latitude, String longitude) async {
  var url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=9d9a9e48647a4facb66334d9a0fbf599';
  var response = await http.get(Uri.parse(url));
  print("API Call Response $response");
  print("API Call Response Body ${response.body}");
  Map<String, dynamic> parsedWeather = json.decode(response.body);
  print("Parsed Weather $parsedWeather");
  String lat = parsedWeather['coord']['lat'].toString();
  String lon = parsedWeather['coord']['lon'].toString();
  String country = parsedWeather['sys']['country'];
  String address = parsedWeather['name'];
  String maxTemp = parsedWeather['main']['temp_max'].toString();
  String minTemp = parsedWeather['main']['temp_min'].toString();
  WeatherDetails weatherDetails = WeatherDetails(
    address: address,
    latitude: lat,
    longitude: lon,
    country: country,
    maxTemp: maxTemp,
    minTemp: minTemp,
  );
  try {
    if (response.body != null) {
      _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => MainScreen(args: weatherDetails)));
    }
  } catch (e) {
    print(e);
  }
}

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onMessageOpenedApp;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingbackgroundHandler);
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
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 23,
            ),
            displaySmall: TextStyle(
              fontSize: 16,
            ),
          ),
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
