import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/get_bookings_model.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/navigator.dart';
import '../../../core/constants/shared_preferences_utils.dart';
import '../../../network/base_url.dart';
import '../../screen/bottom_navigation_screen.dart';
import '../Categories/detail_page.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class BookingDetailsPage extends StatefulWidget {
  BookingDetailsPage({
    super.key,
    required this.bookingList,
    required this.dates,
    required this.navigatePage,
  });

  GetBookingsModel bookingList;
  String dates;
  String navigatePage;

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  double deliveryCharges = 0.0;
  double totalAmount = 0.0;
  double amountWithShipping = 0.0;
  bool isLoading = false;

  Future<Map<String, dynamic>> deleteBookingApi(int bookingId) async {
    var responseData;
    String token = await getToken();

    final jsonResponse = await http.delete(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.booking}/$bookingId"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("deleteBookingApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("deleteBookingApi catch", exception.toString());
    }
    return responseData;
  }

  Future<Map<String, dynamic>> deleteBookingApiNew(int bookingId) async {
    String token = await getToken();
    String reqParam = jsonEncode({
      "booking_id": bookingId,
    });

    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.cancelBooking}"),
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

  Future<void> fetchAndHandlePdf(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      String token = await getToken();

      final response = await http.get(
        Uri.parse(
            "${BaseUrl.globalUrl}/${BaseUrl.bookingInvoice}?unique_id=${widget.bookingList.uniqueId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/pdf",
        },
      );

      if (response.statusCode == 200) {
        Uint8List pdfData = response.bodyBytes;
        _showOptions(context, pdfData);
      } else {
        throw Exception("Failed to fetch PDF");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showOptions(BuildContext context, Uint8List pdfData) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text("View PDF"),
              onTap: () => _viewPdf(context, pdfData),
            ),
            // ListTile(
            //   leading: Icon(Icons.download),
            //   title: Text("Download PDF"),
            //   onTap: () => _downloadPdf(context, pdfData),
            // ),
          ],
        );
      },
    );
  }

  void _viewPdf(BuildContext context, Uint8List pdfData) async {
    final directory = await getTemporaryDirectory();
    final filePath = "${directory.path}/invoice.pdf";
    final file = File(filePath);
    await file.writeAsBytes(pdfData);
    OpenFile.open(filePath);
  }

  void _downloadPdf(BuildContext context, Uint8List pdfData) async {
    // try {
    //   DocumentFileSavePlus.saveFile(pdfData, "invoice.pdf", "appliation/pdf");
    // } catch (e) {
    //   print(e);
    // }

    // final status = await Permission.storage.request();
    // if (status.isGranted) {
    //   final directory = await getExternalStorageDirectory();
    //   final filePath = "${directory!.path}/downloaded_file.pdf";
    //   final file = File(filePath);
    //   await file.writeAsBytes(pdfData);
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("PDF downloaded to: $filePath")),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Storage permission denied")),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = double.parse(widget.bookingList.totalBookingAmount.toString());
    try {
      amountWithShipping = double.parse(widget.bookingList.totalBookingAmount.toString()) + double.parse(widget.bookingList.shippingCharges.toString());
    } catch (e) {
      amountWithShipping = double.parse(widget.bookingList.totalBookingAmount.toString());
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Booking details",
              style: TextStyle(
                fontFamily: poppinsSemiBold,
                fontSize: 15,
              ),
            ),
            Text(
              widget.dates,
              style: const TextStyle(
                fontFamily: poppinsRegular,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A9DA0)),
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      20.ph,
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
                          Text(
                            "${widget.bookingList.products!.length.toString()} Products",
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontFamily: serifRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      10.ph,
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.bookingList.products!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(color: Colors.grey.shade300);
                        },
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 15,
                            leading: Container(
                              width: 64,
                              height: 84,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.bookingList.products![index].image
                                        .toString(),
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
                                  widget.bookingList.products![index].name
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
                                    if (widget.bookingList.products![index]
                                            .pivot?.price !=
                                        null)
                                      Text(
                                        'KD ${widget.bookingList.products![index].pivot?.price.toString()}${widget.bookingList.products![index].priceType == "price_per_day" ? " per day" : ""}',
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 16,
                                          fontFamily: 'PoppinsRegular',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                                if (widget.bookingList.products![index].pivot
                                        ?.color !=
                                    null)
                                  Row(
                                    children: [
                                      Text(
                                        "Color - ${widget.bookingList.products![index].pivot?.color}",
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      5.ph,
                                      // Assumes ph is a predefined extension or method on double for padding or margin.
                                    ],
                                  ),
                                if (widget.bookingList.products![index].pivot
                                        ?.size !=
                                    null)
                                  Row(
                                    children: [
                                      Text(
                                        "Size - ${widget.bookingList.products![index].pivot?.size}",
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      // Include any additional widgets or logic here
                                    ],
                                  ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                const Text("Quantity: "),
                                Text(
                                  widget.bookingList.products![index].pivot!
                                      .quantity
                                      .toString(),
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.bookingList.products![index]
                                            .addons !=
                                        null &&
                                    widget.bookingList.products![index].addons!
                                        .isNotEmpty) ...[
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
                                  for (var addon in widget.bookingList
                                      .products![index].addons!) ...[
                                    Container(
                                      // padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            addon.name ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade900,
                                              fontFamily: poppinsRegular,
                                            ),
                                          ),
                                          Text(
                                            'KD ${addon.price ?? '0.0'}',
                                            // Format price here, adjust currency symbol as needed
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
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      20.ph,
                      Column(
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
                          if(widget.bookingList.checkoutType == "Waiting for confirmation")
                            Column(children: [
                            10.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  widget.bookingList.totalBookingAmount
                                      .toString(),
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                              ],
                            ),
                            10.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  widget.bookingList.shippingCharges
                                      .toString(),
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                              ],
                            ),
                            10.ph,
                            Divider(color: Colors.grey.shade300),
                            5.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Total amount",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontFamily: poppinsMedium,
                                  ),
                                ),
                                Text(
                                  // "KD 170.000",
                                  amountWithShipping.toStringAsFixed(3),
                                  style: const TextStyle(
                                    fontFamily: poppinsSemiBold,
                                  ),
                                ),
                              ],
                            ),
                            5.ph,
                          ])
                          else
                            Column(children: [
                            5.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Total amount",
                                  style: TextStyle(
                                    fontFamily: poppinsBold,
                                  ),
                                ),
                                Text(
                                  // "KD 160.000",
                                  "KD ${totalAmount.toStringAsFixed(3)}",
                                  style: const TextStyle(
                                    fontFamily: poppinsBold,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ],
                      ),
                      10.ph,
                    ],
                  ),
                ),
                bottomButtonWidget(context),
              ],
            ),
    );
  }

  Widget bottomButtonWidget(BuildContext context) {
    return Align(
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
        child: Row(
          children: [
            Expanded(
              child: widget.navigatePage == 'all'
                  ? MaterialButton(
                      onPressed: () {
                        fetchAndHandlePdf(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                          side: const BorderSide(
                            color: Color(0xFF2A9DA0),
                          )),
                      child: Text(
                        'get invoice'.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2A9DA0),
                          fontSize: 14,
                          fontFamily: poppinsSemiBold,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  : MaterialButton(
                      onPressed: () {
                        if (widget.bookingList.status != "canceled") {
                          ModelUtils.showCustomAlertDialog(
                            context,
                            title: "Cancel Booking",
                            content: const Text(
                                "Are you sure want to cancel booking"),
                            okBtnFunction: () {
                              deleteBookingApiNew(widget.bookingList.id!)
                                  .then((value) {
                                if (value['message'] ==
                                    "Booking Canceled successfully") {
                                  showSnackBar(context, value['message']);
                                  Navigator.pop(context);
                                  navigateReplaceAll(
                                      context,
                                      BottomNavigationBarScreen(
                                          selectedIndex: 0));
                                }
                              });
                            },
                          );
                        } else {
                          ModelUtils.showCustomAlertDialog(
                            context,
                            title: "Cancel Booking",
                            content: const Text("Booking already canceled"),
                            okBtnFunction: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        // Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                          side: const BorderSide(
                            color: Color(0xFF2A9DA0),
                          )),
                      child: Text(
                        'cancel booking'.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2A9DA0),
                          fontSize: 14,
                          fontFamily: poppinsSemiBold,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
            ),
            15.pw,
            Expanded(
              child: widget.navigatePage == "all"
                  ? MaterialButton(
                      onPressed: () {
                        navigateAddScreen(
                            context,
                            DetailPage(
                                productId:
                                    widget.bookingList.products![0].id!));
                      },
                      color: const Color(0xFF2A9DA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Text(
                        'book again'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: poppinsSemiBold,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  : MaterialButton(
                      onPressed: () {
                        fetchAndHandlePdf(context);
                      },
                      color: const Color(0xFF2A9DA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Text(
                        'get invoice'.toUpperCase(),
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
      ),
    );
  }
}
