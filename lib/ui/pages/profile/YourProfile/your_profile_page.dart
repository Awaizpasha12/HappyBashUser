import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/profile_model.dart';
import 'package:pinput/pinput.dart';

import 'package:http/http.dart' as http;

import '../../../../core/constants/dialog_box.dart';
import '../../../../core/constants/shared_preferences_utils.dart';
import '../../../../core/constants/static_words.dart';
import '../../../../network/base_url.dart';
import '../../../../theme/theme_helper.dart';

class YourProfilePage extends StatefulWidget {
  const YourProfilePage({super.key});

  @override
  State<YourProfilePage> createState() => _YourProfilePageState();
}

class _YourProfilePageState extends State<YourProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  String smsCode = "";
  final int _countdown = 60;
  String oldPassword = "";
  String password = "";
  String conformPass = "";
  String newMobileNo = "";
  String countryCode = "+965";

  Future<ProfileModel> getProfileApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();

    //loading circular bar
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CustomProgressBar());
      },
    );

    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.profile}"),
      headers: {
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());

    // After loading navigate to nextScreen...
    Navigator.of(context).pop();

    try {
      if (response.statusCode == 200) {
        printMsgTag("getCartApi ResponseData", responseData);
        return ProfileModel.fromJson(responseData);
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getCartApi catch", exception.toString());
    }

    return ProfileModel.fromJson(responseData);
  }

  Future<Map<String, dynamic>?> updateMobileNoOTPPostApi() async {
    var responseData;
    String token = await getToken();

    String reqParam = jsonEncode({
      "country_code": countryCode,
      "new_mobile": newMobileNo,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.updatemobileNo}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
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

  Future<Map<String, dynamic>?> verifyOTPPostApi(String pin) async {
    var responseData;
    String token = await getToken();
    String countryCode = "+965";

    // if (newMobileNo.length > 8) {
    //   countryCode = "+91";
    // }
    String reqParam = jsonEncode({
      "otp": pin,
      "phone": "$countryCode$newMobileNo",
    });

    printMsgTag("reqParam:=", reqParam.toString());

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/user/${BaseUrl.verifyOtp}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
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

  Future<Map<String, dynamic>?> updateProfilePatchApi(
      {required String name, required String password}) async {
    var responseData;
    String token = await getToken();

    String reqParam = jsonEncode({
      "name": name,
      "password": password,
    });

    printMsgTag("reqParam:=", reqParam.toString());
    // print("reqParam:=" + reqParam.toString());

    final jsonResponse = await http.patch(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.profile}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      // headers: {"content-type": "application/json"},
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag(
            "updateProfilePatchApi response", jsonResponse.body.toString());
        // print("register response${jsonResponse.body}");
        // setIsRegistered(true);
        responseData = jsonDecode(jsonResponse.body);
        return responseData;
      } else {
        // showSnackBar(context, jsonResponse["Message"]);
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("updateProfilePatchApis catch", exception.toString());
    }
    return responseData;
  }

  @override
  void initState() {
    super.initState();
    getProfileApi().then((value) {
      _name.text = value.name.toString();
      String mobilenum = value.phone.toString();
      mobilenum = mobilenum.replaceAll(" ", "");
      String num = mobilenum.substring(mobilenum.length - 8);
      printMsgTag("Num", num);
      _phoneNumber.text = num;
      _email.text = value.email.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    String secondsStr = _countdown < 10 ? '0$_countdown' : '$_countdown';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 0.0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: PrimaryColors().black900,
            size: 20,
          ),
        ),
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width,
                  height: 100,
                  color: const Color(0xFFEAF5F5),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    "assets/images/Isolation_Mode.svg",
                  ),
                ),
                // const Positioned(
                //   left: 20,
                //   bottom: -65,
                //   child: CircleAvatar(
                //     radius: 47,
                //     backgroundColor: Colors.white,
                //     child: CircleAvatar(
                //       radius: 36,
                //       backgroundColor: Color(0xFF2A9DA0),
                //       child: Center(
                //         child: Text(
                //           'HM',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 20,
                //             fontFamily: serifRegular,
                //             fontWeight: FontWeight.w400,
                //             letterSpacing: 1,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
            100.ph,
            Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        // isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 14,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDEDED)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDEDED)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDEDED)),
                        ),
                      ),
                      cursorColor: Colors.black,
                      validator: (name) {
                        if (name == null || name.isEmpty) {
                          return "Please enter name";
                        }
                        return null;
                      },
                      // onSaved: (value) {
                      //   allergies = value!;
                      //   printMsgTag("allergies", allergies);
                      // },
                    ),
                    20.ph,
                    TextFormField(
                      readOnly: true,
                      controller: _phoneNumber,
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
                          child: const Text(
                            "+965",
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                        suffixIcon: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              changeMobileNumber(context, secondsStr);
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Color(0xFF2A9DA0),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(),
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
                        FilteringTextInputFormatter.allow(RegExp('[٠-٩0-9]')),
                        // FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (mobileNo) {
                        if (mobileNo == null || mobileNo.isEmpty) {
                          return "Enter mobile number";
                        }
                        if (mobileNo.length != 8) {
                          return "Mobile number should be alteast 8 digits only";
                        }
                        return null;
                      },
                      // onSaved: (value) {
                      //   allergies = value!;
                      //   printMsgTag("allergies", allergies);
                      // },
                    ),
                    20.ph,
                    TextFormField(
                      readOnly: true,
                      controller: _email,
                      decoration: InputDecoration(
                        // isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 14,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    child: Container(
                                      width: width,
                                      height: 226,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 16),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Change email address',
                                                  style: TextStyle(
                                                    color: Color(0xFF333333),
                                                    fontSize: 24,
                                                    fontFamily: serifRegular,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: SvgPicture.asset(
                                                    ImageConstant.cancel,
                                                    color: PrimaryColors()
                                                        .black900,
                                                  ),
                                                )
                                              ],
                                            ),
                                            13.ph,
                                            Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  // isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                  labelText: 'Email',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF9B9B9B),
                                                    fontSize: 14,
                                                    fontFamily: poppinsRegular,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFEDEDED)),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFEDEDED)),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFEDEDED)),
                                                  ),
                                                ),
                                                cursorColor: Colors.black,
                                                validator: (email) {
                                                  if (email == null ||
                                                      email.isEmpty) {
                                                    return "Please enter email";
                                                  } else if (!EmailValidator
                                                      .validate(email)) {
                                                    return "Enter valid email id";
                                                  }
                                                  return null;
                                                },
                                                // onSaved: (value) {
                                                //   allergies = value!;
                                                //   printMsgTag("allergies", allergies);
                                                // },
                                              ),
                                            ),
                                            20.ph,
                                            MaterialButton(
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  Navigator.pop(context);
                                                  showModalBottomSheet(
                                                    context: context,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    builder: (context) {
                                                      return okayModel(
                                                          "Email address changed successfully!");
                                                    },
                                                  );
                                                }
                                              },
                                              minWidth: width,
                                              height: 40,
                                              color:
                                                  PrimaryColors().primarycolor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          36)),
                                              child: Text(
                                                'Update Email'.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: poppinsSemiBold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Color(0xFF2A9DA0),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(),
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
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return "Please enter email";
                        } else if (!EmailValidator.validate(email)) {
                          return "Enter valid email id";
                        }
                        return null;
                      },
                      // onSaved: (value) {
                      //   allergies = value!;
                      //   printMsgTag("allergies", allergies);
                      // },
                    ),
                    20.ph,
                    TextFormField(
                      readOnly: true,
                      // controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        // isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 14,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              changePassword(context);
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Color(0xFF2A9DA0),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(),
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
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return "Please enter password";
                        } else if (password.length < 8) {
                          return "Password must be alteast 8 characters long";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // password = value!;
                        // printMsgTag("Password", password);
                      },
                    ),
                    20.ph,
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> changePassword(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: width,
            height: 425,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change password',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontFamily: serifRegular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset(
                          ImageConstant.cancel,
                          color: PrimaryColors().black900,
                        ),
                      )
                    ],
                  ),
                  13.ph,
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            labelText: 'Old Password',
                            labelStyle: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                          ),
                          cursorColor: Colors.black,
                          // validator: (password) {
                          //   if (password == null || password.isEmpty) {
                          //     return "Please enter old password";
                          //   } else if (password.length < 8) {
                          //     return "Password must be alteast 8 characters long";
                          //   }
                          //   return null;
                          // },
                          // onEditingComplete: () {
                          //   if (getPassword() == oldPassword) {
                          //     printMsgTag("getpassword", true);
                          //   }
                          // },
                          onFieldSubmitted: (value) {
                            printMsgTag("old password valie", value);
                          },
                          onChanged: (value) =>
                              printMsgTag("old password onchange value", value),
                          onSaved: (value) {
                            oldPassword = value!;
                            printMsgTag("Password", oldPassword);
                          },
                        ),
                        15.ph,
                        TextFormField(
                          controller: _pass,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            labelText: 'New Password',
                            labelStyle: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                          ),
                          cursorColor: Colors.black,
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return "Please enter new password";
                            } else if (password.length < 8) {
                              return "Password must be alteast 8 characters long";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            password = value!;
                            printMsgTag("Password", password);
                          },
                        ),
                        15.ph,
                        TextFormField(
                          controller: _confirmPass,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            labelText: 'Confirm password',
                            labelStyle: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEDEDED)),
                            ),
                          ),
                          cursorColor: Colors.black,
                          validator: (cpassword) {
                            if (cpassword == null || cpassword.isEmpty) {
                              return "Please enter confirm password";
                            }
                            if (cpassword != _pass.text) {
                              return "confirm password does't match with password";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            conformPass = value!;
                            printMsgTag("cPassowrd", value);
                          },
                        ),
                      ],
                    ),
                  ),
                  20.ph,
                  MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        var existingPassword = await getPassword();
                        if (oldPassword == existingPassword) {
                          updateProfilePatchApi(
                                  name: _name.text, password: password)
                              .then(
                            (value) {
                              if (value!['message'] ==
                                  "Profile updated successfully") {
                                setPassword(password);
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return okayModel(
                                        "Password changed successfully!");
                                  },
                                );
                              }
                            },
                          );
                        } else {
                          ModelUtils.showSimpleAlertDialog(
                            context,
                            title: const Text("Password not match"),
                            content: "Your old password does not match",
                            okBtnFunction: () => Navigator.pop(context),
                          );
                        }
                      }
                    },
                    minWidth: width,
                    height: 40,
                    color: PrimaryColors().primarycolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36)),
                    child: Text(
                      'save changes'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> changeMobileNumber(BuildContext context, String secondsStr) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                width: width,
                height: 255,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Change mobile number',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 24,
                              fontFamily: serifRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              ImageConstant.cancel,
                              color: PrimaryColors().black900,
                            ),
                          )
                        ],
                      ),
                      13.ph,
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      //   if (countryCode == "+965") {
                                      //     countryCode = "+91";
                                      //   } else {
                                      //     countryCode == "+965";
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
                                  borderSide:
                                      BorderSide(color: Color(0xFFEDEDED)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFEDEDED)),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFEDEDED)),
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
                                // if (countryCode == "+965") {
                                  if (mobileNo.length != 8) {
                                    return "Mobile number should be alteast 8 digits only";
                                  }
                                // }
                                return null;
                              },
                              onSaved: (value) {
                                newMobileNo = value!;
                                printMsgTag("newMobileNo", newMobileNo);
                              },
                            ),
                            10.ph,
                            const Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "We will send a message with a verification code.",
                                    style: TextStyle(
                                      color: Color(0xFF595959),
                                      fontSize: 12,
                                      fontFamily: poppinsRegular,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      20.ph,
                      MaterialButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            updateMobileNoOTPPostApi().then((value) {
                              if (value!["message"] ==
                                  "OTP sent successfully") {
                                Navigator.pop(context);
                                // startTimer();
                                pinController.clear();
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Container(
                                            width: width,
                                            height: 280,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Enter verification code',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF333333),
                                                          fontSize: 24,
                                                          fontFamily:
                                                              serifRegular,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: SvgPicture.asset(
                                                          ImageConstant.cancel,
                                                          color: PrimaryColors()
                                                              .black900,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  13.ph,
                                                  RichText(
                                                    text: const TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Enter the 6-digit code we sent over SMS to (+965) 2607-9484 ',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF595959),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                poppinsMedium,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'Edit number',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF2A9DA0),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                poppinsSemiBold,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  otpField(),
                                                  40.ph,
                                                  Row(
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text:
                                                                  'Resend code in ',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF595959),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    poppinsRegular,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '00:$secondsStr',
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF2A9DA0),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    poppinsSemiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

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
        key: _otpFormKey,
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
            verifyOTPPostApi(pin).then((value) {
              if (value!["message"] == "Mobile number updated successfully") {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return okayModel('Mobile number changed successfully!');
                  },
                );
              }
            });
            // if (pin == "9417") {
            //   setState(() {
            //     smsCode = widget.otp;
            //   });
            // } else {
            //   setState(() {
            //     smsCode = pin;
            //   });
            // }

            // navigateReplaceAll(context, const CreateAccountScreen());
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

  Widget okayModel(String text) {
    return Container(
      width: width,
      height: 265,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/success.svg"),
              ],
            ),
            20.ph,
            Text(
              // 'Mobile number changed successfully!',
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 24,
                fontFamily: serifRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
            20.ph,
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              minWidth: width,
              height: 40,
              color: PrimaryColors().primarycolor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36)),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: poppinsSemiBold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
