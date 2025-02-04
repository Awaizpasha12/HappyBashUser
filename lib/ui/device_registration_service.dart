import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/shared_preferences_utils.dart';
import '../core/reusable.dart';
import '../network/base_url.dart';

class DeviceRegistrationService {
  late SharedPreferences prefs;

  // Initialize SharedPreferences in the constructor
  DeviceRegistrationService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>?> registerDevice() async {
    // Wait until prefs is initialized
    await _initPrefs();
    String token = await getToken();
    String reqParam = jsonEncode({
      "DeviceType": getDeviceType(prefs),
      "UniqueDeviceId": getDeviceId(prefs),
      "NotificationToken": getFcmToken(prefs),
      "ClientKey": "nzXgNGqRfh029okDkqlbWwyGNCDhL3Wn1v6koEPh",
    });

    printMsgTag("reqParam := ", reqParam);

    try {
      final jsonResponse = await http.post(
        Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.registerDevice}"),
        headers: {"content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: reqParam,
      );

      if (jsonResponse.statusCode == 200) {
        printMsgTag("register response", jsonResponse.body.toString());
        return jsonDecode(jsonResponse.body.toString());
      } else {
        printMsgTag("register failed", "Status Code: ${jsonResponse.statusCode}");
        return null;
      }
    } catch (exception) {
      printMsgTag("register catch", exception.toString());
      return null;
    }
  }

  // Future<Map<String, dynamic>?> getRegisterData() async {
  //   // Wait until prefs is initialized
  //   await _initPrefs();
  //
  //   final result = await Future.delayed(
  //     const Duration(seconds: 1),
  //         () async {
  //       return await registerDevice();
  //     },
  //   );
  //
  //   print("Result from getRegisterData: $result");
  //   return result;
  // }
}
