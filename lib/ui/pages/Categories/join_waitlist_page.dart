import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/image_constants.dart';
import '../../../core/constants/shared_preferences_utils.dart';
import '../../../core/constants/static_words.dart';
import '../../../core/utils/size_utils.dart';
import '../../../network/base_url.dart';

class JoinWaitlistPage extends StatefulWidget {
  JoinWaitlistPage({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.productName,
    required this.price,
  });
  int id;
  String imageUrl;
  String productName;
  String price;

  @override
  State<JoinWaitlistPage> createState() => _JoinWaitlistPageState();
}

class _JoinWaitlistPageState extends State<JoinWaitlistPage> {
  DateTime? startDate;
  DateTime? endDate;
  String startFormattedDate = "";
  String endFormattedDate = "";

  Future<Map<String, dynamic>> addWaitlistPostApi() async {
    var responseData;
    String formatStartDate = "";
    String formatEndDate = "";
    String token = await getToken();
    if (startDate != null && endDate != null) {
      // Convert string to DateTime object
      DateTime originalStartDate = DateTime.parse(startDate.toString());
      DateTime originalEndDate = DateTime.parse(endDate.toString());

      // Format the DateTime object as required
      formatStartDate = DateFormat('yyyy-MM-dd').format(originalStartDate);
      formatEndDate = DateFormat('yyyy-MM-dd').format(originalEndDate);
    }

    String reqParam = jsonEncode(
      {
        "start_date": formatStartDate,
        "end_date": formatEndDate,
      },
    );

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.addWaitlist}/${widget.id}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 201) {
        printMsgTag(
            "addWaitlistPostApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("addWaitlistPostApi catch", exception.toString());
    }
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    if (startDate != null && endDate != null) {
      // Convert string to DateTime object
      DateTime originalStartDate = DateTime.parse(startDate.toString());
      DateTime originalEndDate = DateTime.parse(endDate.toString());

      // Format the DateTime object as required
      startFormattedDate = DateFormat('dd MMM yyyy').format(originalStartDate);
      endFormattedDate = DateFormat('dd MMM yyyy').format(originalEndDate);
    }
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: PrimaryColors().black900,
              size: 20,
            ),
          ),
          title: const Text("Join wait list"),
        ),
        body: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 15,
                    leading: Container(
                      width: 64,
                      height: 84,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.imageUrl,
                            // waitlistList[index].
                          ),
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
                          widget.productName,
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
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            10.pw,
                            Text(
                              'KD ${widget.price}',
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
                  ),
                  30.ph,
                  const Text(
                    'Select event dates',
                    style: TextStyle(
                      color: Color(0xFF595959),
                      fontSize: 12,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  10.ph,
                  GestureDetector(
                    onTap: () async {
                      final result = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (result != null) {
                        setState(() {
                          startDate = result.start;
                          endDate = result.end;
                        });

                        printMsgTag("startDate", startDate);
                        printMsgTag("endDate", endDate);
                      }
                    },
                    child: Card(
                      surfaceTintColor: Colors.transparent,
                      color: Colors.transparent,
                      elevation: 0.0,
                      margin: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFF6F6F6),
                                  shape: CircleBorder(),
                                ),
                                child: Center(
                                  child: Image.asset(ImageConstant.calendar),
                                ),
                              ),
                              10.pw,
                              Text(
                                // '29 Jan 2023 - 31 Jan 2023',
                                startFormattedDate.isNotEmpty &&
                                        endFormattedDate.isNotEmpty
                                    ? '$startFormattedDate - $endFormattedDate'
                                    : "Start Date - End Date",
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: poppinsRegular,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                helpText: "Title",
                              );
                              if (result != null) {
                                setState(() {
                                  startDate = result.start;
                                  endDate = result.end;
                                });

                                printMsgTag("startDate", startDate);
                                printMsgTag("endDate", endDate);
                              }
                            },
                            child: Image.asset("assets/icons/chevron-left.png"),
                          )
                        ],
                      ),
                    ),
                  ),
                  20.ph,
                ],
              ),
            ),
            addToCartButtonWidget(context),
          ],
        ));
  }

  Widget addToCartButtonWidget(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          width: width,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            // color: isAddToCart ? Colors.lightGreen : Colors.white,
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
              if (startFormattedDate.isNotEmpty &&
                  endFormattedDate.isNotEmpty) {
                addWaitlistPostApi().then((value) {
                  if (value['id'] != null) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Container(
                            width: width,
                            height: 290,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: SvgPicture.asset(
                                        ImageConstant.cancel,
                                        color: PrimaryColors().black900,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 60,
                                    color: Colors.green,
                                  ),
                                  5.ph,
                                  const Text(
                                    'Request created successfully!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 24,
                                      fontFamily: serifRegular,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  10.ph,
                                  Text(
                                    "We will get back to you soon. it takes 2-3 business days to evaluate your request",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontFamily: serifRegular,
                                      // height: 1.1,
                                    ),
                                  ),
                                  20.ph,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MaterialButton(
                                          onPressed: () {
                                            // Navigator.pop(context);
                                            navigateReplaceAll(
                                                context,
                                                BottomNavigationBarScreen(
                                                    selectedIndex: 3));
                                          },
                                          height: 45,
                                          color: const Color(0xFF2A9DA0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(36)),
                                          child: Text(
                                            'got it!'.toUpperCase(),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ).then((value) {
                      setState(() {});
                    });
                  }
                });
              } else {
                ModelUtils.showSimpleAlertDialog(
                  context,
                  title: const Text("Happy Bash"),
                  content: "Please select event dates",
                  okBtnFunction: () => Navigator.pop(context),
                );
              }
            },
            color: const Color(0xFF2A9DA0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
            child: Text(
              'create request'.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: poppinsSemiBold,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          )),
    );
  }
}
