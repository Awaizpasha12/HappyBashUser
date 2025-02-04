import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/add_address_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateAddressPage extends StatefulWidget {
  UpdateAddressPage({
    super.key,
    required this.addressId,
    required this.addressLine1,
    required this.block,
    required this.street,
    required this.additionalDir,
  });
  int addressId;
  String addressLine1;
  String block;
  String street;
  String additionalDir;

  @override
  State<UpdateAddressPage> createState() => _UpdateAddressPageState();
}

class _UpdateAddressPageState extends State<UpdateAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  TextEditingController addressLine1Tc = TextEditingController();
  TextEditingController blockTc = TextEditingController();
  TextEditingController streetTc = TextEditingController();
  TextEditingController additionalDirTc = TextEditingController();
  String addressLine1 = "";
  String addressLine2 = "";
  String block = "";
  String street = "";
  String additionalDir = "";

  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<AddAddressModel> updateAddressPutApi() async {
    String token = await getToken();

    String reqParm = jsonEncode({
      "street": street,
      "city": block,
      "state": addressLine1,
      "postal_code": "200001"
    });

    final response = await http.put(
      Uri.parse(
          "${BaseUrl.globalUrl}/${BaseUrl.addresses}/${widget.addressId}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: reqParm,
    );

    var responseData = jsonDecode(response.body.toString());

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        printMsgTag("updateAddressPutApi ResponseData", responseData);

        return AddAddressModel.fromJson(responseData);
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("updateAddressPutApi catch", exception.toString());
    }

    return AddAddressModel.fromJson(responseData);
  }

  @override
  void initState() {
    super.initState();
    addressLine1Tc.text = widget.addressLine1;
    blockTc.text = widget.block;
    streetTc.text = widget.street;
    additionalDirTc.text = widget.additionalDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Address",
          style: TextStyle(
            fontFamily: poppinsRegular,
            fontSize: 16,
          ),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: getSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            prefs = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      10.ph,
                      Container(
                        width: width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        color: const Color(0xFFFCF4EA),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/HappyBash/location-1.svg"),
                            8.pw,
                            Text(
                              // 'Abdullah Al Salem',
                              getLocation(prefs),
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                      20.ph,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFE38E31),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                8.pw,
                                const Text(
                                  'Address details',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                    fontFamily: serifRegular,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            20.ph,
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: addressLine1Tc,
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Address line 1',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    validator: (address) {
                                      if (address == null || address.isEmpty) {
                                        return "Please enter address";
                                      }

                                      return null;
                                    },
                                    onSaved: (value) {
                                      addressLine1 = value!;
                                      printMsgTag("addressLine1", addressLine1);
                                    },
                                  ),
                                  10.ph,
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Address line 2',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    // validator: (address) {
                                    //   if (address == null || address.isEmpty) {
                                    //     return "Please enter address";
                                    //   }

                                    //   return null;
                                    // },
                                    onSaved: (value) {
                                      addressLine2 = value!;
                                      printMsgTag("addressLine2", addressLine2);
                                    },
                                  ),
                                  10.ph,
                                  TextFormField(
                                    controller: blockTc,
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Block',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    validator: (block) {
                                      if (block == null || block.isEmpty) {
                                        return "Please enter block";
                                      }

                                      return null;
                                    },
                                    onSaved: (value) {
                                      block = value!;
                                      printMsgTag("block", block);
                                    },
                                  ),
                                  10.ph,
                                  TextFormField(
                                    controller: streetTc,
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Street',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    validator: (street) {
                                      if (street == null || street.isEmpty) {
                                        return "Please enter street";
                                      }

                                      return null;
                                    },
                                    onSaved: (value) {
                                      street = value!;
                                      printMsgTag("street", street);
                                    },
                                  ),
                                  10.ph,
                                  TextFormField(
                                    controller: additionalDirTc,
                                    decoration: const InputDecoration(
                                      // isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      labelText: 'Additional directions',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontSize: 14,
                                        fontFamily: poppinsRegular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFDED5D5)),
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                    // validator: (addDir) {
                                    //   if (addDir == null || addDir.isEmpty) {
                                    //     return "Please enter addtional direction";
                                    //   }
                                    //   return null;
                                    // },
                                    onSaved: (value) {
                                      additionalDir = value!;
                                      printMsgTag(
                                          "additionalDir", additionalDir);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            20.ph,
                          ],
                        ),
                      ),
                      32.ph,
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: width,
                    height: 60,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(1, 2),
                          blurRadius: 29.0,
                          spreadRadius: 1.9,
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          updateAddressPutApi().then((value) {
                            Navigator.pop(context);
                          });
                        }
                      },
                      color: const Color(0xFF2A9DA0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36)),
                      child: Text(
                        'Update Address'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: poppinsSemiBold,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
          return const CustomProgressBar();
        },
      ),
    );
  }
}
