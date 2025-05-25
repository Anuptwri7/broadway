import 'package:classboradway/providers/dropdownProvider.dart';
import 'package:classboradway/providers/loginProvider.dart';
import 'package:classboradway/sellerApp/mainPage.dart';
import 'package:classboradway/ui/createProduct.dart';
import 'package:classboradway/ui/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

import 'package:provider/provider.dart';
import 'extraDose/animation.dart';
import 'extraDose/cal.dart';

import 'integration/notificationServices.dart';
import 'loginPage.dart';
import 'mainPage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService.initialize();
  await NotificationService().init();

  FirebaseInAppMessaging.instance.triggerEvent("my_custom_event");
  FirebaseInAppMessaging.instance.setMessagesSuppressed(false);

  getDeviceToken();
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  runApp(MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: 'test_public_key_5c5fa086bb704a54b1efd924a2acb036',
      builder: (context, e) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          routes: {
            // '/home': (context) => HomePage(),
            '/mainPage': (context) => MainPage(),
            '/createProduct': (context) => Createproduct(),
          },
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home:  HomePage(),
          navigatorKey: e,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ne', 'NP'),
          ],
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
        );
      },
    );
  }
}
void getDeviceToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}