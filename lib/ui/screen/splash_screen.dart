import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:happy_bash/ui/device_registration_service.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/onboard_screen.dart';
import 'package:happy_bash/ui/screen/select_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../core/constants/image_constants.dart';
import '../../core/constants/navigator.dart';
import '../../core/constants/shared_preferences_utils.dart';
import '../../core/reusable.dart';
import '../../core/utils/permission_utills.dart';
import '../../network/base_url.dart';
import '../../core/utils/global_file.dart' as globals;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;
  late VideoPlayerController _controller;
  String pmDeviceType = "";
  String pmUniqueId = "";
  String pmToken = "";
  bool isDeviceRegistered = false;
  bool isUserLogin = false;

  Future<SharedPreferences> getSharedPreferences() async {
    prefs =  await SharedPreferences.getInstance();
    // isDeviceRegistered = prefs.getBool('deviceRegistration') ?? false;
    isDeviceRegistered = getIsDeviceRegistered(prefs);
    isUserLogin = getIsUserLogin(prefs);
    printMsgTag("isUserLogin", isUserLogin);
    pmUniqueId = getDeviceId(prefs);
    pmToken = getFcmToken(prefs);
    if (Platform.isAndroid) {
      pmDeviceType = "2";
    } else {
      pmDeviceType = "1";
    }
    setDeviceType(pmDeviceType);
    var fcmToken = await globals.notificationServices.getDeviceToken();
    setFcmToken(fcmToken);
    var deviceId = await globals.notificationServices.getDeviceId();
    setDeviceId(deviceId);
    print(" pmToken: $pmToken");
    return prefs;
  }

  Future getRegisterData() async {
    final rslt = await Future.delayed(
      const Duration(seconds: 1),
      () async {
        final result = await registerDevice();
        printMsgTag("resp Register:-", result);
        return result;
      },
    );
    print("rslt: $rslt");
    return rslt;
  }

  Future<Map<String, dynamic>?> registerDevice() async {
    // pmToken = sharedutils.getFCMToken(prefs);
    String reqParam = jsonEncode({
      "DeviceType": getDeviceType(prefs),
      "UniqueDeviceId": getDeviceId(prefs),
      "NotificationToken": getFcmToken(prefs),
      // "ClientKey": base64.encode(utf8.encode(pmUniqueId)),
      "ClientKey": "nzXgNGqRfh029okDkqlbWwyGNCDhL3Wn1v6koEPh",
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.registerDevice}"),
      headers: {"content-type": "application/json"},
      // headers: {"content-type": "application/json"},
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("register response", jsonResponse.body.toString());
        // print("register response${jsonResponse.body}");
        // setIsRegistered(true);
        final responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("register catch", exception.toString());
    }
    return null;
  }

  navigateHome() {
    Future.delayed(
      const Duration(seconds: 5),
      () {
        // navigateReplaceAll(
        //     context, BottomNavigationBarScreen(selectedIndex: 0));
        navigateReplaceAll(context, const SelectLanguageScreen());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    PermissionUtils.permissionServiceCall();
    globals.notificationServices.requestNotificationPermission();
    globals.notificationServices.isTokenRefresh();
    globals.notificationServices.forgroundMessage();
    globals.notificationServices.firebaseInit(context);
    globals.notificationServices.setupInteractMessage(context);
    _controller = VideoPlayerController.asset(ImageConstant.splashScreen);
    _controller.setVolume(0.0);
    // _controller.initialize().then((_) => setState(() {}));
    _controller.initialize();
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: PrimaryColors().primarycolor,
      backgroundColor: const Color(0xFFA9F1EB),
      body: FutureBuilder(
        future: getSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("Data ${snapshot.data}");
            if (isDeviceRegistered == true) {
              Future.delayed(const Duration(seconds: 6)).then((value) async {
                var index = 0;
                RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
                if (initialMessage != null) {
                  index = 5;
                }
    //Navigation to Home Screen with checking if user is login or not
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => getLanguage(prefs).isEmpty
                          ? const SelectLanguageScreen()
                          : getLocation(prefs).isNotEmpty || getIsUserLogin(prefs)
                              ? BottomNavigationBarScreen(selectedIndex: index)
                              : const OnBoardScreen(),
                    ),
                    (route) => false);
              });
            } else {
              setIsDeviceRegistered(true);
              navigateReplaceAll(context, const SelectLanguageScreen());
            }
          }
          return Center(
            child: AspectRatio(
              aspectRatio: 1 / 1.77,
              child: VideoPlayer(_controller),
            ),
          );
        },
      ),
    );
  }
}
