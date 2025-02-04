import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/get_waitlist_model.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/static_words.dart';
import '../../../network/base_url.dart';
import '../../../theme/theme_helper.dart';

class WaitListPage extends StatefulWidget {
  const WaitListPage({Key? key}) : super(key: key);

  @override
  State<WaitListPage> createState() => _WaitListPageState();
}

class _WaitListPageState extends State<WaitListPage> {
  late SharedPreferences prefs;
  List<GetWaitlistModel?> waitlistList = [];

  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<List<GetWaitlistModel?>> getWaitlistApi() async {
    String token = await getToken();
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.waitlist}"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    waitlistList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("getWaitlistApi ResponseData", responseData);
        for (Map i in responseData) {
          waitlistList.add(GetWaitlistModel.fromJson(i));
        }

        return waitlistList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getWaitlistApi catch", exception.toString());
    }

    return waitlistList;
  }

  Future<Map<String, dynamic>> waitlistDeleteApi(int productId) async {
    var responseData;
    String token = await getToken();

    //loading circular bar
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CustomProgressBar());
      },
    );

    final jsonResponse = await http.delete(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.deleteWaitlist}/$productId"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // After loading navigate to nextScreen...
    Navigator.of(context).pop();

    try {
      if (jsonResponse.statusCode == 200 || jsonResponse.statusCode == 201) {
        printMsgTag("waitlistDeleteApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("waitlistDeleteApi catch", exception.toString());
    }
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 1.0,
        titleSpacing: 0,
        leading: const SizedBox(),
        // leading: GestureDetector(
        //   onTap: () => Navigator.pop(context),
        //   child: Icon(
        //     Icons.arrow_back_ios_new,
        //     color: PrimaryColors().black900,
        //     size: 20,
        //   ),
        // ),
        title: const Text(
          'My waitlist',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: getSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            prefs = snapshot.data!;
            if (getIsUserLogin(prefs) == true) {
              return FutureBuilder(
                future: getWaitlistApi(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (waitlistList.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: waitlistList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              minVerticalPadding: 15,
                              leading: Container(
                                width: 64,
                                height: 84,
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        // wishlist[index]["image"],
                                        waitlistList[index]!
                                            .product!
                                            .images![0]
                                            .imageUrl
                                            .toString()),
                                    fit: BoxFit.fill,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // 'Curved sofa',
                                    waitlistList[index]!
                                        .product!
                                        .name
                                        .toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 16,
                                      fontFamily: serifRegular,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  3.ph,
                                  Row(
                                    children: [
                                      const Text(
                                        'KD 120.00',
                                        style: TextStyle(
                                          color: Color(0xFF9B9B9B),
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      10.pw,
                                      Text(
                                        'KD ${waitlistList[index]!.product!.pricePerDay.toString()}',
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 16,
                                          fontFamily: poppinsBold,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      2.pw,
                                      const Text(
                                        'per day',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 14,
                                          fontFamily: poppinsRegular,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              subtitle: GestureDetector(
                                onTap: () {
                                  ModelUtils.showCustomAlertDialog(
                                    context,
                                    title: "Wishlist Remove",
                                    content: const Text(
                                        "Are you sure want to remove from wishlist"),
                                    okBtnFunction: () {
                                      waitlistDeleteApi(
                                              waitlistList[index]!.product!.id!)
                                          .then((value) {
                                        if (value['message'] ==
                                            "Product removed from wishlist") {
                                          showSnackBar(
                                              context, value['message']);
                                          navigateReplaceAll(
                                            context,
                                            BottomNavigationBarScreen(
                                                selectedIndex: 1),
                                          );
                                        }
                                      });
                                    },
                                  );
                                },
                                child: const Text(
                                  "Remove",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontFamily: poppinsRegular),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(thickness: 1);
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No waitlist found...",
                          style: TextStyle(fontFamily: poppinsMedium),
                        ),
                      );
                    }
                  }
                  return const CustomProgressBar();
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        navigateAddScreen(context, const LoginScreen());
                      },
                      height: 45,
                      color: PrimaryColors().primarycolor,
                      child: Text(
                        "Login to see wait list".toUpperCase(),
                        style: TextStyle(
                          color: PrimaryColors().white,
                          fontFamily: poppinsSemiBold,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          }
          return const CustomProgressBar();
        },
      ),
    );
  }
}
