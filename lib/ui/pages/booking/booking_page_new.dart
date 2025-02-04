import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/booking_model_new.dart';
import 'package:happy_bash/models/get_bookings_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/ui/pages/booking/booking_details_page.dart';
import 'package:happy_bash/ui/screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/dialog_box.dart';
import '../../../core/constants/static_words.dart';
import '../../../theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../screen/bottom_navigation_screen.dart';
class BookingPageNew extends StatefulWidget {
  BookingPageNew({super.key, required this.uniqueId,required this.navigatePage,});

  final int uniqueId;
  String navigatePage;
  @override
  State<BookingPageNew> createState() => _BookingPageStateNew();
}

class _BookingPageStateNew extends State<BookingPageNew> {
  late SharedPreferences prefs;
  BookingModelNew? bookingModel;
  List<GetBookingsModel> bookingList = [];
  DateTime currentDate = DateTime.now();
  String? _webViewLink;
  bool _showWebView = false;
  bool isLoading = true; // Manage loading state

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    prefs = await SharedPreferences.getInstance();
    await fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      String token = await getToken();
      final response = await http.get(
        Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.allBooking}?unique_id=${widget.uniqueId}"),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        bookingModel = BookingModelNew.fromJson(responseData);
        bookingList = bookingModel?.bookings ?? [];
      } else {
        throw Exception("Failed to fetch bookings");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> checkOut(int bookingId) async {
    String token = await getToken();
    String reqParam = jsonEncode({
      "booking_id": bookingId,
    });

    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.afterConfirmationPayment}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: reqParam,
    );

    return jsonDecode(response.body);
  }

  Future<void> initiatePayment(int bookingId) async {
    try {
      var responseData = await checkOut(bookingId);
      setState(() {
        _webViewLink = responseData['data']['link'];
        _showWebView = true;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to initiate payment. Please try again."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void handlePageStarted(String url) {
    if (url.contains('payment-response')) {
      Uri uri = Uri.parse(url);
      String? result = uri.queryParameters['result'];
      if (result == 'CAPTURED') {
        processPaymentResult("Payment and Order Successful",
            "Your payment was successful and your order has been placed successfully", true);
      } else {
        processPaymentResult("Payment Failed",
            "The payment process failed. Please try again or contact support if the issue persists.", false);
      }
    } else if (url.contains('payment-cancel')) {
      processPaymentResult("Payment Cancelled",
          "The payment process has been cancelled. If you wish to proceed, please start again.", false);
    }
  }

  void processPaymentResult(String title, String content, bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showWebView = false;
      });
      ModelUtils.showSimpleAlertDialog(
        context,
        title: Text(
          title,
          style: TextStyle(color: success ? Colors.green : Colors.redAccent),
        ),
        content: content,
        okBtnFunction: () {
          if (success) {
            navigateReplaceAll(context, BottomNavigationBarScreen(selectedIndex: 0));
          } else {
            Navigator.pop(context);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: CustomProgressBar());
    }

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
          'Booking Details',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 15,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _showWebView
          ? WebView(
        initialUrl: _webViewLink,
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: handlePageStarted,
        navigationDelegate: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      )
          : getIsUserLogin(prefs)
          ? DefaultTabController(
        length: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.blue),
                        SizedBox(width: 10), // Space between the icon and the text
                        Expanded(
                          child: Text(
                            "Booking Id - #${bookingModel?.summary?.uniqueId ?? "-"}",
                            style: const TextStyle(
                              fontFamily: 'PoppinsMedium',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between items
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.green),
                        SizedBox(width: 10), // Space between the icon and the text
                        Expanded(
                          child: Text(
                            "Shipping Price - ${bookingModel?.summary?.shippingPrice ?? "-"}",
                            style: const TextStyle(
                              fontFamily: 'PoppinsMedium',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between items
                  // Container(
                  //   padding: EdgeInsets.zero,
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.info_outline, color: Colors.orange),
                  //       SizedBox(width: 10), // Space between the icon and the text
                  //       Expanded(
                  //         child: Text(
                  //           "Order Status - ${bookingModel?.summary?.status ?? "-"}",
                  //           style: const TextStyle(
                  //             fontFamily: 'PoppinsMedium',
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 10), // Spacing between items
                  // Container(
                  //   padding: EdgeInsets.zero,
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.payment, color: Colors.red),
                  //       SizedBox(width: 10), // Space between the icon and the text
                  //       Expanded(
                  //         child: Text(
                  //           "Payment status - ${bookingModel?.summary?.paymentStatus ?? "-"}",
                  //           style: const TextStyle(
                  //             fontFamily: 'PoppinsMedium',
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 10), // Spacing between items
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on_rounded, color: Colors.green),
                        SizedBox(width: 10), // Space between the icon and the text
                        Expanded(
                          child: Text(
                            "Total Amount - ${bookingModel?.summary?.totalAmount ?? "-"}",
                            style: const TextStyle(
                              fontFamily: 'PoppinsMedium',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookingList.isNotEmpty
                  ? ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: bookingList.length,
                itemBuilder: (context, index) {
                  final booking = bookingList[index];
                  DateTime startDate = DateTime.parse(booking.startDatetime!);
                  DateTime endDate = DateTime.parse(booking.endDatetime!);
                  String formattedStartDate = DateFormat('dd MMMM, yyyy').format(startDate);
                  String formattedEndDate = DateFormat('dd MMMM, yyyy').format(endDate);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 5.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(ImageConstant.calendar),
                              10.pw,
                              Text(
                                "$formattedStartDate - $formattedEndDate",
                                style: const TextStyle(
                                  fontFamily: poppinsRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                        15.ph,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   "${bookingList[index].products!.length} product",
                              //   style: const TextStyle(
                              //     fontSize: 16,
                              //     fontFamily: poppinsSemiBold,
                              //   ),
                              // ),
                              // 15.ph,
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: bookingList[index].products!.length,
                                  itemBuilder: (context, productIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 55,
                                            height: 50,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                bookingList[index].products![productIndex].image.toString(),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          8.pw,
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              5.ph,
                                              Text(
                                                bookingList[index].products![productIndex].name.toString(),
                                                style: const TextStyle(
                                                  fontFamily: poppinsMedium,
                                                ),
                                              ),
                                              3.ph,
                                              if (bookingList[index].products![productIndex].pivot?.price != null)
                                                Column(
                                                children: [
                                                    Text(
                                                      'KD ${bookingList[index].products![productIndex].pivot?.price}${bookingList[index].products![productIndex].priceType == "price_per_day" ? "/per day" : ""}',
                                                      style: TextStyle(
                                                        fontFamily: 'PoppinsRegular',
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  5.ph, // This assumes ph is a predefined extension or method on double.
                                                ],
                                              ),
                                              if (bookingList[index].products![productIndex].pivot?.color != null)
                                                Column(
                                                children: [
                                                    Text(
                                                      "Color - ${bookingList[index].products![productIndex].pivot?.color}",
                                                      style: TextStyle(
                                                        fontFamily: 'PoppinsRegular',
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  5.ph, // Assumes ph is a predefined extension or method on double for padding or margin.
                                                ],
                                              ),
                                              if (bookingList[index].products![productIndex].pivot?.size != null)
                                                Column(
                                                children: [
                                                  Text(
                                                      "Size - ${bookingList[index].products![productIndex].pivot?.size}",
                                                      style: TextStyle(
                                                        fontFamily: 'PoppinsRegular',
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  // Include any additional widgets or logic here
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              20.ph,
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingDetailsPage(
                                              bookingList: bookingList[index],
                                              dates: '$formattedStartDate - $formattedEndDate',
                                              navigatePage: widget.navigatePage,
                                            ),
                                          ),
                                        ).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      color: PrimaryColors().primarycolor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "View Details".toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: poppinsSemiBold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              15.ph,
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'PoppinsRegular', // make sure the font name matches exactly
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Order Status - ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: bookingList[index].status ?? "",
                                      style: TextStyle(
                                        color: bookingList[index].status == "confirmed"
                                            ? Colors.green
                                            : bookingList[index].status == "pending"
                                            ? Colors.red
                                            : bookingList[index].status == "initiated"
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              15.ph,
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'PoppinsRegular', // make sure the font name matches exactly
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Payment Status - ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: bookingList[index].paymentStatus ?? "",
                                      style: TextStyle(
                                        color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              15.ph,
                              if (bookingList[index].status == "confirmed" &&
                                  bookingList[index].checkoutType == "Waiting for confirmation" &&
                                  bookingList[index].paymentStatus != "Paid"
                              )
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: MaterialButton(
                                    onPressed: () {
                                      initiatePayment(bookingList[index].id ?? 1);
                                    },
                                    color: PrimaryColors().primarycolor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Pay Now".toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontFamily: poppinsSemiBold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : const Center(child: Text("No bookings found")),
            ),
          ],
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(ImageConstant.noBooking),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                navigateAddScreen(context, const LoginScreen());
              },
              color: PrimaryColors().primarycolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              child: Text(
                "Login to see booking".toUpperCase(),
                style: TextStyle(color: PrimaryColors().white, fontFamily: poppinsSemiBold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

