// import 'dart:convert';

// import 'base_url.dart';

// Future<Map<String, String>> getHeaders() async {
//   Map<String, String> headers = {"content-type": "application/json"};
//   String key = await getDeviceIdHeaders();
//   if (key != "") {
//     headers = {
//       "content-type": "application/json",
//       // "X-NailItMobile-SecurityToken": base64.encode(utf8.encode(key))
//       BaseUrl.appHeader: base64.encode(utf8.encode(key))
//     };
//   } else {
//     headers = {"content-type": "application/json"};
//   }
//   printMsgTag("headers==>", headers);
//   // print("headers==>" + headers);

//   return headers;
// }
