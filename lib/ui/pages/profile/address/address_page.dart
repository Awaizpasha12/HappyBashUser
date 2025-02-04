import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/get_address_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/profile/address/add_address_page.dart';
import 'package:happy_bash/ui/pages/profile/address/update_address_page.dart';
import 'package:http/http.dart' as http;

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<GetAddressModel> getAddressList = [];

  Future<List<GetAddressModel>> addressGetApi() async {
    String token = await getToken();
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.addresses}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    getAddressList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("addressGetApi ResponseData", responseData);
        for (Map i in responseData) {
          getAddressList.add(GetAddressModel.fromJson(i));
        }
        return getAddressList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("addressGetApi catch", exception.toString());
    }

    return getAddressList;
  }

  Future<Map<String, dynamic>> deleteAddressApi(int addressId) async {
    var responseData;
    String token = await getToken();

    final jsonResponse = await http.delete(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.addresses}/$addressId"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("deleteCartApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("deleteCartApi catch", exception.toString());
    }
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Address",
          style: TextStyle(
            fontFamily: poppinsRegular,
            fontSize: 16,
          ),
        ),
        // actions: [
        //   MaterialButton(
        //     onPressed: () {},
        //     // height: 40,
        //     // color: PrimaryColors().primarycolor,
        //     padding: const EdgeInsets.symmetric(horizontal: 1),
        //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //       side: BorderSide(color: PrimaryColors().primarycolor),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(
        //           Icons.add_circle_rounded,
        //           color: PrimaryColors().primarycolor,
        //         ),
        //         3.pw,
        //         Text(
        //           "Add",
        //           style: TextStyle(
        //             fontFamily: poppinsMedium,
        //             color: PrimaryColors().primarycolor,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        //   5.pw,
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: MaterialButton(
                  onPressed: () {
                    // navigateAddScreen(context, const AddAddressPage());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressPage(),
                        )).then((value) {
                      setState(() {});
                    });
                  },
                  height: 40,
                  color: PrimaryColors().primarycolor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_rounded,
                        color: PrimaryColors().white,
                      ),
                      3.pw,
                      Text(
                        "Add address",
                        style: TextStyle(
                          fontFamily: poppinsMedium,
                          color: PrimaryColors().white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.ph,
              FutureBuilder(
                future: addressGetApi(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: getAddressList.length,
                      // separatorBuilder: (BuildContext context, int index) {
                      //   return const Divider();
                      // },
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateAddressPage(
                                                addressLine1:
                                                    getAddressList[index]
                                                        .state
                                                        .toString(),
                                                block: getAddressList[index]
                                                    .city
                                                    .toString(),
                                                street: getAddressList[index]
                                                    .street
                                                    .toString(),
                                                additionalDir: '',
                                                addressId:
                                                    getAddressList[index].id!,
                                              ),
                                            )).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        ImageConstant.edit,
                                        color: PrimaryColors().primarycolor,
                                      ),
                                    ),
                                    5.pw,
                                    GestureDetector(
                                      onTap: () {
                                        showModal(
                                          context: context,
                                          configuration:
                                              const FadeScaleTransitionConfiguration(
                                            transitionDuration:
                                                Duration(milliseconds: 500),
                                            reverseTransitionDuration:
                                                Duration(milliseconds: 300),
                                          ),
                                          builder: (_) {
                                            return AlertDialog(
                                              // actionsAlignment: MainAxisAlignment.center,
                                              title:
                                                  const Text("Delete Address"),
                                              // titlePadding: EdgeInsets.zero,
                                              content: const Text(
                                                  "Are you sure want to delete address?"),
                                              actions: <Widget>[
                                                MaterialButton(
                                                  color: PrimaryColors()
                                                      .primarycolor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  onPressed: () {
                                                    deleteAddressApi(
                                                            getAddressList[
                                                                    index]
                                                                .id!)
                                                        .then((value) {
                                                      Navigator.pop(context);
                                                      showSnackBar(context,
                                                          value["message"]);
                                                    });
                                                  },
                                                  child: const Text(
                                                    "Okay",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                MaterialButton(
                                                  color: PrimaryColors().white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: PrimaryColors().primarycolor,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  "Street: ${getAddressList[index].street}",
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                                8.ph,
                                Text(
                                  "State: ${getAddressList[index].state}",
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                                8.ph,
                                Text(
                                  "City: ${getAddressList[index].city}",
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                                8.ph,
                                Text(
                                  "Postal code: ${getAddressList[index].postalCode}",
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                                8.ph,
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const CustomProgressBar();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
