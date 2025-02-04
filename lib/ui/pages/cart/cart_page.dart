import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/get_cart_model.dart';
import 'package:happy_bash/ui/pages/cart/confirm_address_page.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/image_constants.dart';
import '../../../core/constants/static_words.dart';
import '../../../network/base_url.dart';
import '../../../theme/theme_helper.dart';
import '../../screen/login_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late GetCartModel getCartModel;
  late SharedPreferences prefs;
  double toBePaidNow = 0.0;
  double totalAmount = 0.0;
  double deliveryCharges = 0.0;
  int selectedValue = 1;
  String startFormattedDate = "";
  String endFormattedDate = "";



  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<GetCartModel> getCartApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.getCart}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());

    try {
      if (response.statusCode == 200) {
        printMsgTag("getCartApi ResponseData", responseData);
        return GetCartModel.fromJson(responseData);
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getCartApi catch", exception.toString());
    }

    return GetCartModel.fromJson(responseData);
  }

  Future<Map<String, dynamic>> deleteCartApi(int cartId) async {
    var responseData;
    String token = await getToken();

    final jsonResponse = await http.delete(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.deleteCart}/$cartId"),
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
      backgroundColor: Colors.white,
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
      body: FutureBuilder<SharedPreferences>(
        future: getSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            prefs = snapshot.data!;
            if (getIsUserLogin(prefs) == true) {
              return FutureBuilder<GetCartModel>(
                  future: getCartApi(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      getCartModel = snapshot.data!;
                      if (getCartModel.cart != null) {
                        if (getCartModel.cart!.cartItems!.isNotEmpty) {
                          var cartItems = getCartModel.cart!.cartItems;
                          String toBePaidNowNew = getCartModel.toBePaidNow ?? "0";
                          String totalAmountNew = getCartModel.totalAmount ?? "0";
                          String deliveryChargesNew = getCartModel.shippingCharges ?? "0";
                          String totalNew = getCartModel.total ?? "0";
                           // double total = getCartModel.cart!.cartItems!
                           //     .map((e) => double.tryParse(e.total ?? '0.0') ?? 0.0)
                           //     .fold(0.0, (previousValue, element) => previousValue + element);
                           // toBePaidNow = getCartModel.cart!.cartItems!
                           //     .where((e) => e.product?.checkOutType == "Available" || e.product?.checkOutType == "On time") // Filter items with "Available" checkoutType
                           //     .map((e) => double.tryParse(e.total ?? '0.0') ?? 0.0) // Parse total to double
                           //     .fold(0.0, (previousValue, element) => previousValue + element) + deliveryCharges; // Sum up the filtered items
                           // deliveryCharges = getCartModel.cart!.cartItems!
                           //     .map((e) => double.tryParse(e.shippingPrice ?? '0.0') ?? 0.0)
                           //     .reduce((current, next) => current > next ? current : next);
                           // totalAmount = total + deliveryCharges;

                          return Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    10.ph,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 35.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.redAccent),
                                            ),
                                            child: const CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              height: 1,
                                              color: Colors.black26,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black26),
                                            ),
                                            child: const CircleAvatar(
                                              radius: 5,
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              height: 1,
                                              color: Colors.black26,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black26),
                                            ),
                                            child: const CircleAvatar(
                                              radius: 5,
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0, right: 20, top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Cart",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.redAccent,
                                              fontFamily: poppinsRegular,
                                            ),
                                          ),
                                          Text(
                                            "Confirm address",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontFamily: poppinsRegular,
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      color: const Color(0xFFFCF4EA),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              "assets/HappyBash/location-1.svg"),
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
                                    ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: cartItems!.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Divider(
                                          color: Colors.grey.shade300,
                                          thickness: 0.7,
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        if (cartItems[index].startDate !=
                                                null &&
                                            cartItems[index].endDate != null) {
                                          // Convert string to DateTime object
                                          DateTime originalStartDate =
                                              DateTime.parse(cartItems[index]
                                                  .startDate
                                                  .toString());
                                          DateTime originalEndDate =
                                              DateTime.parse(cartItems[index]
                                                  .endDate
                                                  .toString());

                                          // Format the DateTime object as required
                                          startFormattedDate =
                                              DateFormat('dd MMM yyyy')
                                                  .format(originalStartDate);
                                          endFormattedDate =
                                              DateFormat('dd MMM yyyy')
                                                  .format(originalEndDate);
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 65,
                                                    height: 55,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: getCartModel
                                                              .cart!
                                                              .cartItems![index]
                                                              .product!
                                                              .images!
                                                              .isEmpty
                                                          ? Container(
                                                              width: 65,
                                                              height: 55,
                                                              color: Colors.grey
                                                                  .shade200,
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  "No image\nfound",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Image.network(
                                                              // "assets/images/sofaFullview.png",
                                                              getCartModel
                                                                  .cart!
                                                                  .cartItems![
                                                                      index]
                                                                  .product!
                                                                  .images![0]
                                                                  .imageUrl
                                                                  .toString(),
                                                              fit: BoxFit.fill,
                                                            ),
                                                    ),
                                                  ),
                                                  10.pw,
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                // "Curved sofa",
                                                                getCartModel
                                                                    .cart!
                                                                    .cartItems![
                                                                        index]
                                                                    .product!
                                                                    .name!,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      poppinsSemiBold,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              onTap: () {
                                                                showModal(
                                                                  context:
                                                                      context,
                                                                  configuration:
                                                                      const FadeScaleTransitionConfiguration(
                                                                    transitionDuration:
                                                                        Duration(
                                                                            milliseconds:
                                                                                500),
                                                                    reverseTransitionDuration:
                                                                        Duration(
                                                                            milliseconds:
                                                                                300),
                                                                  ),
                                                                  builder: (_) {
                                                                    return AlertDialog(
                                                                      // actionsAlignment: MainAxisAlignment.center,
                                                                      title: const Text(
                                                                          "Remove item"),
                                                                      // titlePadding: EdgeInsets.zero,
                                                                      content:
                                                                          const Text(
                                                                              "Are you sure want to remove item from cart"),
                                                                      actions: <Widget>[
                                                                        MaterialButton(
                                                                          color:
                                                                              PrimaryColors().primarycolor,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            deleteCartApi(getCartModel.cart!.cartItems![index].id!).then(
                                                                              (value) {
                                                                                printMsgTag("value", value['message']);
                                                                                if (value['message'] == "Item removed from cart") {
                                                                                  Navigator.pop(context);
                                                                                  showSnackBar(context, "Item removed from cart");
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Okay",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MaterialButton(
                                                                          color:
                                                                              PrimaryColors().white,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                          ),
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                          child:
                                                                              const Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ).then((value) {
                                                                  setState(
                                                                      () {});
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                                color: Colors
                                                                    .red
                                                                    .shade300,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        3.ph,
                                                        Row(
                                                          children: [
                                                            // const Text(
                                                            //   'KD 120.00',
                                                            //   style: TextStyle(
                                                            //     color: Color(
                                                            //         0xFF9B9B9B),
                                                            //     fontSize: 14,
                                                            //     fontFamily:
                                                            //         poppinsRegular,
                                                            //     fontWeight:
                                                            //         FontWeight
                                                            //             .w400,
                                                            //     decoration:
                                                            //         TextDecoration
                                                            //             .lineThrough,
                                                            //   ),
                                                            // ),
                                                            // 10.pw,
                                                            if(cartItems[index].product?.priceType == "price_per_day")
                                                            const Text(
                                                              'Per Day Price ',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF333333),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                poppinsRegular,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                              ),
                                                            ),
                                                            if(cartItems[index].product?.priceType != "price_per_day" && cartItems[index].product?.pricePerDay != null)
                                                              const Text(
                                                                'Per Item Price ',
                                                                style: TextStyle(
                                                                  color: Color(
                                                                      0xFF333333),
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                  poppinsRegular,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                ),
                                                              ),
                                                            if(cartItems[index].product?.pricePerDay != null)
                                                              Text(
                                                              'KD ${cartItems[index].product?.pricePerDay ?? ""}',
                                                              // 'KD ${cartItems[index].quantity! * double.parse(getCartModel.cart!.cartItems![index].product!.pricePerDay.toString())}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF333333),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    poppinsBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        3.ph,
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Overall Cost ',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF333333),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                poppinsRegular,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                              ),
                                                            ),
                                                            Text(
                                                              'KD ${cartItems[index].total}',
                                                              // 'KD ${cartItems[index].quantity! * double.parse(getCartModel.cart!.cartItems![index].product!.pricePerDay.toString())}',
                                                              style:
                                                              const TextStyle(
                                                                color: Color(
                                                                    0xFF333333),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                poppinsBold,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        10.ph,
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                "Quantity: "),
                                                            Text(
                                                              cartItems[index]
                                                                  .quantity
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    poppinsRegular,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              ),
                                              10.ph,
                                              const Text(
                                                "Event dates",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  fontFamily: poppinsRegular,
                                                ),
                                              ),
                                              Text(
                                                "$startFormattedDate - $endFormattedDate",
                                                style: TextStyle(
                                                  color: Colors.grey.shade900,
                                                  fontFamily: poppinsRegular,
                                                ),
                                              ),
// Adding the "Addons" section
                                              if (cartItems[index].addons != null && cartItems[index].addons!.isNotEmpty) ...[
                                                20.ph,
                                                const Text(
                                                  "Addons",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: poppinsRegular,
                                                  ),
                                                ),
                                                5.ph,
                                                // Dynamically adding views for each addon
                                                for (var addon in cartItems[index].addons!) ...[
                                                  Container(
                                                    // padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          addon.name ?? '',
                                                          style: TextStyle(
                                                            color: Colors.grey.shade900,
                                                            fontFamily: poppinsRegular,
                                                          ),
                                                        ),
                                                        Text(
                                                          'KD ${addon.price ?? '0.0'}', // Format price here, adjust currency symbol as needed
                                                          style: TextStyle(
                                                            color: Colors.grey.shade600,
                                                            fontFamily: poppinsRegular,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Divider(color: Colors.grey.shade300), // Optional: adds a divider between each addon
                                                ],
                                              ]


                                              // 10.ph,
                                              // Text(
                                              //   "Manage booking options",
                                              //   style: TextStyle(
                                              //     color: PrimaryColors()
                                              //         .primarycolor,
                                              //     fontFamily: poppinsSemiBold,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    // 20.ph,
                                    // Card(
                                    //   margin: const EdgeInsets.symmetric(
                                    //       horizontal: 10),
                                    //   color: const Color.fromARGB(
                                    //       255, 252, 237, 217),
                                    //   elevation: 0.0,
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         vertical: 15.0, horizontal: 20),
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.spaceBetween,
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.center,
                                    //       children: [
                                    //         Row(
                                    //           children: [
                                    //             SvgPicture.asset(
                                    //                 "assets/icons/Percent_polygon.svg"),
                                    //             10.pw,
                                    //             const Text(
                                    //               "Apply coupon",
                                    //               style: TextStyle(
                                    //                 fontFamily: poppinsSemiBold,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         const Icon(
                                    //           Icons.arrow_forward_ios,
                                    //           size: 20,
                                    //         )
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    20.ph,
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //   children: [
                                    //     Flexible(
                                    //       child: Radio(activeColor: Color(0xFF2A9DA0),value: 1, groupValue: selectedValue, onChanged: (int? value) {
                                    //         setState(() {
                                    //           selectedValue = value!;
                                    //         });
                                    //       },),
                                    //     ),
                                    //     Flexible(child: Text("Available",style: TextStyle(fontSize: 10,),)),
                                    //     Flexible(
                                    //       child: Radio(activeColor: Color(0xFF2A9DA0),value: 2, groupValue: selectedValue, onChanged: (int? value) {
                                    //         setState(() {
                                    //           selectedValue = value!;
                                    //         });
                                    //       },),
                                    //     ),
                                    //     Flexible(child: Text("Waiting\nfor\nconfirmation",style: TextStyle(fontSize: 10),)),
                                    //     Flexible(
                                    //       child: Radio(activeColor: Color(0xFF2A9DA0),value: 3, groupValue: selectedValue, onChanged: (int? value) {
                                    //         setState(() {
                                    //         selectedValue = value!;
                                    //         });
                                    //       },),
                                    //     ),
                                    //     Flexible(child: Text("Depending on time",style: TextStyle(fontSize: 10),)),
                                    //   ],
                                    // ),
                                    // 20.ph,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 3,
                                                height: 20,
                                                decoration: ShapeDecoration(
                                                  color:
                                                      const Color(0xFFE38E31),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                              ),
                                              8.pw,
                                              const Text(
                                                'Price details',
                                                style: TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 16,
                                                  fontFamily: serifRegular,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )
                                            ],
                                          ),
                                          10.ph,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Total",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontFamily: poppinsMedium,
                                                ),
                                              ),
                                              Text(
                                                // "KD 160.000",
                                                "KD $totalNew",
                                                style: const TextStyle(
                                                  fontFamily: poppinsSemiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          10.ph,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Delivery charges",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontFamily: poppinsMedium,
                                                ),
                                              ),
                                              Text(
                                                // "KD 10.000",
                                                "KD $deliveryChargesNew",
                                                style: const TextStyle(
                                                  fontFamily: poppinsSemiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          10.ph,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Total amount",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontFamily: poppinsMedium,
                                                ),
                                              ),
                                              Text(
                                                "KD $totalAmountNew",
                                                style: const TextStyle(
                                                  fontFamily: poppinsSemiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          10.ph,
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.spaceBetween,
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.center,
                                          //   children: [
                                          //     Text(
                                          //       "To be paid now",
                                          //       style: TextStyle(
                                          //         color: Colors.grey.shade600,
                                          //         fontFamily: poppinsMedium,
                                          //       ),
                                          //     ),
                                          //      Text(
                                          //        getCartModel.cart?.toBePaidNow ?? "",
                                          //       style: TextStyle(
                                          //         fontFamily: poppinsSemiBold,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // 10.ph,
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.spaceBetween,
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.center,
                                          //   children: [
                                          //     Text(
                                          //       "Coupon discount",
                                          //       style: TextStyle(
                                          //         color: Colors.grey.shade600,
                                          //         fontFamily: poppinsMedium,
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       "Apply coupon",
                                          //       style: TextStyle(
                                          //         fontFamily: poppinsSemiBold,
                                          //         color: PrimaryColors()
                                          //             .primarycolor,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // 5.ph,
                                          Divider(color: Colors.grey.shade300),
                                          5.ph,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "To be paid now",
                                                style: TextStyle(
                                                  fontFamily: poppinsBold,
                                                ),
                                              ),
                                              Text(
                                                "KD $toBePaidNowNew",
                                                style: const TextStyle(
                                                  fontFamily: poppinsBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    100.ph,
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: width,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
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
                                      navigateAddScreen(context,
                                          ConfirmAddress(prefs: prefs,selectedValue : selectedValue,getCartModel: getCartModel,));
                                    },
                                    color: const Color(0xFF2A9DA0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(36)),
                                    child: Text(
                                      'Confirm booking'.toUpperCase(),
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
                        else {
                          return Center(
                            // child: Text("No items found"),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  ImageConstant.emptyCart,
                                ),
                                5.ph,
                                MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 2.5,
                                  color: PrimaryColors().primarycolor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () => navigateReplaceAll(
                                      context,
                                      BottomNavigationBarScreen(
                                          selectedIndex: 1)),
                                  child: Text(
                                    "Add Product",
                                    style: TextStyle(
                                      color: PrimaryColors().white,
                                      fontFamily: poppinsSemiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      }
                      else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                ImageConstant.emptyCart,
                              ),
                              5.ph,
                              MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width / 2.5,
                                color: PrimaryColors().primarycolor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onPressed: () => navigateReplaceAll(
                                    context,
                                    BottomNavigationBarScreen(
                                        selectedIndex: 1)),
                                child: Text(
                                  "Add Product",
                                  style: TextStyle(
                                    color: PrimaryColors().white,
                                    fontFamily: poppinsSemiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.data.toString()),
                      );
                    }
                    return const CustomProgressBar();
                  });
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(ImageConstant.noBooking),
                    20.ph,
                    MaterialButton(
                      onPressed: () {
                        navigateAddScreen(context, const LoginScreen());
                      },
                      height: 45,
                      color: PrimaryColors().primarycolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Login to see Cart".toUpperCase(),
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
