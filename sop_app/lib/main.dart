import 'package:flutter/material.dart';
import 'package:sop_app/pages/admin_page.dart';

import './services/navigation_service.dart';
import 'package:provider/provider.dart';

//Packages
import 'package:firebase_analytics/firebase_analytics.dart';
import './pages/splash_page.dart';

import './providers/authentication_provider.dart';
import './providers/sop_page_provider.dart';
import './services/database_service.dart';

import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () async {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        runApp(
          MainApp(),
        );
      },
    ),
  );
}


class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider();
          },
        ),
        ChangeNotifierProvider<SopPageProvider>(
          create: (BuildContext _context) {
            return SopPageProvider();
          },
        ),
        Provider<DatabaseService>(
          create: (BuildContext _context) {
            return DatabaseService();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Student Management',
        theme: ThemeData(
          colorScheme:
          ColorScheme.dark(background: Color.fromRGBO(36, 35, 49, 1.0)),
          scaffoldBackgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
          '/register': (BuildContext _context) => RegisterPage(),
        },
        // Remove the '/home' route
        // '/home': (BuildContext _context) => HomePage(),
      ),
    );
  }
}

void navigateToHomePage(BuildContext context) async {
  final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
  final currentUser = authProvider.currentUser;
  if (currentUser != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(currentUser: currentUser),
      ),
    );
  } else {
    print("Error: currentUser is null");
  }

}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}
