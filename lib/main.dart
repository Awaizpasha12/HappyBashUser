import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_bash/ui/screen/select_languages.dart';
import 'package:happy_bash/ui/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:happy_bash/ui/screen/splash_screen_new.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HappyBash User',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: const SplashScreenNew(),
    );
  }
}
