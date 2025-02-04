import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/get_location_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key, required this.navigateFrom}) : super(key: key);
  String navigateFrom = "";

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String searchValue = "";
  List<GetLocationModel> getLocationList = [];
//......Location get api function definition......//
  Future<List<GetLocationModel>> locationsGetApi() async {
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.locations}"),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    getLocationList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("categoriesGetApi ResponseData", responseData);
        for (Map i in responseData) {
          getLocationList.add(GetLocationModel.fromJson(i));
        }
        // return CategoriesModel.fromJson(responseData);
        return getLocationList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("categoriesGetApi catch", exception.toString());
    }

    return getLocationList;
  }
  //...... update Location api function definition ......//
  Future<Map<String, dynamic>> updateLocationApi(String locationId) async {
    var responseData;
    String token = await getToken();

    final jsonResponse = await http.put(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.updateLocations}"),
      headers: {
        // "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {"location_id": locationId},
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("updateLocationApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("updateLocationApi catch", exception.toString());
    }
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select event location',
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 20,
                    fontFamily: serifRegular,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                24.ph,
                TextFormField(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    hintText: 'Search location',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF2A9DA0)),
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Image.asset(
                      "assets/icons/Search.png",
                      color: searchValue.isNotEmpty
                          ? PrimaryColors().black900
                          : null,
                    ),
                    suffixIcon: searchValue.isNotEmpty
                        ? Image.asset("assets/icons/cancel.png")
                        : const SizedBox(width: 0, height: 0),
                  ),
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                  // validator: (cpassword) {},
                ),
                24.ph,
                FutureBuilder(
                  future: locationsGetApi(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: getLocationList.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(thickness: 1);
                        },
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              updateLocationApi(
                                      getLocationList[index].id.toString())
                                  .then((value) {
                                setLocation(getLocationList[index].name);
                                if (widget.navigateFrom == "createAccount") {
                                  showSnackBar(
                                      context, "Register Successfully...");
                                } else if (widget.navigateFrom == "login") {
                                  showSnackBar(
                                      context, "Login Successfully...");
                                }
                                navigateReplaceAll(
                                    context,
                                    BottomNavigationBarScreen(
                                        selectedIndex: 0));
                              });
                            },
                            dense: true,
                            horizontalTitleGap: 0,
                            leading: Image.asset("assets/icons/location.png"),
                            title: Text(
                              getLocationList[index].name.toString(),
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: poppinsRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const CustomProgressBar();
                  },
                ),
                // locationWidget(
                //   locationName: 'ASIMA',
                //   areaName: [
                //     'Abdullah Al Salem',
                //     "Adailiya",
                //     "AlNahda",
                //     "AlRai",
                //     "Bnaid Al Qar",
                //   ],
                // ),
                // 24.ph,
                // locationWidget(
                //   locationName: 'CAMPS'.toUpperCase(),
                //   areaName: ["South Camps"],
                // ),
                // 24.ph,
                // locationWidget(
                //   locationName: 'Hawalli'.toUpperCase(),
                //   areaName: ["Al Bedae"],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget locationWidget(
      {required String locationName, required List areaName}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locationName,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        16.ph,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: areaName.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(thickness: 1);
          },
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                // updateLocationApi().then((value) => null);
                setLocation(areaName[index]);
                showSnackBar(context, "Register Successfully...");
                navigateReplaceAll(
                    context, BottomNavigationBarScreen(selectedIndex: 0));
              },
              dense: true,
              horizontalTitleGap: 0,
              leading: Image.asset("assets/icons/location.png"),
              title: Text(
                areaName[index],
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: poppinsRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
