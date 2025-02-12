import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/models/add_to_cart_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/Categories/join_waitlist_page.dart';
import 'package:happy_bash/ui/pages/cart/cart_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/image_constants.dart';
import '../../../models/product_detail_model.dart';
import '../../screen/login_screen.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key, required this.productId}) : super(key: key);
  int productId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late ProductDetailModel productDetailModel;
  bool isLoading = true;
  late SharedPreferences prefs;
  int colorindex = 0;
  bool isAddToCart = false;
  int quantity = 1;
  DateTime? startDate;
  DateTime? endDate;
  String startFormattedDate = "";
  String endFormattedDate = "";
  String startTime = "";
  String endTime = "";
  List<String> favoriteDataList = [];
  List<Addon> selectedAddonList = [];
  ColorsNew? selectedColor;
  Sizes? selectedSize;
  int? productVariationId;
  String notAvailableButtonText = "Variation unavailable";
  void productDetailGetApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    prefs = await SharedPreferences.getInstance();
    String token = await getToken();
    int productId = widget.productId;
    favoriteDataList = await futuregetFavouriteId();
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.products}/$productId"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        // "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());

    try {
      if (response.statusCode == 200) {
        printMsgTag("productDetailGetApi ResponseData", responseData);
        productDetailModel =  ProductDetailModel.fromJson(responseData);
        if(productDetailModel.productType == "Variation") {
          if(responseData["default_variation"] != null) {
            //if it is variation then update the data
            if (responseData["default_variation"]["id"] != null) {
              productVariationId = responseData["default_variation"]["id"];
            }
            if (responseData["default_variation"]["price"] != null) {
              productDetailModel.pricePerDay = responseData["default_variation"]["price"];
            }
            if (responseData["default_variation"]["available_quantity"] != null) {
              productDetailModel.availableQuantity =
              responseData["default_variation"]["available_quantity"];
            }
            if (responseData["default_variation"]['images'] != null) {
              var images = <Images>[];
              responseData["default_variation"]['images'].forEach((v) {
                images!.add(Images.fromJson(v));
              });
              productDetailModel.images = images;
            }
            if(responseData["default_variation"]["color"] != null){
              selectedColor = responseData["default_variation"]["color"] != null
                  ? ColorsNew.fromJson(responseData["default_variation"]["color"])
                  : null;
            }
            if(responseData["default_variation"]["size"] != null){
              selectedSize = responseData["default_variation"]["size"] != null
                  ? Sizes.fromJson(responseData["default_variation"]["size"])
                  : null;
            }
          }
        }
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("productDetailGetApi catch", exception.toString());
    }

    // productDetailModel =  ProductDetailModel.fromJson(responseData);
    isLoading = false;
    setState(() {
      productDetailModel;
      isLoading;
      selectedColor;
      selectedSize;
    });
  }
  bool showPrice(){
    if(productDetailModel.productType == "Variation" && productVariationId == null){
      return false;
    }
    return true;
  }
  bool validateAndProceed() {
    List<Sizes> sizes = productDetailModel.sizes ?? []; // Assuming this list is populated elsewhere
    List<ColorsNew> colorsNew = productDetailModel.colors ?? []; // Assuming this list is populated elsewhere

    // Check if selectedSize is selected
    bool isSizeSelected = selectedSize != null;

    // Check if productVariationId is selected
    bool isColorSelected = selectedColor != null;

    // Validation logic
    if ((isSizeSelected && colorsNew.isEmpty) ||
        (isColorSelected && sizes.isEmpty) ||
        (isSizeSelected && isColorSelected)) {
      return true;
    }
    return false;
  }

  void checkForAvailablilityAndUpdate() async {
    //here first check if they have selected both
   // var proceed = validateAndProceed();
   // if(!proceed) {
   //   return;
   // }
   setState(() {
     isLoading = true;
   });
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    int productId = widget.productId;
    String reqParam = jsonEncode({
      "product_id": productId,
      "size_id" : (selectedSize?.id ?? "").toString(),
      "color_id":(selectedColor?.id ?? "").toString()
    });
    var querPar = "?product_id=${productId}&size_id=${(selectedSize?.id ?? "").toString()}&color_id=${(selectedColor?.id ?? "").toString()}";
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.productVariation}$querPar"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());

    try {
      // if(responseData.length > 0) {
      if(response.statusCode == 200) {
        printMsgTag("productDetailGetApi ResponseData", responseData);
        if (responseData["id"] != null) {
          productVariationId = responseData["id"];
        }
        if (responseData["price"] != null) {
          productDetailModel.pricePerDay = responseData["price"];
        }
        if (responseData["available_quantity"] != null) {
          productDetailModel.availableQuantity = responseData["available_quantity"];
        }
        if (responseData['images'] != null) {
          var images = <Images>[];
          responseData['images'].forEach((v) {
            images!.add(Images.fromJson(v));
          });
          productDetailModel.images = images;
          isLoading = false;
          setState(() {
            productDetailModel;
            isLoading;
          });
        }
      }
      else {
        productVariationId = null;
        productDetailModel.pricePerDay = null;
        productDetailModel.availableQuantity = null;
        productDetailModel.images = [];
        notAvailableButtonText = responseData["message"] ?? "Variation unavailable";
        // ModelUtils.showSimpleAlertDialog(
        //   context,
        //   title: const Text("Variation Alert"),
        //   content: responseData["message"] ?? "Selected variation is not available",
        //   okBtnFunction: () => Navigator.pop(context),
        // );
        setState(() {
          isLoading = false;
        });
      }
    } catch (exception) {
      printMsgTag("productDetailGetApi catch", exception.toString());
    }

  }
  Future<AddToCartModel> addToCartPostApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    int productId = widget.productId;
    DateTime originalStartDate = DateTime.parse(startDate.toString());
    DateTime originalEndDate = DateTime.parse(endDate.toString());

    // Add three days to the current date
    // DateTime dateAfterThreeDays = current.add(const Duration(days: 3));

    // Format the date as 'yyyy-MM-dd'
    String startDateEvt = DateFormat('yyyy-MM-dd').format(originalStartDate);
    String endDateEvt = DateFormat('yyyy-MM-dd').format(originalEndDate);

    // String reqParam = jsonEncode(
    //   {
    //     "product_id": productId,
    //     "quantity": quantity,
    //     "start_date": startDateEvt,
    //     "end_date": endDateEvt,
    //     "start_time": startTime,
    //     "end_time": endTime,
    //     "vendor_id":productDetailModel.vendorId ?? 0
    //   },
    // );
    Map<String, dynamic> reqParamMap = {
      "product_id": productId,
      "quantity": quantity,
      "start_date": startDateEvt,
      "end_date": endDateEvt,
      "start_time": startTime,
      "end_time": endTime,
      "vendor_id": productDetailModel.vendorId ?? 0,
      "addons": selectedAddonList.map((addon) {
        return {
          "id": addon.id,
          "productId": addon.productId,
          "name": addon.name,
          "price": addon.price,
        };
      }).toList(),
    };

    if (productVariationId != null) {
      reqParamMap["product_variation_id"] = productVariationId;
    }

    final selectedSize = this.selectedSize;
    if(selectedSize != null){
      reqParamMap["size_id"] = selectedSize.id ?? "";
    }
    final selectedColor = this.selectedColor;
    if(selectedColor != null){
      reqParamMap["color_id"] = selectedColor.id;
    }
    String reqParam = jsonEncode(reqParamMap);


    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.addToCart}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: reqParam,
    );
    var responseData = jsonDecode(response.body.toString());

    try {
      if (response.statusCode == 200) {
        printMsgTag("addToCartPostApi ResponseData", responseData);
        return AddToCartModel.fromJson(responseData);
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("addToCartPostApi catch", exception.toString());
    }

    return AddToCartModel.fromJson(responseData);
  }

  Future<Map<String, dynamic>> addToWishlistPostApi(int productId) async {
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

    final jsonResponse = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.addWishlist}/$productId"),
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
        printMsgTag(
            "addToWishlistPostApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("addToWishlistPostApi catch", exception.toString());
    }
    return responseData;
  }

  Future<Map<String, dynamic>> removeWishlistDeleteApi(int productId) async {
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
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.removeWishlist}/$productId"),
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
        printMsgTag(
            "removeWishlistDeleteApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("removeWishlistDeleteApi catch", exception.toString());
    }
    return responseData;
  }

  @override
  void initState() {
    super.initState();
    productDetailGetApi();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            )),
      ),
      body: isLoading
          ? const CustomProgressBar()  // Show progress bar when data is loading
          : fullBodyWidget(context),


      // body: FutureBuilder<ProductDetailModel>(
      //     future: productDetailGetApi(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         productDetailModel = snapshot.data!;
      //         return fullBodyWidget(context);
      //       }
      //       return const CustomProgressBar();
      //     }),
    );
  }

  Widget fullBodyWidget(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              //-------------- product header images --------------//
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  initialPage: 0,
                  height: 400,
                ),
                items: productDetailModel.images!.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.network(
                          image.imageUrl.toString(),
                          width: width,
                          height: 400,
                          fit: BoxFit.fitWidth,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              //-------------- product body details --------------//
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                  decoration: BoxDecoration(
                    color: PrimaryColors().white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      productDetailsWidget(),
                      // reviewsWidget(),
                      // 24.ph,
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Divider(),
                      // ),
                      // 24.ph,
                      // recommendProductWidget(),
                      // Container(
                      //   width: width,
                      //   height: 98,
                      //   decoration:
                      //       const BoxDecoration(color: Color(0xFFEBF7DE)),
                      // )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        //-------------- product bottom add to cart button --------------//
        addToCartButtonWidget(context)
      ],
    );
  }

  Column recommendProductWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
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
                'People also loved these products',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: serifRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        24.ph,
        SizedBox(
          height: 266,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {},
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  elevation: 0.0,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 240,
                        height: 140,
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: NetworkImage(
                                "https://via.placeholder.com/240x140"),
                            fit: BoxFit.fill,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      12.ph,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Curved sofa',
                              style: TextStyle(
                                color: Color(0xFF1D2939),
                                fontSize: 18,
                                fontFamily: serifRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            8.ph,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(ImageConstant.star),
                                2.pw,
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '4.2',
                                        style: TextStyle(
                                          color: Color(0xFFE38E31),
                                          fontSize: 14,
                                          fontFamily: poppinsSemiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' (21) • 1K+ booked',
                                        style: TextStyle(
                                          color: Color(0xFF595959),
                                          fontSize: 14,
                                          fontFamily: poppinsMedium,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            8.ph,
                            Row(
                              children: [
                                const Text(
                                  'KD 120.00',
                                  style: TextStyle(
                                    color: Color(0xFF9B9B9B),
                                    fontSize: 14,
                                    fontFamily: poppinsRegular,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                10.pw,
                                const Text(
                                  'KD 80.00',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                    fontFamily: poppinsBold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Text(
                                  ' per day',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: poppinsRegular,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget addToCartButtonWidget(BuildContext context) {
    // if(!getIsUserLogin(prefs)){
    //   return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         SvgPicture.asset(ImageConstant.noBooking),
    //         const SizedBox(height: 20),
    //         MaterialButton(
    //           onPressed: () {
    //             navigateReplaceAll(context, const LoginScreen());
    //           },
    //           color: PrimaryColors().primarycolor,
    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    //           child: Text(
    //             "Login to see booking".toUpperCase(),
    //             style: TextStyle(color: PrimaryColors().white, fontFamily: poppinsSemiBold),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    if (productDetailModel.productType == "Variation" && productVariationId == null) {
      var buttonText = "Select size and color";
      if (selectedColor != null || selectedSize != null) {
        buttonText = notAvailableButtonText;
      }
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width, // Use MediaQuery for width
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Light grey color to indicate inactivity
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
          child: Center(
            child: MaterialButton(
              onPressed: null, // Button is inactive
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36)
              ),
              child: Text(buttonText,
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
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isAddToCart ? Colors.lightGreen : Colors.white,
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
        // child: productDetailModel.availableQuantity! <= 0
        child: (productDetailModel.availableQuantity ?? 1)  <= 0
            ? MaterialButton(
                onPressed: () {
                  // navigateAddScreen(
                  //     context,
                  //     JoinWaitlistPage(
                  //       id: productDetailModel.id!,
                  //       imageUrl:
                  //           productDetailModel.images![0].imageUrl.toString(),
                  //       productName: productDetailModel.name.toString(),
                  //       price: productDetailModel.pricePerDay.toString(),
                  //     ));
                },
                color: const Color(0xFF2A9DA0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36)),
                child: Text(
                  'Join Wait list'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: poppinsSemiBold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              )
            : isAddToCart == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                            5.pw,
                            const Flexible(
                              child: Text(
                                "Added to the cart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: poppinsSemiBold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      20.pw,
                      Expanded(
                        child: MaterialButton(
                          onPressed: () =>
                              navigateAddScreen(context, const CartPage()),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36)),
                          child: Text(
                            'View Cart'.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2A9DA0),
                              fontSize: 14,
                              fontFamily: poppinsSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : MaterialButton(
                    onPressed: () {
                      if (!getIsUserLogin(prefs)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Login Required"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(ImageConstant.noBooking),
                                  const SizedBox(height: 20),
                                  MaterialButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      navigateReplaceAll(context, const LoginScreen());
                                    },
                                    color: PrimaryColors().primarycolor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50)),
                                    child: Text(
                                      "Login to see booking".toUpperCase(),
                                      style: TextStyle(
                                          color: PrimaryColors().white,
                                          fontFamily: poppinsSemiBold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      else {
                        bookingOptions(context).then((value) {
                          setState(() {});
                        });
                      }
                    },
                    color: const Color(0xFF2A9DA0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36)),
                    child: Text(
                      'ADD TO CART'.toUpperCase(),
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
    );
  }

  Future<dynamic> bookingOptions(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                width: width,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- header section ---------------- //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Booking options',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 24,
                              fontFamily: serifRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              ImageConstant.cancel,
                              color: PrimaryColors().black900,
                            ),
                          )
                        ],
                      ),
                      10.ph,
                      // ---------------- select event date ---------------- //
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                startDate = result.start;
                                endDate = result.end;
                                if (startDate != null && endDate != null) {
                                  // Convert string to DateTime object
                                  DateTime originalStartDate =
                                  DateTime.parse(startDate.toString());
                                  DateTime originalEndDate =
                                  DateTime.parse(endDate.toString());

                                  // Format the DateTime object as required
                                  startFormattedDate = DateFormat('dd MMM yyyy')
                                      .format(originalStartDate);
                                  endFormattedDate = DateFormat('dd MMM yyyy')
                                      .format(originalEndDate);
                                }
                                setState(() {});

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
                                          child:
                                          Image.asset(ImageConstant.calendar),
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
                                  Image.asset("assets/icons/chevron-left.png")
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      5.ph,
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      10.ph,
                      // ---------------- select event time ---------------- //
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select event time',
                            style: TextStyle(
                              color: Color(0xFF595959),
                              fontSize: 12,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          10.ph,
                          GestureDetector(
                            onTap: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 270,
                                    color: PrimaryColors().white,
                                    child: Column(
                                      children: [
                                        CupertinoTimerPicker(
                                          mode: CupertinoTimerPickerMode.hm,
                                          initialTimerDuration: const Duration(
                                              hours: 0, minutes: 0),
                                          onTimerDurationChanged: (value) {
                                            printMsgTag("Select events time",
                                                value.inHours);
                                            // value.inHours
                                            setState(() {
                                              int minutes = value.inMinutes -
                                                  (value.inHours * 60);
                                              int hours = value.inHours;
                                              if (hours < 10 && minutes < 10) {
                                                startTime = "0$hours:0$minutes";
                                                if(hours + 1 == 10){
                                                  endTime = "${(hours + 1) %
                                                      24}:0$minutes";
                                                }else {
                                                  endTime = "0${(hours + 1) %
                                                      24}:0$minutes";
                                                }
                                                printMsgTag("startTime", startTime);
                                              } else if (hours < 10 && minutes >= 10) {
                                                startTime = "0$hours:$minutes";
                                                endTime = "0${(hours + 1) % 24}:$minutes";
                                                printMsgTag("startTime", startTime);
                                              } else if (hours >= 10 && minutes < 10) {
                                                startTime = "$hours:0$minutes";
                                                endTime = "${(hours + 1) % 24}:0$minutes";
                                                printMsgTag("startTime", startTime);
                                              } else if (hours >= 10 && minutes >= 10) {
                                                startTime = "$hours:$minutes";
                                                endTime = "${(hours + 1) % 24}:$minutes";
                                                printMsgTag("startTime", startTime);
                                              }
                                            });
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: MaterialButton(
                                                  color: PrimaryColors()
                                                      .primarycolor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Done",
                                                    style: TextStyle(
                                                      color:
                                                      PrimaryColors().white,
                                                      fontFamily: poppinsSemiBold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
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
                                        child: const Center(
                                          child: Icon(
                                            Icons.access_time_outlined,
                                          ),
                                        ),
                                      ),
                                      10.pw,
                                      Text(
                                        // '29 Jan 2023 - 31 Jan 2023',
                                        startTime.isNotEmpty
                                            ? startTime
                                            : "Select Time",
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 14,
                                          fontFamily: poppinsRegular,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                  Image.asset("assets/icons/chevron-left.png")
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      5.ph,
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      10.ph,
                      // ---------------- select color ---------------- //
                      // if(productDetailModel.color != null && productDetailModel.color!.isNotEmpty)
                      //   Column(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text(
                      //         "Select colors",
                      //         style: TextStyle(
                      //           color: Colors.black87,
                      //           fontFamily: poppinsRegular,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //       5.ph,
                      //       SizedBox(
                      //         height: 50,
                      //         child: ListView.builder(
                      //           scrollDirection: Axis.horizontal,
                      //           itemCount: 1,  // Only one item in the list
                      //           itemBuilder: (context, index) {
                      //             return Padding(
                      //               padding: const EdgeInsets.all(4.0),
                      //               child: GestureDetector(
                      //                 onTap: () {
                      //                   setState(() {
                      //                     colorindex = index;
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                   padding: const EdgeInsets.all(3.0),
                      //                   decoration: BoxDecoration(
                      //                     shape: BoxShape.circle,
                      //                     border: Border.all(
                      //                       color: colorindex == index
                      //                           ? Colors.black54
                      //                           : Colors.transparent,
                      //                     ),
                      //                   ),
                      //                   child: CircleAvatar(
                      //                     radius: 15,
                      //                     backgroundColor:Color(int.parse((productDetailModel.color ?? "").replaceAll("#", "0xff"))),  // Hex color code for grey
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // 5.ph,
                      // if(productDetailModel.color != null && productDetailModel.color!.isNotEmpty)
                      //   Divider(
                      //     thickness: 1,
                      //     color: Colors.grey.shade300,
                      //   ),
                      // if(productDetailModel.size != null)
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text(
                      //       "Select Size",
                      //       style: TextStyle(
                      //         color: Colors.black87,
                      //         fontFamily: 'PoppinsRegular',
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //     SizedBox(height: 10),
                      //     Container(
                      //       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      //       decoration: BoxDecoration(
                      //         color: Colors.grey[200],
                      //         borderRadius: BorderRadius.circular(4),
                      //       ),
                      //       child: Text(
                      //         productDetailModel.size ?? "",
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontFamily: 'PoppinsRegular',
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      10.ph,
                      // ---------------- select quantity ---------------- //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Select quantity"),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              8.pw,
                              Text(quantity.toString()),
                              8.pw,
                              GestureDetector(
                                onTap: () {
                                  if(quantity < (productDetailModel.availableQuantity ?? 0)) {
                                    setState(() {
                                      quantity++;
                                    });
                                  }else{
                                    ModelUtils.showSimpleAlertDialog(context,
                                        title: const Text("Item Quantity"),
                                        content: "You cannot add more quantities than what is currently available.",
                                        okBtnFunction: () =>
                                            Navigator.pop(context));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      25.ph,
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                if (startFormattedDate.isNotEmpty &&
                                    endFormattedDate.isNotEmpty &&
                                    startTime.isNotEmpty) {
                                  // Check if checkOutType is "On time"
                                  // if (productDetailModel.checkOutType == "On time") {
                                  //   DateTime selectedStartDate = DateFormat('dd MMM yyyy').parse(startFormattedDate);
                                  //   DateTime selectedEndDate = DateFormat('dd MMM yyyy').parse(endFormattedDate);
                                  //
                                  //   DateTime? availableStartDate = productDetailModel.availableStartDate != null
                                  //       ? DateFormat('dd/MM/yyyy').parse(productDetailModel.availableStartDate!)
                                  //       : null;
                                  //   DateTime? availableEndDate = productDetailModel.availableEndDate != null
                                  //       ? DateFormat('dd/MM/yyyy').parse(productDetailModel.availableEndDate!)
                                  //       : null;
                                  //
                                  //   if (availableStartDate != null && availableEndDate != null) {
                                  //     if (selectedStartDate.isBefore(availableStartDate) || selectedEndDate.isAfter(availableEndDate)) {
                                  //       ModelUtils.showSimpleAlertDialog(
                                  //         context,
                                  //         title: const Text("Invalid Date"),
                                  //         content: "Selected dates must fall within the available range: ${DateFormat('dd MMM yyyy').format(availableStartDate)} to ${DateFormat('dd MMM yyyy').format(availableEndDate)}.",
                                  //         okBtnFunction: () => Navigator.pop(context),
                                  //       );
                                  //       return;
                                  //     }
                                  //   }
                                  // }
                                  if (productDetailModel.checkOutType == "On time") {
                                    DateTime selectedStartDate = DateFormat('dd MMM yyyy').parse(startFormattedDate);
                                    DateTime selectedEndDate = DateFormat('dd MMM yyyy').parse(endFormattedDate);

                                    DateTime? availableStartDate = productDetailModel.availableStartDate != null
                                        ? DateFormat('dd/MM/yyyy').parse(productDetailModel.availableStartDate!)
                                        : null;
                                    DateTime? availableEndDate = productDetailModel.availableEndDate != null
                                        ? DateFormat('dd/MM/yyyy').parse(productDetailModel.availableEndDate!)
                                        : null;

                                    if (availableStartDate != null && availableEndDate != null) {
                                      if (selectedStartDate.isBefore(availableStartDate) || selectedEndDate.isAfter(availableEndDate)) {
                                        ModelUtils.showSimpleAlertDialog(
                                          context,
                                          title: const Text("Invalid Date"),
                                          content: "Selected dates must fall within the available range: ${DateFormat('dd MMM yyyy').format(availableStartDate)} to ${DateFormat('dd MMM yyyy').format(availableEndDate)}.",
                                          okBtnFunction: () => Navigator.pop(context),
                                        );
                                        return;
                                      }
                                    }
                                  }
                                  addToCartPostApi().then((value) {
                                    if (value.message == "Item added to cart successfully") {
                                      int cartId = value.cartItem!.cartId!;
                                      setState(() {
                                        isAddToCart = true;
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pop(context);
                                      showSnackBar(context, value.message.toString());
                                    }
                                  });
                                } else {
                                  if (startFormattedDate.isEmpty && endFormattedDate.isEmpty) {
                                    ModelUtils.showSimpleAlertDialog(
                                      context,
                                      title: const Text("Event Date"),
                                      content: "Please select event date",
                                      okBtnFunction: () => Navigator.pop(context),
                                    );
                                  } else if (startTime.isEmpty) {
                                    ModelUtils.showSimpleAlertDialog(
                                      context,
                                      title: const Text("Event Time"),
                                      content: "Please select event time",
                                      okBtnFunction: () => Navigator.pop(context),
                                    );
                                  }
                                }
                              },
                              height: 45,
                              color: const Color(0xFF2A9DA0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Text(
                                'ADD TO CART',
                                style: TextStyle(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget productDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  // 'Curved sofa',
                  productDetailModel.name.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 20,
                    fontFamily: serifRegular,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // productDetailModel.availableQuantity! <= 0
                  // ? Container(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 8, vertical: 2),
                  //     decoration: ShapeDecoration(
                  //       // color: const Color(0xFFEBF7DE),
                  //       color: const Color(0XFFFCF4EA),
                  //       shape: RoundedRectangleBorder(
                  //         side: const BorderSide(
                  //             width: 1,
                  //             // color: Color.fromARGB(255, 161, 31, 31),
                  //             color: Color(0XFFE38E31)),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           'not available'.toUpperCase(),
                  //           // textAlign: TextAlign.right,
                  //           style: const TextStyle(
                  //             // color: Color(0xFF65A11F),
                  //             // color: Color.fromARGB(255, 161, 31, 31),
                  //             color: Color(0XFFE38E31),
                  //             fontSize: 10,
                  //             fontFamily: poppinsRegular,
                  //             fontWeight: FontWeight.w500,
                  //             letterSpacing: 1,
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   )
                  // :

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: ShapeDecoration(
                  color: productDetailModel.checkOutType == "Available"
                      ? const Color(0xFF85CB33)
                      : productDetailModel.checkOutType == "Waiting for confirmation"
                      ? const Color(0xFFFFA500) // Orange
                      : const Color(0xFFFF0000), // Red
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1,
                        color: productDetailModel.checkOutType == "Available"
                            ? const Color(0xFF85CB33)
                            : productDetailModel.checkOutType == "Waiting for confirmation"
                            ? const Color(0xFFFFA500) // Orange
                            : const Color(0xFFFF0000)), // Red
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      productDetailModel.checkOutType ?? "",
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 10,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 8, vertical: 2),
              //         decoration: ShapeDecoration(
              //           color: const Color(0xFFEBF7DE),
              //           shape: RoundedRectangleBorder(
              //             side: const BorderSide(
              //                 width: 1, color: Color(0xFF85CB33)),
              //             borderRadius: BorderRadius.circular(4),
              //           ),
              //         ),
              //         child: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Text(
              //               'available'.toUpperCase(),
              //               // textAlign: TextAlign.right,
              //               style: const TextStyle(
              //                 color: Color(0xFF65A11F),
              //                 fontSize: 10,
              //                 fontFamily: poppinsRegular,
              //                 fontWeight: FontWeight.w500,
              //                 letterSpacing: 1,
              //               ),
              //             ),
              //           ],
              //         ),
              //       )
            ],
          ),
          // 8.ph,
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     SvgPicture.asset(ImageConstant.star),
          //     2.pw,
          //     Text.rich(
          //       TextSpan(
          //         children: [
          //           TextSpan(
          //             text: productDetailModel.rating,
          //             style: const TextStyle(
          //               color: Color(0xFFE38E31),
          //               fontSize: 14,
          //               fontFamily: poppinsSemiBold,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //            TextSpan(
          //             // text:" (${productDetailModel.timesRated}) • ${productDetailModel.timesBooked} +booked",
          //              text:" (${productDetailModel.timesRated})",
          //              style: TextStyle(
          //               color: Color(0xFF595959),
          //               fontSize: 14,
          //               fontFamily: poppinsMedium,
          //               fontWeight: FontWeight.w400,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          8.ph,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  //  Text(
                  //    'KD ${productDetailModel.originalPrice}',
                  //   style: TextStyle(
                  //     color: Color(0xFF9B9B9B),
                  //     fontSize: 14,
                  //     fontFamily: poppinsRegular,
                  //     fontWeight: FontWeight.w400,
                  //     decoration: TextDecoration.lineThrough,
                  //   ),
                  // ),
                  10.pw,
                  if(showPrice())
                  Text(
                    'KD ${productDetailModel.pricePerDay}',
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: poppinsBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if(productDetailModel.priceType == "price_per_day" && showPrice())
                  const Text(
                    ' per day',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (favoriteDataList
                      .contains(productDetailModel.id.toString())) {
                    removeWishlistDeleteApi(productDetailModel.id!)
                        .then((value) {
                      favoriteDataList.remove(productDetailModel.id.toString());
                      setFavouriteId(favoriteDataList);
                      setState(() {});
                    });
                  } else {
                    addToWishlistPostApi(productDetailModel.id!).then((value) {
                      favoriteDataList.add(productDetailModel.id.toString());
                      setFavouriteId(favoriteDataList);
                      showSnackBar(context, "Added to Wishlist");
                      setState(() {});
                    });
                  }
                },
                child:
                    favoriteDataList.contains(productDetailModel.id.toString())
                        ? const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite_border_rounded),
              )
            ],
          ),
          10.ph,
          Row(
            children: [
            const Text(
              'Shipping Cost ',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                fontFamily: poppinsRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
              Text(
                'KD ${productDetailModel.shippingPrice}',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: poppinsBold,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
          10.ph,

          // Container(
          //   width: width,
          //   height: 36,
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   decoration: ShapeDecoration(
          //     color: const Color(0xFFFFF3D6),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //   ),
          //   child: const Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Text.rich(
          //         TextSpan(
          //           children: [
          //             TextSpan(
          //               text: '4 ',
          //               style: TextStyle(
          //                 color: Color(0xFF333333),
          //                 fontSize: 14,
          //                 fontFamily: poppinsRegular,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //             TextSpan(
          //               text: 'people added to their cart',
          //               style: TextStyle(
          //                 color: Color(0xFF333333),
          //                 fontSize: 14,
          //                 fontFamily: poppinsRegular,
          //                 fontWeight: FontWeight.w400,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // 32.ph,
          aboutThisProductWidget(),
          12.ph,
          const Divider(),
          12.ph,
          if (productDetailModel.productType == "Variation") ...[
            if ((productDetailModel.colors ?? []).isNotEmpty) ...[
              buildColorsUI(context),
              12.ph,
              const Divider(),
              12.ph,
            ],
            if ((productDetailModel.sizes ?? []).isNotEmpty) ...[
              buildSizesUI(context),
              12.ph,
              const Divider(),
              12.ph,
            ]
          ],
          if ((productDetailModel.addons ?? []).isNotEmpty) ...[
            buildAddonsUI(context),
            24.ph,
            const Divider(),
            24.ph,
          ],
          termsAndConditionWidget(),
          24.ph,
          const Divider(),
          24.ph,
        ],
      ),
    );
  }


  // Widget buildColorsUI(BuildContext context) {
  //   List<ColorsNew> colors = productDetailModel.colors ?? []; // Assuming this list is populated elsewhere
  //   List<Widget> colorWidgets = List<Widget>.generate(colors.length, (index) {
  //     final color = colors[index];
  //     bool isSelected = selectedColor == color; // Assuming selectedColor is managed in your state
  //
  //     return GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           selectedColor = color;
  //           isLoading = true;// Update the selected color
  //         });
  //         checkForAvailablilityAndUpdate();
  //       },
  //       child: Container(
  //         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 50,
  //               height: 50,
  //               decoration: BoxDecoration(
  //                 color: Color(int.parse((color.colorCode ?? "").replaceAll("#", "0xff"))),  // Parsing hex color from color code
  //                 shape: BoxShape.circle,
  //                 border: isSelected
  //                     ? Border.all(color: Colors.black, width: 3)
  //                     : null,
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               color.name ?? "Unnamed",
  //               style: TextStyle(
  //                 color: isSelected ? Colors.blue : Colors.black,
  //                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  //
  //   // Layout updated to Wrap for a flexible arrangement
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: 3,
  //                 height: 20,
  //                 decoration: ShapeDecoration(
  //                   color: const Color(0xFFE38E31),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(4)),
  //                 ),
  //               ),
  //               SizedBox(width: 8), // Space between the decorative line and text
  //               const Text(
  //                 'Select Colors',
  //                 style: TextStyle(
  //                   color: Color(0xFF333333),
  //                   fontSize: 16,
  //                   fontFamily: serifRegular,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Wrap(
  //           alignment: WrapAlignment.start,
  //           spacing: 12, // space between columns
  //           runSpacing: 12, // space between rows
  //           children: colorWidgets,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildSizesUI(BuildContext context) {
  //   List<Sizes> sizes = productDetailModel.sizes ?? []; // Assuming this list is populated elsewhere
  //   List<Widget> sizeWidgets = List<Widget>.generate(sizes.length, (index) {
  //     final size = sizes[index];
  //     bool isSelected = selectedSize == size; // Assuming selectedSize is managed in your state
  //
  //     return GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           selectedSize = size;
  //           isLoading = true;// Update the selected size
  //         });
  //         checkForAvailablilityAndUpdate();
  //       },
  //       child: Container(
  //         width: 80, // Further reduced width to 80 pixels
  //         margin: EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: isSelected ? Colors.grey[300] : Colors.white,
  //           border: Border.all(
  //             color: isSelected ? Colors.blue : Colors.grey,
  //             width: 1.0,
  //           ),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         padding: EdgeInsets.symmetric(vertical: 10), // Reduced padding to center text better
  //         child: Center(
  //           child: Text(
  //             size.name ?? "Unknown Size",
  //             textAlign: TextAlign.center, // Ensure text is centered horizontally
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Adjust font size if needed
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  //
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: 3,
  //                 height: 20,
  //                 decoration: ShapeDecoration(
  //                   color: const Color(0xFFE38E31),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(4)),
  //                 ),
  //               ),
  //               SizedBox(width: 8), // A SizedBox for space between the line and the text
  //               const Text(
  //                 'Select Sizes',
  //                 style: TextStyle(
  //                   color: Color(0xFF333333),
  //                   fontSize: 16,
  //                   fontFamily: serifRegular,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         ...sizeWidgets,
  //       ],
  //     ),
  //   );
  // }


  Widget buildColorsUI(BuildContext context) {
    List<ColorsNew> colors = productDetailModel.colors ?? []; // Assuming this list is populated elsewhere
    List<Widget> colorWidgets = List<Widget>.generate(colors.length, (index) {
      final color = colors[index];
      bool isSelected = selectedColor == color; // Assuming selectedColor is managed in your state

      return GestureDetector(
        onTap: () {
          if(selectedColor == color){
            setState(() {
              selectedColor = null;
            });
          }
          else {
            setState(() {
              selectedColor = color;
            });
          }
          checkForAvailablilityAndUpdate();
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse((color.colorCode ?? "").replaceAll("#", "0xff"))),  // Parsing hex color from color code
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey, // Black for selected, gray for non-selected
                    width: 3,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                color.name ?? "Unnamed",
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              SizedBox(width: 8), // Space between the decorative line and text
              const Text(
                'Select Colors',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: serifRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: colorWidgets,
          ),
        ),
      ],
    );
  }

  Widget buildSizesUI(BuildContext context) {
    List<Sizes> sizes = productDetailModel.sizes ?? []; // Assuming this list is populated elsewhere
    List<Widget> sizeWidgets = List<Widget>.generate(sizes.length, (index) {
      final size = sizes[index];
      bool isSelected = selectedSize == size; // Assuming selectedSize is managed in your state

      return GestureDetector(
        onTap: () {
          if(selectedSize == size){
            setState(() {
              selectedSize = null;
            });
          }
          else {
            setState(() {
              selectedSize = size;
            });
          }
          checkForAvailablilityAndUpdate();
        },
        child: Container(
          width: 60, // Further reduced width to 80 pixels
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[300] : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10), // Reduced padding to center text better
          child: Center(
            child: Text(
              size.name ?? "Unknown Size",
              textAlign: TextAlign.center, // Ensure text is centered horizontally
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Adjust font size if needed
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              SizedBox(width: 8), // A SizedBox for space between the line and the text
              const Text(
                'Select Sizes',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: serifRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Row(
            children: sizeWidgets,
          ),
        ),
      ],
    );
  }


  Widget reviewsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
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
                'Reviews',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: serifRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        24.ph,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                ImageConstant.star,
                width: 24,
              ),
              5.pw,
              const Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '4.2',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '/5',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 12,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        16.ph,
        SizedBox(
          height: 84,
          // width: 312,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            padding: const EdgeInsets.only(left: 20),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                height: 84,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF6F6F6),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: Color(0xFFEDEDED),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'The booking experience was awesome. The happy bash really made us very happy',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget termsAndConditionWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Terms and Conditions',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontFamily: serifRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productDetailModel.termsConditions!.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Padding(
                //   padding: EdgeInsets.only(top: 8.0),
                //   child: Icon(
                //     Icons.circle,
                //     size: 6,
                //   ),
                // ),
                // 5.pw,
                Flexible(
                  child: Text(
                    // 'Cannot install it on the beach if the water could reach the game',
                    productDetailModel.termsConditions![index],
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        24.ph,
        const Text(
          "Confirmation",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
        16.ph,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.circle,
                size: 6,
              ),
            ),
            5.pw,
            const Flexible(
              child: Text(
                "You’ll get confirmation within minutes. If you don’t see any confirmation, reach out to our customer support",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: poppinsRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        24.ph,
        const Text(
          "Cancellation policy",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
        16.ph,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.circle,
                size: 6,
              ),
            ),
            5.pw,
            const Flexible(
              child: Text(
                "Please review our Cancellation & Refund Policy before placing your order.",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: poppinsRegular,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget aboutThisProductWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'About this product',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontFamily: serifRegular,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
        16.ph,
        Text(
            productDetailModel.description ?? "",
            // 'One Table With 4 Chairs Of Mixed Color Blocks',
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontFamily: poppinsRegular,
              fontWeight: FontWeight.w400,
            ),
          ),
        16.ph,
        //-------------- what's included section --------------//
        const Text(
          "What’s included",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
        24.ph,
        productDetailModel.includedItems!.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productDetailModel.includedItems!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(ImageConstant.checkCircle),
                        12.pw,
                        Flexible(
                          child: Text(
                            productDetailModel.includedItems![index],
                            // 'One Table With 4 Chairs Of Mixed Color Blocks',
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
            : const Text(""),
        24.ph,
        //-------------- not included section --------------//
        const Text(
          'What’s Not included',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        16.ph,
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productDetailModel.notIncludedItems!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(4.0), // Consistent padding with 'included items'
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.remove_circle_outline, // Changed to a 'minus' icon for clarity
                    color: Colors.red, // Optional: make the icon red to denote 'not included'
                    size: 20, // Adjust size to match your design
                  ),
                  12.pw, // Consistent spacing with 'included items'
                  Flexible(
                    child: Text(
                      productDetailModel.notIncludedItems![index],
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                        fontFamily: 'PoppinsRegular',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),


        24.ph,
        //-------------- additional information section --------------//
        const Text(
          'Additional information',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
        16.ph,
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productDetailModel.additionalInformation!.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                  ),
                ),
                5.pw,
                Flexible(
                  child: Text(
                    // 'Cannot install it on the beach if the water could reach the game',
                    productDetailModel.additionalInformation![index],
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Function to create a list of addon widgets with checkboxes and info buttons

  Widget buildAddonsUI(BuildContext context) {
    List<Addon> addons = productDetailModel.addons ?? [];
    List<Widget> addonWidgets = List<Widget>.generate(addons.length, (index) {
      final addon = addons[index];
      bool isSelected = selectedAddonList.any((selectedAddon) =>
      selectedAddon.id == addon.id);

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Card(
          elevation: 6,
          margin: EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text(
              addon.name ?? "",
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "KD ${addon.price}",
                    style: TextStyle(color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    addon.description ?? "",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            trailing: SizedBox(
              height: 80, // Adjust height to prevent overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedAddonList.add(addon);
                        } else {
                          selectedAddonList.removeWhere((
                              selectedAddon) => selectedAddon.id == addon.id);
                        }
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
    // Return a Column widget containing all the addon cards with padding
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                  'Addons',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontFamily: serifRegular,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          ...addonWidgets,
        ]
    );
  }





}
