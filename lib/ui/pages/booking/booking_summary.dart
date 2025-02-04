import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/book_summary_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/static_words.dart';
import '../../../theme/theme_helper.dart';
import 'booking_page.dart';
import 'booking_page_new.dart';

class BookingSummary extends StatefulWidget {
  const BookingSummary({super.key});

  @override
  State<BookingSummary> createState() => _BookingSummaryState();
}

class _BookingSummaryState extends State<BookingSummary> {
  late SharedPreferences prefs;
  List<BookSummaryModel> summaryList = [];
  List<BookSummaryModel> pastSummaryList = [];
  DateTime currentDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    loadBookingSummary();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadBookingSummary() async {
    String token = await getToken();

    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.bookingSummary}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    summaryList.clear();

    try {
      if (response.statusCode == 200) {
        printMsgTag("getWaitlistApi ResponseData", responseData);
        for (Map i in responseData) {
          summaryList.add(BookSummaryModel.fromJson(i));
        }

        pastSummaryList.clear();

        for (var booking in summaryList) {
          DateTime endDateTime = DateTime.parse(booking.bookingDateTime.toString());
          if (currentDate.isBefore(endDateTime)) {
            pastSummaryList.add(booking);
          }
        }
        printMsgTag("pastSummaryList", pastSummaryList);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (exception) {
      printMsgTag("getWaitlistApi catch", exception.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: CustomProgressBar(),
      );
    } else {
      return Scaffold(
        body: DefaultTabController(
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
                    Tab(text: "Upcoming"),
                    Tab(text: "All Bookings"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildUpcomingBookings(),
                    buildAllBookings(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget buildUpcomingBookings() {
    if (pastSummaryList.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        itemCount: pastSummaryList.length,
        itemBuilder: (context, index) {
          DateTime parsedEndDateTime = DateTime.parse(pastSummaryList[index].bookingDateTime.toString());
          String formattedEndDate = DateFormat('dd MMMM, yyyy').format(parsedEndDateTime);
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
                        formattedEndDate,
                        style: const TextStyle(
                          fontFamily: poppinsRegular,
                        ),
                      ),
                    ],
                  ),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child:
              Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    5.ph,
                    Text(
                      "#${pastSummaryList[index].uniqueId}",
                      style: const TextStyle(
                        fontFamily: poppinsMedium,
                      ),
                    ),
                    3.ph,
                    Text(
                      "Total Amount - ${pastSummaryList[index].totalAmount}",
                      style: TextStyle(
                        fontFamily: 'PoppinsRegular',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                )
            ),
                15.ph,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BookingPageNew(uniqueId: pastSummaryList[index].uniqueId ?? 1,navigatePage: "upcoming",)),
                            );
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
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text("No upcoming bookings found"),
      );
    }
  }

  Widget buildAllBookings() {
    if (summaryList.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        itemCount: summaryList.length,
        itemBuilder: (context, index) {
          DateTime parsedEndDateTime = DateTime.parse(summaryList[index].bookingDateTime.toString());
          String formattedEndDate = DateFormat('dd MMMM, yyyy').format(parsedEndDateTime);
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
                        formattedEndDate,
                        style: const TextStyle(
                          fontFamily: poppinsRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child:
                  Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    5.ph,
                    Text(
                      "#${summaryList[index].uniqueId}",
                      style: const TextStyle(
                        fontFamily: poppinsMedium,
                      ),
                    ),
                    3.ph,
                    Text(
                      "Total Amount - ${summaryList[index].totalAmount}",
                      style: TextStyle(
                        fontFamily: 'PoppinsRegular',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ),
                15.ph,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BookingPageNew(uniqueId: summaryList[index].uniqueId ?? 1,navigatePage: "all",)),
                            );
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
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text("No bookings found"),
      );
    }
  }
}
