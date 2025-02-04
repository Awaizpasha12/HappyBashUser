import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/navigator.dart';
import '../../../core/constants/static_words.dart';
import '../../../core/utils/size_utils.dart';
import '../../../models/get_address_model.dart';
import '../../../models/get_cart_model.dart';
import '../../../network/base_url.dart';
import '../profile/address/add_address_page.dart';
import 'payment_page.dart';

class ConfirmAddress extends StatefulWidget {
  const ConfirmAddress({super.key, required this.prefs, required this.selectedValue,required this.getCartModel});

  final SharedPreferences prefs;
  final int selectedValue;
  final GetCartModel getCartModel;
  @override
  State<ConfirmAddress> createState() => _ConfirmAddressState();
}

class _ConfirmAddressState extends State<ConfirmAddress> {
  List<GetAddressModel> getAddressList = [];
  int selectedAddressId = 0;
  late GetAddressModel selectedAddress;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 15,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                10.ph,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 1,
                          color: Colors.redAccent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 1,
                          color: Colors.black26,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                        child: const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 20, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cart",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontFamily: poppinsRegular,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Confirm address",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontFamily: poppinsRegular,
                          ),
                        ),
                      ),
                      Text(
                        "Payment",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontFamily: poppinsRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                20.ph,
                Container(
                  width: width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  color: const Color(0xFFFCF4EA),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/HappyBash/location-1.svg"),
                      8.pw,
                      Text(
                        // 'Abdullah Al Salem',
                        getLocation(widget.prefs),
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
                12.ph,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: FutureBuilder(
                    future: addressGetApi(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            if (getAddressList.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: getAddressList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedAddressId = getAddressList[index].id!;
                                        selectedAddress = getAddressList[index];
                                      });
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: selectedAddressId == getAddressList[index].id
                                              ? PrimaryColors().primarycolor
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                    ),
                                  );
                                },
                              ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddAddressPage(),
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                              height: 40,
                              color: PrimaryColors().primarycolor.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            SizedBox(height: 30),
                            if (getAddressList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "No address found",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontFamily: poppinsMedium,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
                      return const CustomProgressBar();
                    },
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                  if (selectedAddressId != 0) {
                    navigateAddScreen(
                        context,
                        PaymentPage(
                          addressId: selectedAddressId,
                            selectedValue : widget.selectedValue,getCartModel: widget.getCartModel,getAddressModel: selectedAddress,
                        ));
                  } else {
                    ModelUtils.showSimpleAlertDialog(
                      context,
                      title: const Text("Happy bash"),
                      content: "Please select address",
                      okBtnFunction: () => Navigator.pop(context),
                    );
                  }
                },
                color: const Color(0xFF2A9DA0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36)),
                child: Text(
                  'Go to payment'.toUpperCase(),
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
      ),
    );
  }
}
