import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:happy_bash/core/utils/notification_service.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/onboard_screen.dart';
import 'package:happy_bash/ui/screen/select_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/shared_preferences_utils.dart';
import '../../core/utils/permission_utills.dart';
import '../../core/utils/global_file.dart' as globals;

class SplashScreenNew extends StatefulWidget {
  const SplashScreenNew({Key? key}) : super(key: key);

  @override
  State<SplashScreenNew> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenNew> {
  late SharedPreferences prefs;
  String pmDeviceType = "";
  String pmUniqueId = "";
  String pmToken = "";
  bool isDeviceRegistered = false;
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initializeApp();
  }

  Future<void> initializeApp() async {
    debugPrint("[SplashScreenNew] Initializing app");

    try {
      debugPrint("[SplashScreenNew] Requesting permissions and initializing notifications");
      await PermissionUtils.permissionServiceCall();
      debugPrint("[SplashScreenNew] Permissions granted");

      await globals.notificationServices.requestNotificationPermission();
      debugPrint("[SplashScreenNew] Notification permission requested");

      globals.notificationServices.isTokenRefresh();
      debugPrint("[SplashScreenNew] Token refresh setup");

      globals.notificationServices.forgroundMessage();
      debugPrint("[SplashScreenNew] Foreground message setup");

      globals.notificationServices.firebaseInit(context);
      debugPrint("[SplashScreenNew] Firebase initialized");

      globals.notificationServices.setupInteractMessage(context);
      debugPrint("[SplashScreenNew] Interact message setup");
    } catch (e) {
      debugPrint("[SplashScreenNew] Error during notification services initialization: $e");
    }

    try {
      prefs = await SharedPreferences.getInstance();
      debugPrint("[SplashScreenNew] SharedPreferences initialized");

      isDeviceRegistered = getIsDeviceRegistered(prefs);
      isUserLogin = getIsUserLogin(prefs);

      pmUniqueId = getDeviceId(prefs) ?? 'unknown_device';
      pmToken = getFcmToken(prefs) ?? 'unknown_token';

      pmDeviceType = Platform.isAndroid ? "2" : "1";
      setDeviceType(pmDeviceType);

      debugPrint("[SplashScreenNew] Device type : $pmDeviceType, Unique ID: $pmUniqueId, Token: $pmToken");

      debugPrint("[SplashScreenNew] started to fetch fcm token : yes");

      String? fcmToken = await NotificationServices().getDeviceToken();
      if(fcmToken != null) {
        debugPrint("[SplashScreenNew] FCM Token: $fcmToken");
      } else {
        debugPrint("[SplashScreenNew] FCM Token: null");
      }
      setFcmToken(fcmToken ?? 'unknown_fcm_token');

      String? deviceId = await globals.notificationServices.getDeviceId();
      debugPrint("[SplashScreenNew] Device ID: ${deviceId ?? 'null'}");
      setDeviceId(deviceId ?? 'unknown_device_id');
    } catch (e) {
      debugPrint("[SplashScreenNew] Error during SharedPreferences or device setup: $e");
    }


    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    int index = 0;
    try {
      debugPrint("[SplashScreenNew] Checking for initial Firebase message");
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("[SplashScreenNew] Initial message received: $initialMessage");
        index = 5;
      }
    } catch (e) {
      debugPrint("[SplashScreenNew] Error checking for initial message: $e");
    }
    // Adding a delay of 5 seconds before navigation
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => getLanguage(prefs).isEmpty
            ? const SelectLanguageScreen()
            : getLocation(prefs).isNotEmpty || getIsUserLogin(prefs)
            ? BottomNavigationBarScreen(selectedIndex: index)
            : const OnBoardScreen(),
      ),
          (route) => false,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFF2A9DA0),
  //     body: Center(
  //       child: Center(
  //         child: Container(
  //           width: 222,
  //           height: 222,
  //           decoration: const BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: Color(0xFFFFFFFF),
  //           ),
  //           child: Image.asset(
  //             'assets/images/Happy_Bash1.png',
  //             scale: 5,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A9DA0),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3fa7aa),
          ),
          child: Center(
            child: Container(
              width: 222,
              height: 222,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFFFFF),
              ),
              child: Image.asset(
                'assets/images/Happy_Bash1.png',
                scale: 5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}