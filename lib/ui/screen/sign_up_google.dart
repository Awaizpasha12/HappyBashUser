import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:happy_bash/core/reusable.dart';

import '../../core/constants/dialog_box.dart';
import '../../core/constants/image_constants.dart';
import '../../core/constants/navigator.dart';
import '../../core/constants/static_words.dart';
import '../../core/utils/size_utils.dart';
import '../../network/base_url.dart';
import 'package:http/http.dart' as http;
import '../../theme/theme_helper.dart';
import 'google_otp_verify_screen.dart';
import 'login_screen.dart';
import 'otp_verify_page.dart';

class SignUpGoogle extends StatefulWidget {
   const SignUpGoogle({super.key, this.useremail, this.userId,});
  final String? useremail;
  final String? userId;
  @override
  State<SignUpGoogle> createState() => _SignUpGoogleState();
}

class _SignUpGoogleState extends State<SignUpGoogle> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  String mobileNo = "";
  String countryCode = "+965";
  // String? email;
  // String? phone;
  // String? userId;

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your phone number',
                    style: TextStyle(
                      color: Color(0xFF1D2939),
                      fontSize: 32,
                      fontFamily: serifRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  30.ph,
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            // isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            hintText: 'Phone number',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                            prefixIconConstraints: const BoxConstraints(),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
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
                            if (mobileNo == null || mobileNo.isEmpty) {
                              return "Enter mobile number";
                            }
                            if (countryCode == "+965" && mobileNo.length != 8) {
                              return "Mobile number should be alteast 8 digits only";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            mobileNo = value!;
                            printMsgTag("mobileNo", mobileNo);
                          },
                        ),
                        20.ph,
                        const Text(
                          "We will send a message with a verification code. By continuing, you agree to our Terms of Service & Privacy Policy.",
                          style: TextStyle(
                            color: Color(0xFF595959),
                            fontSize: 12,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        )
                      ],
                    ),
                  ),
                  30.ph,
                  MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        sendOTPPostApi().then((value) {
                          if (value!['message'] ==
                              "OTP sent successfully") {
                            navigateAddScreen(
                              context,
                              GoogleOtpVerifyScreen(
                                googleUserid: widget.userId,
                                userPhone: mobileNo,
                                userEmail : widget.useremail,
                                  navigateFrom: "login",
                                  phoneNumber:
                                  "$countryCode$mobileNo",
                                  countryCode: countryCode,
                                ),
                            );
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

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  // ......... Sign Up with OTP Verification........//
  Future<Map<String, dynamic>?> sendOTPPostApi() async {
    var responseData;
    // print("countryCode: $countryCode");
    // print("countryCode: $mobileNo");

    Map<String, String> reqParam = {
      'phone': mobileNo,
      'country_code': countryCode,
    };
    String reqParamStr = jsonEncode(reqParam);

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());
    //print("url : ${BaseUrl.globalUrl}/${BaseUrl.sendOtp}");
    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.sendOtp}"),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: reqParamStr,
    );
    // print(jsonResponse.body);
    // print(jsonResponse.statusCode);
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("sendOTPPostApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      //print(jsonResponse.body);
      // showSnackBar(context, jsonDecode(jsonResponse.body)['message']);
      ModelUtils.showSimpleAlertDialog(
        context,
        title: const Text('Invalid credentials'),
        content: jsonDecode(jsonResponse.body)['error'] ?? " ",
        okBtnFunction: () => Navigator.pop(context),
      );
      printMsgTag("sendOTPPostApi catch", exception.toString());
    }

    return responseData;
  }

}

