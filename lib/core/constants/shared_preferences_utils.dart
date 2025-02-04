import 'package:shared_preferences/shared_preferences.dart';

setIsDeviceRegistered(isRegistered) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("isRegistered", isRegistered);
}

bool getIsDeviceRegistered(SharedPreferences? upref) {
  bool value = upref?.getBool("isRegistered") ?? false;
  return value;
}

setDeviceId(deviceId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("deviceId", deviceId);
}

String getDeviceId(SharedPreferences upref) {
  String value = upref.getString("deviceId") ?? "";
  return value;
}

setToken(token) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("token", token);
}

Future<String> getToken() async {
  SharedPreferences upref = await SharedPreferences.getInstance();
  String value = upref.getString("token") ?? "";
  return value;
}

setIsUserLogin(isLogin) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("userLogin", isLogin);
}

bool getIsUserLogin(SharedPreferences? upref) {
  bool value = upref?.getBool("userLogin") ?? false;
  return value;
}

setLocation(location) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("location", location);
}

String getLocation(SharedPreferences upref) {
  String value = upref.getString("location") ?? "";
  return value;
}

setLanguage(language) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("language", language);
}

String getLanguage(SharedPreferences upref) {
  String value = upref.getString("language") ?? "";
  return value;
}

setFavouriteId(List<String> value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  value ??= [];
  pref.setStringList("favouriteid", value);
}

List<String> getFavouriteId(SharedPreferences upref) {
  // SharedPreferences upref = await SharedPreferences.getInstance();
  List<String> value = upref.getStringList("favouriteid") ?? [];
  return value;
}

Future<List<String>> futuregetFavouriteId() async {
  SharedPreferences upref = await SharedPreferences.getInstance();
  List<String> value = upref.getStringList("favouriteid") ?? [];
  return value;
}

setPassword(password) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("password", password);
}

Future<String> getPassword() async {
  SharedPreferences upref = await SharedPreferences.getInstance();
  String value = upref.getString("password") ?? "";
  return value;
}

setFcmToken(fcmToken) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("fcmToken", fcmToken);
}

String getFcmToken(SharedPreferences upref) {
  String value = upref.getString("fcmToken") ?? "";
  return value;
}

setDeviceType(type) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("deviceType", type);
}

String getDeviceType(SharedPreferences upref) {
  String value = upref.getString("deviceType") ?? "";
  return value;
}

setIsFcmRegistered(isRegistered) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("isFcmRegistered", isRegistered);
}

bool getIsFcmRegistered(SharedPreferences? upref) {
  bool value = upref?.getBool("isFcmRegistered") ?? false;
  return value;
}

setNotificationEnabled(val) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("isNotificationEnabled", val);
}

Future<bool> getIsNotificationEnabled() async {
  SharedPreferences upref = await SharedPreferences.getInstance();
  bool value = upref?.getBool("isNotificationEnabled") ?? true;
  return value;
}
