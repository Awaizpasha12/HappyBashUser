import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/otp_verify_page.dart';
import 'package:happy_bash/ui/screen/sign_up_google.dart';
import 'package:happy_bash/ui/screen/sign_up_screen.dart';

import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  var obscureTextPass = true;
  String password = "";
  String? email;
  String? phone;
  String? userId;
  //User? user;
  String countryCode = "+965";
  //........function of register with google api definition..........//
  Future<Map<String, dynamic>?> registerWithGoogleWithPostApi(User userData) async {
    var responseData;
    String reqParm = jsonEncode({
      "email": userData.email,
      "id_token": userData.uid,
      //....Check if phone number is not null then pass it otherwise null.....//
      if(userData.phoneNumber != null) userData.phoneNumber : null,
    });
    print(reqParm);
    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.googleSignup}"),

      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
      },
      body: reqParm,
    );
    responseData = jsonDecode(response.body.toString());
    print("${BaseUrl.globalUrl}/${BaseUrl.googleSignup}");
    print(userData.phoneNumber);
    print(response.statusCode);
    // if Status code is 401 then go to add mobile Number screen(SignUpGoogle)......//
    if (response.statusCode == 401) {
      if(phone == null){
        Navigator.push(context,  MaterialPageRoute(builder: (context) => SignUpGoogle(useremail: userData.email,userId: userData.uid) ),);
      }
      printMsgTag("Registration successful.", response.body.toString());
    }
    // if Status code is 200 means user is register successfully then go to BottomNavigationBarScreen(Home screen)......//
    else if (response.statusCode == 200) {
      setIsUserLogin(true);
      setToken(responseData['token']);
      showSnackBar(
          context, "Registration successful.");
      navigateReplaceAll(
        context,
        BottomNavigationBarScreen(
            selectedIndex: 0),
      );
    }
    return null;



  }

  // ...........Google Authentication Function with Firebase............
  bool signInWithGoogleLoader = false;
  signInWithGoogle() async {
    try {
      signInWithGoogleLoader = true;
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      signInWithGoogleLoader = false;
      //.....check if user is not null .....//
      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        // Google Authorization user..........
        User user = userCredential.user!;
        //........ call Api of register with google........//
        registerWithGoogleWithPostApi(user);
      }
    } on PlatformException catch (e) {
      signInWithGoogleLoader = false;
      print("Something went wrong");
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: e.message ?? "abcd",
        okBtnFunction: () => Navigator.pop(context),
      );
    } on FirebaseAuthException catch (e) {
      signInWithGoogleLoader = false;
      print("Something went wrong");
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: e.message ?? "defg",
        okBtnFunction: () => Navigator.pop(context),
      );
      //showSnackBar(title: ApiConfig.error, message: e.message ?? "Something want wrong ..");

      return e.message;
    }
    // user.getIdToken(true).then((idToken) {
    //   signInWithGoogleLoader.value = false;
    //   googleIdToken.value = idToken ?? "";
    //   // print(idToken);
    // }
    // ).catchError((error) {
    //   showSnackBar(title: ApiConfig.error, message: "Something want wrong ..");
    // });
  }

  // signInWithApple() async {
  //   try {
  //     signInWithGoogleLoader = true;
  //     final appleProvider = AppleAuthProvider();
  //     var auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
  //     var gUser = auth.user;
  //
  //     // final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
  //     signInWithGoogleLoader = false;
  //     //.....check if user is not null .....//
  //     if (gUser != null) {
  //       registerWithGoogleWithPostApi(gUser);
  //     }
  //   } on PlatformException catch (e) {
  //     signInWithGoogleLoader = false;
  //     print("Something went wrong");
  //     ModelUtils.showSimpleAlertDialog(
  //       context,
  //       title: const Text('Invalid credentials'),
  //       content: e.message ?? "abcd",
  //       okBtnFunction: () => Navigator.pop(context),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     signInWithGoogleLoader = false;
  //     print("Something went wrong");
  //     ModelUtils.showSimpleAlertDialog(
  //       context,
  //       title: const Text('Invalid credentials'),
  //       content: e.message ?? "defg",
  //       okBtnFunction: () => Navigator.pop(context),
  //     );
  //     //showSnackBar(title: ApiConfig.error, message: e.message ?? "Something want wrong ..");
  //
  //     return e.message;
  //   }
  //   // user.getIdToken(true).then((idToken) {
  //   //   signInWithGoogleLoader.value = false;
  //   //   googleIdToken.value = idToken ?? "";
  //   //   // print(idToken);
  //   // }
  //   // ).catchError((error) {
  //   //   showSnackBar(title: ApiConfig.error, message: "Something want wrong ..");
  //   // });
  // }



  Future<void> signInWithApple() async {
    try {
      signInWithGoogleLoader = true;
      print("Starting Apple Sign-In...");

      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      var auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      var gUser = auth.user;

      print("Authentication successful!");
      print("Firebase User: ${gUser?.uid}");

      // Initialize email variable
      String? email = gUser?.email;
      String? uid = gUser?.uid;

      print("Checking Firebase user email: $email");

      // Try fetching email from additionalUserInfo
      if (email == null && auth.additionalUserInfo?.profile != null) {
        email = auth.additionalUserInfo?.profile?["email"];
        print("Fetched email from additionalUserInfo: $email");
      }

      // Log entire additionalUserInfo to check available fields
      print("Additional User Info: ${auth.additionalUserInfo?.profile}");

      // Try fetching email directly from Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print("Apple Credential Retrieved.");
      print("Apple ID: ${appleCredential.userIdentifier}");
      print("Apple Email: ${appleCredential.email}");
      print("Apple Full Name: ${appleCredential.givenName} ${appleCredential.familyName}");

      // Use email from Apple credential if available
      if (email == null) {
        email = appleCredential.email;
        print("Email obtained from Apple credentials: $email");
      }

      print("Final Email Value: $email");

      signInWithGoogleLoader = false;

      if (gUser != null) {
        registerWithGoogleWithPostApi(gUser);
      }
    } on PlatformException catch (e) {
      signInWithGoogleLoader = false;
      print("PlatformException: ${e.message}");
    } on FirebaseAuthException catch (e) {
      signInWithGoogleLoader = false;
      print("FirebaseAuthException: ${e.message}");
    } catch (e) {
      signInWithGoogleLoader = false;
      print("Unexpected Error: $e");
    }
  }

  Future<Map<String, dynamic>?> loginPostApi() async {
    var responseData;

    String reqParam = jsonEncode({
      "email": email,
      "password": password,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.login}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json"
      },
      // headers: {"content-type": "application/json"},
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("sendOTPPostApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        // showSnackBar(context, jsonResponse["Message"]);
        throw Exception;
      }
    } catch (exception) {
      // showSnackBar(context, jsonDecode(jsonResponse.body)['message']);
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: jsonDecode(jsonResponse.body)['message'],
        okBtnFunction: () => Navigator.pop(context),
      );
      printMsgTag("sendOTPPostApi catch", exception.toString());
    }
    return responseData;
  }
  //.........Login with phone number and with OTP verification......//
  Future<Map<String, dynamic>?> sendLoginOTPPostApi() async {
    var responseData;
    String reqParam = jsonEncode({
      // "country_code": "+965",
      "email": countryCode,
      "id_token": userId,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.sendLoginOTP}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json"
      },
      // headers: {"content-type": "application/json"},
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("sendOTPPostApi response", jsonResponse.body.toString());
        // print("register response${jsonResponse.body}");
        // setIsRegistered(true);
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        // showSnackBar(context, jsonResponse["Message"]);
        throw Exception;
      }
    } catch (exception) {
      // showSnackBar(context, jsonDecode(jsonResponse.body)['message']);
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: jsonDecode(jsonResponse.body)['message'],
        okBtnFunction: () => Navigator.pop(context),
      );
      printMsgTag("sendOTPPostApi catch", exception.toString());
    }
    return responseData;
  }
  //..........Login with phone number using OTP verification..........//
  Future<Map<String, dynamic>?> sendOTPPostApi() async {
    var responseData;
    String reqParam = jsonEncode({
      // "country_code": "+965",
      "country_code": countryCode,
      "phone": phone,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());
    print("url : ${BaseUrl.globalUrl}/${BaseUrl.sendOtp}");
    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.sendOtp}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json"
      },
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("sendOTPPostApi response", jsonResponse.body.toString());
        // print("register response${jsonResponse.body}");
        // setIsRegistered(true);
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        // showSnackBar(context, jsonResponse["Message"]);
        throw Exception;
      }
    } catch (exception) {
      print(jsonResponse.body);
      // showSnackBar(context, jsonDecode(jsonResponse.body)['message']);
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: jsonDecode(jsonResponse.body)['error'] ?? "Something went wrong. Please retry!",
        okBtnFunction: () => Navigator.pop(context),
      );
      printMsgTag("sendOTPPostApi catch", exception.toString());
    }
    return responseData;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: width,
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFEAF5F5), Color(0x00EAF5F5)],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 77,
            child: Image.asset(ImageConstant.happy),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  77.ph,
                  const Row(
                    children: [
                      Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF1D2939),
                          fontSize: 32,
                          fontFamily: serifRegular,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  10.ph,
                  TabBar(
                    labelColor: PrimaryColors().primarycolor,
                    unselectedLabelColor: const Color(0xFF9B9B9B),
                    labelStyle: const TextStyle(
                      color: Color(0xFF2A9DA0),
                      fontSize: 14,
                      fontFamily: poppinsSemiBold,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: PrimaryColors().primarycolor,
                    tabs: const [
                      Tab(
                        text: "Email",
                      ),
                      Tab(
                        text: "Phone number",
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        //---- Login with Email ----//
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            30.ph,
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    validator: (email) {
                                      if (email == null || email.isEmpty) {
                                        return "Please enter email";
                                      } else if (!EmailValidator.validate(
                                          email)) {
                                        return "Enter valid email id";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      email = value!;
                                      printMsgTag("allergies", email);
                                    },
                                  ),
                                  20.ph,
                                  TextFormField(
                                    obscureText: obscureTextPass,
                                    decoration: InputDecoration(
                                      // isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            obscureTextPass = !obscureTextPass;
                                          });
                                        },
                                        child: obscureTextPass == true
                                            ? const Icon(
                                                Icons.visibility_off,
                                                color: Colors.grey,
                                                size: 20,
                                              )
                                            : Icon(
                                                Icons.visibility,
                                                color: PrimaryColors()
                                                    .primarycolor,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    validator: (password) {
                                      if (password == null ||
                                          password.isEmpty) {
                                        return "Please enter password";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      password = value!;
                                      printMsgTag("allergies", password);
                                    },
                                  ),
                                  20.ph,
                                  // const Row(
                                  //   children: [
                                  //     Text.rich(
                                  //       TextSpan(
                                  //         children: [
                                  //           TextSpan(
                                  //             text: 'Forgot password?',
                                  //             style: TextStyle(
                                  //               color: Color(0xFF595959),
                                  //               fontSize: 14,
                                  //               fontFamily: poppinsMedium,
                                  //               fontWeight: FontWeight.w400,
                                  //             ),
                                  //           ),
                                  //           TextSpan(
                                  //             text: ' ',
                                  //             style: TextStyle(
                                  //               color: Color(0xFF595959),
                                  //               fontSize: 14,
                                  //               // fontFamily: 'Poppins',
                                  //               fontWeight: FontWeight.w500,
                                  //             ),
                                  //           ),
                                  //           TextSpan(
                                  //             text: 'Reset it',
                                  //             style: TextStyle(
                                  //               color: Color(0xFF2A9DA0),
                                  //               fontSize: 14,
                                  //               fontFamily: poppinsSemiBold,
                                  //               fontWeight: FontWeight.w600,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       textAlign: TextAlign.center,
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                            26.ph,
                            MaterialButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  loginPostApi().then((value) {
                                    if (value != null) {
                                      if (value['message'] ==
                                          "Login successful.") {
                                        setIsUserLogin(true);
                                        setToken(value['token']);
                                        showSnackBar(
                                            context, "Login successfully...");
                                        navigateReplaceAll(
                                          context,
                                          BottomNavigationBarScreen(
                                              selectedIndex: 0),
                                        );
                                      }
                                    }
                                  });
                                }
                              },
                              minWidth: width,
                              height: 40,
                              color: PrimaryColors().primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Text(
                                'LOG IN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: poppinsSemiBold,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            20.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                10.pw,
                                const SizedBox(
                                  height: 20,
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Color(0xFF9B9B9B),
                                      fontSize: 14,
                                      fontFamily: poppinsMedium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                10.pw,
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            26.ph,
                            const Row(
                              children: [
                                Text(
                                  'Continue with',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: poppinsRegular,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            20.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        signInWithGoogle();
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    ImageConstant.google),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        signInWithApple();
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    ImageConstant.apple),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        //---- Login with Phone number ----//
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            30.ph,
                            Form(
                              key: _formKey1,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                      // isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                      hintText: 'Phone number',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // setState(() {
                                            //   if (countryCode == "+965") {
                                            //     countryCode = "+91";
                                            //   } else {
                                            //     countryCode = "+965";
                                            //   }
                                            // });
                                          },
                                          child: Text(
                                            // "+965",
                                            countryCode,
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFEDEDED)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      // FilteringTextInputFormatter.allow(
                                      //     RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[٠-٩0-9]')),
                                      // FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (mobileNo) {
                                      if (mobileNo == null ||
                                          mobileNo.isEmpty) {
                                        return "Enter mobile number";
                                      }
                                      if (countryCode == "+965" &&
                                          mobileNo.length != 8) {
                                        return "Mobile number should be alteast 8 digits only";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      phone = value!;
                                      printMsgTag("phoneNumber", phone);
                                    },
                                  ),
                                  20.ph,
                                  const Row(
                                    children: [
                                      Text(
                                        'We will send a message with a verification code',
                                        style: TextStyle(
                                          color: Color(0xFF595959),
                                          fontSize: 12,
                                          fontFamily: poppinsRegular,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            26.ph,
                            MaterialButton(
                              onPressed: () {
                                if (_formKey1.currentState!.validate()) {
                                  _formKey1.currentState!.save();
                                  sendOTPPostApi().then((value) {
                                    printMsgTag("sendOtpValue", value);
                                    if (value != null) {
                                      if (value['message'] == "OTP sent successfully") {
                                        navigateAddScreen(
                                            context,
                                            OtpVerificationPage(
                                              navigateFrom: 'login',
                                              phoneNumber: "$countryCode$phone",
                                              phoneNumberWithoutCountryCode: phone ?? "",
                                              countryCode: countryCode,
                                            ));
                                      }
                                    }
                                  });
                                }
                              },
                              minWidth: width,
                              height: 40,
                              color: PrimaryColors().primarycolor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(36)),
                              child: const Text(
                                'CONTINUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: poppinsSemiBold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            20.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                10.pw,
                                const SizedBox(
                                  height: 20,
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Color(0xFF9B9B9B),
                                      fontSize: 14,
                                      fontFamily: poppinsMedium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                10.pw,
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            26.ph,
                            const Row(
                              children: [
                                Text(
                                  'Continue with',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: poppinsRegular,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            20.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        signInWithGoogle();
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    ImageConstant.google),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: Container(
                                //     height: 40,
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 8, vertical: 10),
                                //     decoration: ShapeDecoration(
                                //       color: const Color(0xFFF6F6F6),
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(36),
                                //       ),
                                //     ),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.center,
                                //       children: [
                                //         Container(
                                //           width: 20,
                                //           height: 20,
                                //           clipBehavior: Clip.antiAlias,
                                //           decoration: BoxDecoration(
                                //             image: DecorationImage(
                                //               image: AssetImage(
                                //                   ImageConstant.facebook),
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        signInWithApple();
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    ImageConstant.apple),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: SizedBox(
        width: width,
        height: 44,
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Don’t have an account?',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: poppinsMedium,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const TextSpan(
                  text: ' ',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    // fontFamily: 'Popins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: 'Sign up',
                  style: const TextStyle(
                    color: Color(0xFF2A9DA0),
                    fontSize: 14,
                    fontFamily: poppinsSemiBold,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      navigateAddScreen(context, const SignUpScreen());
                    },
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

}
