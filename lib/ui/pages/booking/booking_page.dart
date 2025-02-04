import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
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

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late SharedPreferences prefs;
  List<GetBookingsModel> bookingList = [];
  List<GetBookingsModel> pastBookings = [];
  DateTime currentDate = DateTime.now();
  String? _webViewLink;
  bool _showWebView = false;
  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<List<GetBookingsModel>> getBookingsApi() async {
    String token = await getToken();

    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.allBooking}"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    bookingList.clear();

    try {
      if (response.statusCode == 200) {
        printMsgTag("getWaitlistApi ResponseData", responseData);
        for (Map i in responseData) {
          bookingList.add(GetBookingsModel.fromJson(i));
        }

        pastBookings.clear();

        for (var booking in bookingList) {
          DateTime endDateTime = DateTime.parse(booking.endDatetime.toString());
          if (currentDate.isBefore(endDateTime)) {
            pastBookings.add(booking);
          }
        }
        printMsgTag("pastBookings", pastBookings);

        return bookingList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getWaitlistApi catch", exception.toString());
    }

    return bookingList;
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
    var responseData = jsonDecode(response.body.toString());
    return responseData;
  }
  Future<void> initiatePayment(int bookingId) async {
    try {
      var responseData = await checkOut(bookingId);
      setState(() {
        _webViewLink = responseData['data']['link'];
        _showWebView = true;
      });
    } catch (e) {
      // Handle errors or show an alert dialog if something goes wrong
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
        // Payment successful
        processPaymentResult("Payment and Order Successful", "Your payment was successful and your order has been placed successfully", true);
      } else {
        // Payment failed
        processPaymentResult("Payment Failed", "The payment process failed. Please try again or contact support if the issue persists.", false);
      }
    } else if (url.contains('payment-cancel')) {
      // Payment cancelled
      processPaymentResult("Payment Cancelled", "The payment process has been cancelled. If you wish to proceed, please start again.", false);
    }
  }
  void processPaymentResult(String title, String content, bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showWebView = false;
      });
      ModelUtils.showSimpleAlertDialog(
        context,
        title: Text(title, style: TextStyle(color: success ? Colors.green : Colors.redAccent)),
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
    return Scaffold(
      body:_showWebView ? WebView(
        initialUrl: _webViewLink,
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: handlePageStarted,
        navigationDelegate: (NavigationRequest request) {
          // if (request.url.contains('payment-response') || request.url.contains('payment-cancel')) {
          //   return NavigationDecision.navigate;
          // }
          return NavigationDecision.navigate;
        },
      ) :
      FutureBuilder<SharedPreferences>(
        future: getSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            prefs = snapshot.data!;
            double half = height / 2;
            int halfint = half.toInt();

            return DefaultTabController(
              length: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  77.ph,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TabBar(
                      labelColor: PrimaryColors().primarycolor,
                      unselectedLabelColor: const Color(0xFF9B9B9B),
                      labelStyle: const TextStyle(
                        color: Color(0xFF2A9DA0),
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      indicatorColor: PrimaryColors().primarycolor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(
                          text: "Upcoming",
                        ),
                        Tab(
                          text: "All Booking",
                        )
                      ],
                    ),
                  ),
                  getIsUserLogin(prefs) == true
                      ? Expanded(
                          child: FutureBuilder(
                              future: getBookingsApi(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return TabBarView(
                                    children: [
                                      //------------------- Upcoming Booking -------------------//

                                      pastBookings.isNotEmpty
                                          ? ListView.builder(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                top: 16.0,
                                              ),
                                              itemCount: pastBookings.length,
                                              itemBuilder: (context, index) {
                                                // Parse the date-time string to a DateTime object
                                                DateTime parsedStartDateTime =
                                                    DateTime.parse(
                                                        pastBookings[index]
                                                            .startDatetime
                                                            .toString());

                                                // Format the DateTime object to the desired format
                                                String formattedStartDate =
                                                    DateFormat('dd MMMM, yyyy')
                                                        .format(
                                                            parsedStartDateTime);
                                                // Parse the date-time string to a DateTime object
                                                DateTime parsedEndDateTime =
                                                    DateTime.parse(
                                                        pastBookings[index]
                                                            .endDatetime
                                                            .toString());

                                                // Format the DateTime object to the desired format
                                                String formattedEndDate =
                                                    DateFormat('dd MMMM, yyyy')
                                                        .format(
                                                            parsedEndDateTime);
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
                                                            Text(
                                                              "${pastBookings[index].products!.length} product",
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontFamily: poppinsSemiBold,
                                                              ),
                                                            ),
                                                            15.ph,
                                                            SizedBox(
                                                              height: 60,
                                                              child: ListView.builder(
                                                                scrollDirection: Axis.horizontal,
                                                                itemCount: pastBookings[index].products!.length,
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
                                                                              pastBookings[index].products![productIndex].image.toString(),
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
                                                                              pastBookings[index].products![productIndex].name.toString(),
                                                                              style: const TextStyle(
                                                                                fontFamily: poppinsMedium,
                                                                              ),
                                                                            ),
                                                                            3.ph,
                                                                            Text(
                                                                              "KD ${pastBookings[index].products![productIndex].pivot?.price ?? ""}${pastBookings[index].products![productIndex].priceType == "price_per_day" ? "/per day" : ""}",
                                                                              style: TextStyle(
                                                                                fontFamily: 'PoppinsRegular',
                                                                                color: Colors.grey.shade600,
                                                                              ),
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
                                                                            bookingList: pastBookings[index],
                                                                            dates: '$formattedStartDate - $formattedEndDate',
                                                                            navigatePage: "upcoming",
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
                                                            Text(
                                                              pastBookings[index].status ?? "",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily: poppinsRegular,
                                                                color: pastBookings[index].status == "confirmed"
                                                                    ? Colors.green
                                                                    : pastBookings[index].status == "pending"
                                                                    ? Colors.red
                                                                    : pastBookings[index].status == "initiated"
                                                                    ? Colors.orange
                                                                    : Colors.grey,
                                                              ),
                                                            ),
                                                            15.ph,
                                                            if (pastBookings[index].status == "confirmed" &&
                                                                pastBookings[index].checkoutType == "Waiting for confirmation" &&
                                                                pastBookings[index].paymentStatus != "Paid"
                                                            )
                                                              Align(
                                                                alignment: Alignment.bottomRight,
                                                                child: MaterialButton(
                                                                  onPressed: () {
                                                                    initiatePayment(pastBookings[index].id ?? 1);
                                                                  },
                                                                  color: Colors.blue,
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
                                          : const Center(
                                              child: Text(
                                                  "No upcomming bookings found"),
                                            ),

                                      //------------------- All Booking -------------------//

                                      bookingList.isNotEmpty
                                          ? ListView.builder(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                top: 16.0,
                                              ),
                                              itemCount: bookingList.length,
                                              itemBuilder: (context, index) {
                                                // Parse the date-time string to a DateTime object
                                                DateTime parsedStartDateTime =
                                                    DateTime.parse(
                                                        bookingList[index]
                                                            .startDatetime
                                                            .toString());

                                                // Format the DateTime object to the desired format
                                                String formattedStartDate =
                                                    DateFormat('dd MMMM, yyyy')
                                                        .format(
                                                            parsedStartDateTime);
                                                // Parse the date-time string to a DateTime object
                                                DateTime parsedEndDateTime =
                                                    DateTime.parse(
                                                        bookingList[index]
                                                            .endDatetime
                                                            .toString());

                                                // Format the DateTime object to the desired format
                                                String formattedEndDate =
                                                    DateFormat('dd MMMM, yyyy')
                                                        .format(
                                                            parsedEndDateTime);
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  clipBehavior: Clip.hardEdge,
                                                  color: Colors.white,
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  elevation: 5.0,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        color: Colors
                                                            .grey.shade200,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                                ImageConstant
                                                                    .calendar),
                                                            10.pw,
                                                            Text(
                                                              // "29 Sept, 2023 - 31 Sept, 2023",
                                                              "$formattedStartDate - $formattedEndDate",
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      poppinsRegular),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      15.ph,
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    20.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${bookingList[index].products!.length} product",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    poppinsSemiBold,
                                                              ),
                                                            ),
                                                            15.ph,
                                                            SizedBox(
                                                              height: 60,
                                                              child: ListView
                                                                  .builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount:
                                                                    bookingList[
                                                                            index]
                                                                        .products!
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        productIndex) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            50),
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              55,
                                                                          height:
                                                                              50,
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            child:
                                                                                Image.network(
                                                                              // "assets/images/sofaFullview.png",
                                                                              bookingList[index].products![productIndex].image.toString(),
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        8.pw,
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            5.ph,
                                                                            Text(
                                                                              // "Pearl Sofa",
                                                                              bookingList[index].products![productIndex].name.toString(),
                                                                              style: const TextStyle(
                                                                                fontFamily: poppinsMedium,
                                                                              ),
                                                                            ),
                                                                            3.ph,
                                                                            Text(
                                                                              "KD ${bookingList[index].products![productIndex].pivot?.price ?? ""}${bookingList[index].products![productIndex].priceType == "price_per_day" ? "/per day" : ""}",
                                                                              style: TextStyle(
                                                                                fontFamily: poppinsRegular,
                                                                                color: Colors.grey.shade600,
                                                                              ),
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
                                                                  child:
                                                                      MaterialButton(
                                                                    onPressed:
                                                                        () {
                                                                      navigateAddScreen(
                                                                          context,
                                                                          BookingDetailsPage(
                                                                            bookingList:
                                                                                bookingList[index],
                                                                            dates:
                                                                                '$formattedStartDate - $formattedEndDate',
                                                                            navigatePage:
                                                                                'all',
                                                                          ));
                                                                    },
                                                                    color: PrimaryColors()
                                                                        .primarycolor,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    child: Text(
                                                                      "View Details"
                                                                          .toUpperCase(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            poppinsSemiBold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            15.ph,
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : const Center(
                                              child: Text("No bookings found"),
                                            )
                                    ],
                                  );
                                }
                                return const CustomProgressBar();
                              }),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              (halfint / 2).ph,
                              SvgPicture.asset(ImageConstant.noBooking),
                              20.ph,
                              MaterialButton(
                                onPressed: () {
                                  navigateAddScreen(
                                      context, const LoginScreen());
                                },
                                height: 45,
                                color: PrimaryColors().primarycolor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  "Login to see booking".toUpperCase(),
                                  style: TextStyle(
                                    color: PrimaryColors().white,
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            );
          }
          return const CustomProgressBar();
        },
      ),
    );
  }
}
