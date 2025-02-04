import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../ui/screen/bottom_navigation_screen.dart';
import '../constants/navigator.dart';
import '../constants/shared_preferences_utils.dart';
import '../enums/platform_name.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          // globals.logger.e("Payload: $payload");
          // handle interaction when app is active for android
          handleMessage(context, message);
        });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) async {
      // Check if notifications are enabled
      if (await getIsNotificationEnabled()) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification!.android;

        if (kDebugMode) {
          debugPrint("notifications title:${notification!.title}");
          debugPrint("notifications body:${notification.body}");
          debugPrint('count:${android!.count}');
          debugPrint('data:${message.data.toString()}');
        }

        if (Platform.isIOS) {
          if(message.notification != null){
            //show simple dialog to show notification when in the foreground
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(message.notification!.title ?? 'Notification'),
                  content: Text(message.notification!.body ?? 'No content'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
                  ],
                ));
          }


          forgroundMessage();
        }

        if (Platform.isAndroid) {
          initLocalNotifications(context, message);
          showNotification(message);
        }
      }
    });
  }
  Future<String> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          debugPrint('[SplashScreenNew] User granted permission');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          debugPrint('[SplashScreenNew] User granted provisional permission');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[SplashScreenNew] User denied permission');
        }
        // Optionally, open app settings if permissions are denied
        // appsetting.AppSettings.openNotificationSettings();
      }
      return "true";  // Consider returning a more meaningful status if needed
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[SplashScreenNew] Error during notification services initialization: $e");
      }
      return "false";  // Indicate failure in obtaining permission
    }
  }


  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.max,
        showBadge: true,
        playSound: true);
    //sound: const RawResourceAndroidNotificationSound('jetsons_doorbell'));

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
        sound: channel.sound
      //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
      //  icon: largeIconPath
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //function to get device token on which we will send the notifications
  Future<String?> getDeviceToken() async {
    String? token;
    try {
      if (getPlatformName() == "ios") {
            if(messaging != null) {
              debugPrint("[SplashScreenNew] messaging is not null");
              token = await messaging.getAPNSToken();
            }
            else{
              debugPrint("[SplashScreenNew] messaging is null");
            }
          } else {
            token = await messaging.getToken();
          }
    } catch (e) {
      debugPrint("[SplashScreenNew] got exception $e");
    }
    return token;
  }
  static String getPlatformName() {
    return Platform.isAndroid
        ? PlatformName.android.name
        : PlatformName.ios.name;
  }
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        debugPrint('refresh');
      }
    });
  }
  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique ID on Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor; // Unique ID on iOS
    }
    return null;
  }
  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {


    // NavigatorService.pushNamedAndRemoveUntil(AppRoutes.notificationScreen);
    navigateReplaceAll(
        context,
        BottomNavigationBarScreen(
            selectedIndex: 5));
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Method used to get current timestamp
  String getCurrentTimestamp() {
    DateTime dt = DateTime.now();
    final utcIso8601 = dt.toUtc().toIso8601String();
    // globals.logger.i("Current Timestamp: $utcIso8601");
    return utcIso8601;
  }
}
