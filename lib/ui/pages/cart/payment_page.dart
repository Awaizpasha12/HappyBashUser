import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/dialog_box.dart';
import '../../../core/constants/shared_preferences_utils.dart';
import '../../../core/constants/static_words.dart';
import '../../../models/get_address_model.dart';
import '../../../network/base_url.dart';
import '../../../models/get_cart_model.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage(
      {super.key,
      required this.addressId,
      required this.selectedValue,
      required this.getCartModel,
      required this.getAddressModel});

  int addressId;
  int selectedValue;
  final GetCartModel getCartModel;
  final GetAddressModel getAddressModel;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _showPaymentButton = true;
  bool _showWebView = false;
  bool _isLoading = false;
  String? _webViewLink;
  String startFormattedDate = "";
  String endFormattedDate = "";

  double toBePaidNow = 0.0;
  double totalAmount = 0.0;
  double deliveryCharges = 0.0;

  Future<Map<String, dynamic>> checkoutPostApi() async {
    setState(() {
      _isLoading = true;
    });
    var responseData;
    String token = await getToken();
    String reqParam = jsonEncode(
      {
        "address_id": widget.addressId.toString(),
        //"checkout_type":widget.selectedValue == 1 ? "Available" : (widget.selectedValue == 2) ?"Waiting for confirmation" : "Depending on time"
      },
    );

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.checkout}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: reqParam,
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("checkoutPostApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        if (responseData['message'] != null &&
            responseData['message'] == "Checkout successful") {
          ModelUtils.showSimpleAlertDialog(
            context,
            title: Text(
              "Payment and Order Successful",
              style: TextStyle(color: PrimaryColors().primarycolor),
            ),
            content:
                "Your payment was successful and your order has been placed successfully",
            okBtnFunction: () {
              navigateReplaceAll(
                  context, BottomNavigationBarScreen(selectedIndex: 0));
            },
          );
        } else {
          String link = responseData['data']['link'];
          setState(() {
            _showPaymentButton = false;
            _showWebView = true;
            _isLoading = false;
            _webViewLink = link;
          });
        }
        return responseData;
      } else {
        responseData = jsonDecode(jsonResponse.body.toString());
        var msg = responseData["message"] ??
            "Something went wrong please try after sometime";
        ModelUtils.showSimpleAlertDialog(
          context,
          title: const Text("Processing Error"),
          content: msg,
          okBtnFunction: () => Navigator.pop(context),
        );
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("checkoutPostApi catch", exception.toString());
      setState(() {
        _isLoading = false;
      });
    }
    return responseData;
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   checkoutPostApi();
  // }
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
                          color: Colors.redAccent,
                          fontFamily: poppinsRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                20.ph,
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (_showWebView && _webViewLink != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: WebView(
                      initialUrl: _webViewLink!,
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageStarted: (String url) {
                        if (url.contains('payment-response')) {
                          Uri uri = Uri.parse(url);
                          String? result = uri.queryParameters['result'];
                          if (result == 'CAPTURED') {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _showWebView = false;
                                _showPaymentButton = true;
                              });
                              ModelUtils.showSimpleAlertDialog(
                                context,
                                title: Text(
                                  "Payment and Order Successful",
                                  style: TextStyle(
                                      color: PrimaryColors().primarycolor),
                                ),
                                content:
                                    "Your payment was successful and your order has been placed successfully",
                                okBtnFunction: () {
                                  navigateReplaceAll(
                                      context,
                                      BottomNavigationBarScreen(
                                          selectedIndex: 0));
                                },
                              );
                            });
                          } else if (result != 'CAPTURED') {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ModelUtils.showSimpleAlertDialog(
                                context,
                                title: Text(
                                  "Payment Failed",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                content:
                                    "The payment process failed. Please try again or contact support if the issue persists.",
                                okBtnFunction: () {
                                  Navigator.pop(context);
                                },
                              );
                            });
                          }
                        } else if (url.contains('payment-cancel')) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _showWebView = false;
                              _showPaymentButton = true;
                            });
                            ModelUtils.showSimpleAlertDialog(
                              context,
                              title: Text(
                                "Payment Cancelled",
                                style: TextStyle(
                                    color: PrimaryColors().primarycolor),
                              ),
                              content:
                                  "The payment process has been cancelled. If you wish to proceed, please start again.",
                              okBtnFunction: () {
                                navigateReplaceAll(
                                    context,
                                    BottomNavigationBarScreen(
                                        selectedIndex: 0));
                              },
                            );
                          });
                        }
                      },
                      navigationDelegate: (NavigationRequest request) {
                        return NavigationDecision.navigate;
                        // if (request.url.contains('payment-response') || request.url.contains('payment-cancel')) {
                        //   return NavigationDecision.navigate;
                        // }
                        // return NavigationDecision.prevent;
                      },
                    ),
                  )
                else
                  buildDetailUi(),
              ],
            ),
          ),
          if (_showPaymentButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width,
                height: 60,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                    checkoutPostApi();
                  },
                  color: const Color(0xFF2A9DA0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36)),
                  child: Text(
                    'Initiate Payment',
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
            ),
        ],
      ),
    );
  }

  buildDetailUi() {
    // if (snapshot.hasData) {
    //   widget.getCartModel = snapshot.data!;
    if (widget.getCartModel.cart != null) {
      if (widget.getCartModel.cart!.cartItems!.isNotEmpty) {
        var cartItems = widget.getCartModel.cart!.cartItems;
        String toBePaidNowNew = widget.getCartModel.toBePaidNow ?? "0";
        String totalAmountNew = widget.getCartModel.totalAmount ?? "0";
        String deliveryChargesNew = widget.getCartModel.shippingCharges ?? "0";
        String totalNew = widget.getCartModel.total ?? "0";
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  10.ph,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
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
                              'Order summary',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: serifRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  20.ph,
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.grey.shade300,
                        thickness: 0.7,
                      );
                    },
                    itemBuilder: (context, index) {
                      if (cartItems[index].startDate != null &&
                          cartItems[index].endDate != null) {
                        // Convert string to DateTime object
                        DateTime originalStartDate = DateTime.parse(
                            cartItems[index].startDate.toString());
                        DateTime originalEndDate =
                            DateTime.parse(cartItems[index].endDate.toString());

                        // Format the DateTime object as required
                        startFormattedDate =
                            DateFormat('dd MMM yyyy').format(originalStartDate);
                        endFormattedDate =
                            DateFormat('dd MMM yyyy').format(originalEndDate);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 65,
                                  height: 55,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: widget
                                            .getCartModel
                                            .cart!
                                            .cartItems![index]
                                            .product!
                                            .images!
                                            .isEmpty
                                        ? Container(
                                            width: 65,
                                            height: 55,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Text(
                                                "No image\nfound",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Image.network(
                                            // "assets/images/sofaFullview.png",
                                            widget
                                                .getCartModel
                                                .cart!
                                                .cartItems![index]
                                                .product!
                                                .images![0]
                                                .imageUrl
                                                .toString(),
                                            fit: BoxFit.fill,
                                          ),
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
                          ],
                        ),
                      );
                    },
                  ),
                  20.ph,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
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
                              "KD $totalNew",
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
                              "KD $deliveryChargesNew",
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
                        Divider(color: Colors.grey.shade300),
                        5.ph,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                  20.ph,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
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
                              'Order will be delivered to',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: serifRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  20.ph,
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Street: ",
                              style: TextStyle(
                                fontFamily: poppinsSemiBold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.getAddressModel.street ?? "",
                                style: const TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "State: ",
                              style: TextStyle(
                                fontFamily: poppinsSemiBold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.getAddressModel.state ?? "",
                                style: const TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "City: ",
                              style: TextStyle(
                                fontFamily: poppinsSemiBold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.getAddressModel.city ?? "",
                                style: const TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "Postal Code: ",
                              style: TextStyle(
                                fontFamily: poppinsSemiBold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.getAddressModel.postalCode ?? "",
                                style: const TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      }
    }
    return const CustomProgressBar();
  }
}
