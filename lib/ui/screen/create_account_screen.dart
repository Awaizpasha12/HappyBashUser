import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';

import 'package:http/http.dart' as http;

import 'package:email_validator/email_validator.dart';
import 'package:happy_bash/ui/screen/location_screen.dart';

import '../../network/base_url.dart';
import '../../theme/theme_helper.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key, required this.phoneNumber})
      : super(key: key);
  final String phoneNumber;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  var obscureTextPass = true;
  var obscureTextCpass = true;
  String password = "";
  String conformPass = "";
  String email = "";
  String fullName = "";

  //......SignUp Page Api Post User Data.......//
  Future<Map<String, dynamic>> registerPostApi() async {
    var responseData;

    String reqParm = jsonEncode({
      "name": fullName,
      "email": email,
      "password": password,
      "phone": widget.phoneNumber,
    });

    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.register}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
      },
      body: reqParm,
    );

    try {
      if (response.statusCode == 200) {
        responseData = jsonDecode(response.body.toString());
        printMsgTag("registerPostApi ResponseData", responseData);
        return responseData;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        responseData = jsonDecode(response.body.toString());
        showSnackBar(context, responseData['message']);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("registerPostApi catch", exception.toString());
    }

    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Create \nyour account',
                        style: TextStyle(
                          color: Color(0xFF1D2939),
                          fontSize: 32,
                          fontFamily: serifRegular,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                20.ph,
                const Text(
                  'Get offers and a lot of products that can make your events a most memorable one',
                  style: TextStyle(
                    color: Color(0xFF595959),
                    fontSize: 14,
                    fontFamily: poppinsRegular,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                30.ph,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          // isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          labelText: 'Full name',
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
                        validator: (fullName) {
                          if (fullName == null || fullName.isEmpty) {
                            return "Please enter full name";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          fullName = value!;
                          printMsgTag("email", fullName);
                        },
                      ),
                      20.ph,
                      TextFormField(
                        decoration: const InputDecoration(
                          // isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          labelText: 'Email',
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
                        validator: (email) {
                          if (email == null || email.isEmpty) {
                            return "Please enter email";
                          } else if (!EmailValidator.validate(email)) {
                            return "Enter valid email id";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                          printMsgTag("email", email);
                        },
                      ),
                      20.ph,
                      TextFormField(
                        controller: _pass,
                        obscureText: obscureTextPass,
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
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
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
                                    color: PrimaryColors().primarycolor,
                                    size: 20,
                                  ),
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
                          password = value!;
                          printMsgTag("Password", password);
                        },
                      ),
                      20.ph,
                      TextFormField(
                        controller: _confirmPass,
                        obscureText: obscureTextCpass,
                        decoration: InputDecoration(
                          // isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          labelText: 'Confirm password',
                          labelStyle: const TextStyle(
                            color: Color(0xFF9B9B9B),
                            fontSize: 14,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscureTextCpass = !obscureTextCpass;
                              });
                            },
                            child: obscureTextCpass == true
                                ? const Icon(
                                    Icons.visibility_off,
                                    color: Colors.grey,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.visibility,
                                    color: PrimaryColors().primarycolor,
                                    size: 20,
                                  ),
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
                26.ph,
                MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      registerPostApi().then((value) {
                        if (value["message"] == "Registration successful.") {
                          String token = value["token"];
                          setToken(token);
                          setIsUserLogin(true);
                          setPassword(password);
                          navigateReplaceAll(
                              context,
                              LocationScreen(
                                navigateFrom: 'createAccount',
                              ));
                        }
                      });
                    }
                  },
                  minWidth: double.infinity,
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
        ),
      ),
    );
  }
}
