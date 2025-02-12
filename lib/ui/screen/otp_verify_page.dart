import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/create_account_screen.dart';
import 'package:happy_bash/ui/screen/location_screen.dart';
import 'package:happy_bash/ui/screen/login_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/dialog_box.dart';
import '../../core/constants/image_constants.dart';
import '../../core/constants/navigator.dart';
import '../../core/constants/shared_preferences_utils.dart';
import '../../core/utils/size_utils.dart';
import '../../network/base_url.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    Key? key,
    required this.navigateFrom,
    required this.phoneNumber,
    required this.phoneNumberWithoutCountryCode,
    required this.countryCode,
  }) : super(key: key);
  final String navigateFrom;
  final String phoneNumber;
  final String phoneNumberWithoutCountryCode;
  final String countryCode;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  String smsCode = "";
  int _countdown = 60;
  late Timer _timer;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_countdown < 1) {
          timer.cancel();
        } else {
          _countdown = _countdown - 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> verifyOTPPostApi(String pin) async {
    var responseData;
    String token = await getToken();
    String countryCode = "+965";
    if (widget.phoneNumber.length > 8) {
      countryCode = "+91";
    }
    String reqParam = jsonEncode({
      "otp": pin,
      "phone": widget.phoneNumber,
    });

    printMsgTag("reqParam:=", reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.verifyOtp}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
      },
      // headers: {"content-type": "application/json"},
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("verifyOTPPostApi response", jsonResponse.body.toString());
        // print("register response${jsonResponse.body}");
        // setIsRegistered(true);
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        responseData = jsonDecode(jsonResponse.body);
        // showSnackBar(context, responseData['error']);
        ModelUtils.showSimpleAlertDialog(
          context,
          title: const Text('Invalid Verification Code'),
          content: jsonDecode(jsonResponse.body)['error'],
          okBtnFunction: () {
            pinController.clear();
            Navigator.pop(context);
          },
        );
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("verifyOTPPostApi catch", exception.toString());
    }
    return responseData;
  }

  Future<Map<String, dynamic>?> loginPostApi() async {
    var responseData;

    String reqParam = jsonEncode({
      "phone": widget.phoneNumber,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString
    // ());

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
      // ignore: use_build_context_synchronously
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

  Future<Map<String, dynamic>?> sendOTPPostApi() async {
    setState(() {
      isLoading = true;
    });
    var responseData;
    String reqParam = jsonEncode({
      // "country_code": "+965",
      "country_code": "+965",
      "phone": widget.phoneNumberWithoutCountryCode,
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
        setState(() {
          isLoading = false;
        });
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
    setState(() {
      isLoading = false;
    });
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    String secondsStr = _countdown < 10 ? '0$_countdown' : '$_countdown';

    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A9DA0)),
        ),
      )
          : Stack(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.ph,
                  const Text(
                    'Enter verification\ncode',
                    style: TextStyle(
                      color: Color(0xFF1D2939),
                      fontSize: 32,
                      fontFamily: serifRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  20.ph,
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                          'Enter the 6-digit code we sent over SMS to (+965) ${widget.phoneNumber.substring(0, 4)}-${widget.phoneNumber.substring(4)}  ',
                          style: const TextStyle(
                            color: Color(0xFF595959),
                            fontSize: 14,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Edit number',
                          style: const TextStyle(
                            color: Color(0xFF2A9DA0),
                            fontSize: 14,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              navigateAddScreen(context, const LoginScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                  50.ph,
                  otpField(),
                  40.ph,
                  RichText(
                    text: TextSpan(
                      children: [
                        if (_countdown > 0) ...[
                          const TextSpan(
                            text: 'Resend code in ',
                            style: TextStyle(
                              color: Color(0xFF595959),
                              fontSize: 14,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: '00:$secondsStr',
                            style: const TextStyle(
                              color: Color(0xFF2A9DA0),
                              fontSize: 14,
                              fontFamily: poppinsSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          TextSpan(
                            text: 'Resend now',
                            style: const TextStyle(
                              color: Color(0xFF2A9DA0),
                              fontSize: 14,
                              fontFamily: poppinsSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                sendOTPPostApi().then((value) {
                                  printMsgTag("sendOtpValue", value);
                                  if (value != null) {
                                    if (value['message'] == "OTP sent successfully") {
                                      startTimer();
                                      ModelUtils.showSimpleAlertDialog(
                                        context,
                                        title: const Text("Happy bash"),
                                        content: "OTP Sent Successfully",
                                        okBtnFunction: () => Navigator.pop(context),
                                      );
                                    }
                                  }
                                });
                              },
                          ),
                        ],
                      ],
                    ),
                  ),
                  40.ph,
                  widget.navigateFrom == "login"
                      ? RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Login via',
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
                            // fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Email & password',
                          style: const TextStyle(
                            color: Color(0xFF2A9DA0),
                            fontSize: 14,
                            fontFamily: poppinsSemiBold,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              navigateAddScreen(
                                  context, const LoginScreen());
                            },
                        ),
                      ],
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   String secondsStr = _countdown < 10 ? '0$_countdown' : '$_countdown';
  //
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         Container(
  //           width: width,
  //           height: 220,
  //           decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment(0.00, -1.00),
  //               end: Alignment(0, 1),
  //               colors: [Color(0xFFEAF5F5), Color(0x00EAF5F5)],
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           right: 0,
  //           top: 77,
  //           child: Image.asset(ImageConstant.happy),
  //         ),
  //         SafeArea(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 10.ph,
  //                 const Text(
  //                   'Enter verification\ncode',
  //                   style: TextStyle(
  //                     color: Color(0xFF1D2939),
  //                     fontSize: 32,
  //                     fontFamily: serifRegular,
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                 ),
  //                 20.ph,
  //                 RichText(
  //                   text: TextSpan(
  //                     children: [
  //                       TextSpan(
  //                         text:
  //                             'Enter the 6-digit code we sent over SMS to (+965) ${widget.phoneNumber.substring(0, 4)}-${widget.phoneNumber.substring(4)}  ',
  //                         style: const TextStyle(
  //                           color: Color(0xFF595959),
  //                           fontSize: 14,
  //                           fontFamily: poppinsRegular,
  //                           fontWeight: FontWeight.w400,
  //                           height: 1.5,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: 'Edit number',
  //                         style: const TextStyle(
  //                           color: Color(0xFF2A9DA0),
  //                           fontSize: 14,
  //                           fontFamily: poppinsRegular,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                         recognizer: TapGestureRecognizer()
  //                           ..onTap = () {
  //                             navigateAddScreen(context, const LoginScreen());
  //                           },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 50.ph,
  //                 otpField(),
  //                 40.ph,
  //                 RichText(
  //                   text: TextSpan(
  //                     children: [
  //                       const TextSpan(
  //                         text: 'Resend code in ',
  //                         style: TextStyle(
  //                           color: Color(0xFF595959),
  //                           fontSize: 14,
  //                           fontFamily: poppinsRegular,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: '00:$secondsStr',
  //                         style: const TextStyle(
  //                           color: Color(0xFF2A9DA0),
  //                           fontSize: 14,
  //                           fontFamily: poppinsSemiBold,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 40.ph,
  //                 widget.navigateFrom == "login"
  //                     ? RichText(
  //                         text: TextSpan(
  //                           children: [
  //                             const TextSpan(
  //                               text: 'Login via',
  //                               style: TextStyle(
  //                                 color: Color(0xFF333333),
  //                                 fontSize: 14,
  //                                 fontFamily: poppinsMedium,
  //                                 fontWeight: FontWeight.w400,
  //                               ),
  //                             ),
  //                             const TextSpan(
  //                               text: ' ',
  //                               style: TextStyle(
  //                                 color: Color(0xFF333333),
  //                                 fontSize: 14,
  //                                 // fontFamily: 'Poppins',
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                             TextSpan(
  //                               text: 'Email & password',
  //                               style: const TextStyle(
  //                                 color: Color(0xFF2A9DA0),
  //                                 fontSize: 14,
  //                                 fontFamily: poppinsSemiBold,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                               recognizer: TapGestureRecognizer()
  //                                 ..onTap = () {
  //                                   navigateAddScreen(
  //                                       context, const LoginScreen());
  //                                 },
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     : Container(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget otpField() {
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(5),
        // border: Border.all(color: Colors.grey),
        border: Border(
          bottom: BorderSide(
            color: PrimaryColors().black900,
            // strokeAlign: StrokeAlign.outside,
            width: 3,
          ),
        ),
      ),
    );
    return Center(
      child: Form(
        key: formKey,
        child: Pinput(
          length: 6,
          controller: pinController,
          obscureText: true,
          obscuringCharacter: '*',
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          pinContentAlignment: Alignment.bottomCenter,
          onCompleted: (pin) {
            // if (pin == "9417") {
            //   setState(() {
            //     smsCode = widget.otp;
            //   });
            // } else {
            //   setState(() {
            //     smsCode = pin;
            //   });
            // }
            if (widget.navigateFrom == "signup") {
              verifyOTPPostApi(pin).then((value) {
                printMsgTag("value", value);
                if (value!['message'] == "OTP verified successfully") {
                  navigateAddScreen(
                    context,
                    CreateAccountScreen(
                      phoneNumber: widget.phoneNumber,
                    ),
                  );
                }
              });
            } else if (widget.navigateFrom == "login") {
              verifyOTPPostApi(pin).then((value) {
                printMsgTag("value", value);
                if (value!['message'] == "OTP verified successfully") {
                  loginPostApi().then((value) {
                    if (value != null) {
                      if (value['message'] == "Login successful.") {
                        setIsUserLogin(true);
                        setToken(value['token']);
                        showSnackBar(context, "Login Successfully...");

                        navigateReplaceAll(
                          context,
                          LocationScreen(
                            navigateFrom: 'login',
                          ),
                        );
                      }
                    }
                  });
                }
              });
            } else if (pin == "941760") {
              navigateReplaceAll(
                  context, BottomNavigationBarScreen(selectedIndex: 0));
            } else {
              navigateReplaceAll(
                  context, BottomNavigationBarScreen(selectedIndex: 0));
            }
            printMsgTag("smsCode", smsCode);
          },
          onChanged: (value) {
            // debugPrint('onChanged: $value');
          },
          mouseCursor: MouseCursor.uncontrolled,
          defaultPinTheme: defaultPinTheme.copyWith(
            margin: const EdgeInsets.all(8),
            decoration: defaultPinTheme.decoration!.copyWith(
              // color: focusedBorderColor,1
              // borderRadius: BorderRadius.circular(5),
              border: Border(
                bottom: BorderSide(
                  color: PrimaryColors().black900,
                  width: 3,
                ),
              ),
            ),
          ),
          focusedPinTheme: defaultPinTheme.copyWith(
            margin: const EdgeInsets.all(8),
            decoration: defaultPinTheme.decoration!.copyWith(
              // color: focusedBorderColor,
              // borderRadius: BorderRadius.circular(5),
              // border: Border.all(color: PrimaryColors().primarycolor),
              border: Border(
                bottom: BorderSide(
                  color: PrimaryColors().black900,
                  width: 3,
                ),
              ),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            margin: const EdgeInsets.all(8),
            decoration: defaultPinTheme.decoration!.copyWith(
              color: fillColor,
              // borderRadius: BorderRadius.circular(5),
              // border: Border.all(color: PrimaryColors().primarycolor),
              border: const Border(
                bottom: BorderSide(
                  color: Colors.green,
                  width: 3,
                ),
              ),
            ),
          ),
          errorPinTheme: defaultPinTheme.copyWith(
            margin: const EdgeInsets.all(8),
            decoration: defaultPinTheme.decoration!.copyWith(
              // borderRadius: BorderRadius.circular(5),
              // border: Border.all(color: Colors.redAccent),
              border: const Border(
                bottom: BorderSide(
                  color: Colors.red,
                  width: 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
