import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/categories_model.dart';
import 'package:happy_bash/models/get_cart_model.dart';
import 'package:happy_bash/models/get_location_model.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/device_registration_service.dart';
import 'package:happy_bash/ui/pages/Categories/listing_page.dart';
import 'package:happy_bash/ui/pages/Categories/sub_categories.dart';
import 'package:happy_bash/ui/pages/cart/cart_page.dart';
import 'package:happy_bash/ui/pages/homepage/search_page.dart';
import 'package:happy_bash/ui/pages/profile/contact/contact_us.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/navigator.dart';
import '../../../core/utils/size_utils.dart';
import '../../../models/profile_model.dart';
import '../../../models/sub_categories_model.dart';
import '../../../network/base_url.dart';
import '../../screen/quotation_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  List<CategoriesModel> categoriesList = [];
  List<SubCategoriesModel> subCategoriesList = [];
  DateTime? startDate;
  DateTime? endDate;
  String startFormattedDate = "";
  String endFormattedDate = "";
  String selectEventId = "";
  String selectEventName = "";
  String selectEventImageUrl = "";
  String _searchValue = "";
  TextEditingController _searchController = TextEditingController();

  int tabValue = 0;
  int cartCount = 0;
  int? locationId;
  String searchValue = "";
  int? selectedProductId;
  List<GetLocationModel> getLocationList = [];
  TextEditingController selectedProductName = TextEditingController();

  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if(!getIsFcmRegistered(prefs)){
      DeviceRegistrationService().registerDevice().then((result) {
        setIsFcmRegistered(true);
      });
    }
    await getCartApi().then((value) {
      if (value.cart != null) {
        cartCount = value.cart!.cartItems!.length;
      }
    });
    if (getIsUserLogin(prefs) == true) {
      await getProfileApi().then((value) async {
        locationId = value.locationId;
        await locationsGetApi().then((value) {
          for (var element in getLocationList) {
            if (element.id == locationId) {
              setLocation(element.name);
            }
          }
        });
      });
    }
    return prefs;
  }

  Future<List<GetLocationModel>> locationsGetApi() async {
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.locations}"),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    getLocationList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("categoriesGetApi ResponseData", responseData);
        for (Map i in responseData) {
          getLocationList.add(GetLocationModel.fromJson(i));
        }
        // return CategoriesModel.fromJson(responseData);
        return getLocationList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("categoriesGetApi catch", exception.toString());
    }

    return getLocationList;
  }

  Future<List<CategoriesModel>> categoriesGetApi() async {
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.categories}"),
      // headers: await getHeaders(),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    categoriesList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("categoriesGetApi ResponseData", responseData);
        for (Map i in responseData) {
          categoriesList.add(CategoriesModel.fromJson(i));
        }
        // return CategoriesModel.fromJson(responseData);
        return categoriesList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("categoriesGetApi catch", exception.toString());
    }

    // return CategoriesModel.fromJson(responseData);
    return categoriesList;
  }


  void categoriesGetApiNew() async {
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.categories}"),
      // headers: await getHeaders(),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    categoriesList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("categoriesGetApi ResponseData", responseData);
        for (Map i in responseData) {
          categoriesList.add(CategoriesModel.fromJson(i));
        }
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("categoriesGetApi catch", exception.toString());
    }
    setState(() {
      categoriesList;
    });
  }

  Future<Map<String, dynamic>> updateLocationApi(String locationId) async {
    var responseData;
    String token = await getToken();

    final jsonResponse = await http.put(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.updateLocations}"),
      headers: {
        // "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {"location_id": locationId},
    );
    try {
      if (jsonResponse.statusCode == 200) {
        printMsgTag("updateLocationApi response", jsonResponse.body.toString());
        responseData = jsonDecode(jsonResponse.body.toString());
        return responseData;
      } else {
        throw Exception;
      }
    } catch (exception) {
      printMsgTag("updateLocationApi catch", exception.toString());
    }
    return responseData;
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

  Future<List<SubCategoriesModel>> subCategoriesGetApi(int categoriesId) async {
    final response = await http.get(
      Uri.parse(
          "${BaseUrl.globalUrl}/${BaseUrl.categories}/$categoriesId/${BaseUrl.subCategories}"),
      // headers: await getHeaders(),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    subCategoriesList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("categoriesGetApi ResponseData", responseData);
        for (Map i in responseData) {
          subCategoriesList.add(SubCategoriesModel.fromJson(i));
        }
        return subCategoriesList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("categoriesGetApi catch", exception.toString());
    }

    return subCategoriesList;
  }

  Future<ProfileModel> getProfileApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();

    //loading circular bar
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CustomProgressBar());
      },
    );

    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.profile}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());

    // After loading navigate to nextScreen...
    Navigator.of(context).pop();

    try {
      if (response.statusCode == 200) {
        printMsgTag("getCartApi ResponseData", responseData);
        return ProfileModel.fromJson(responseData);
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getCartApi catch", exception.toString());
    }

    return ProfileModel.fromJson(responseData);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getProfileApi().then((value) {
  //     locationId = value.locationId;
  //     locationsGetApi().then((value) {
  //       getLocationList.forEach((element) {
  //         if (element.id == locationId) {
  //           setLocation(element.name);
  //         }
  //       });
  //     });
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoriesGetApiNew();
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
    if (startDate != null && endDate != null) {
      // Convert string to DateTime object
      DateTime originalStartDate = DateTime.parse(startDate.toString());
      DateTime originalEndDate = DateTime.parse(endDate.toString());

      // Format the DateTime object as required
      startFormattedDate = DateFormat('dd MMM yyyy').format(originalStartDate);
      endFormattedDate = DateFormat('dd MMM yyyy').format(originalEndDate);
    }

    return FutureBuilder<SharedPreferences>(
      future: getSharedPreferences(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          prefs = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: PrimaryColors().white,
              elevation: 0.0,
              // title: GestureDetector(
              //   onTap: () {
              //     showModalBottomSheet(
              //       context: context,
              //       isScrollControlled: true,
              //       shape: const RoundedRectangleBorder(
              //         borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(20),
              //           topRight: Radius.circular(20),
              //         ),
              //       ),
              //       builder: (context) {
              //         return Container(
              //           width: width,
              //           height: height - 100,
              //           decoration: const BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(20),
              //               topRight: Radius.circular(20),
              //             ),
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 vertical: 10, horizontal: 16),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     const Text(
              //                       'Select event location',
              //                       style: TextStyle(
              //                         color: Color(0xFF1D2939),
              //                         fontSize: 20,
              //                         fontFamily: serifRegular,
              //                         fontWeight: FontWeight.w400,
              //                       ),
              //                     ),
              //                     IconButton(
              //                       onPressed: () => Navigator.pop(context),
              //                       icon: const Icon(Icons.close),
              //                     )
              //                   ],
              //                 ),
              //                 7.ph,
              //                 Text(
              //                   'Current location ${getLocation(prefs)}',
              //                   style: TextStyle(
              //                     color: Colors.grey.shade600,
              //                     // fontSize: 20,
              //                     fontFamily: poppinsRegular,
              //                     fontWeight: FontWeight.w400,
              //                     height: -0.9,
              //                   ),
              //                 ),
              //                 20.ph,
              //                 TextFormField(
              //                   decoration: InputDecoration(
              //                     contentPadding: const EdgeInsets.symmetric(
              //                         vertical: 8, horizontal: 12),
              //                     hintText: 'Search location',
              //                     hintStyle: const TextStyle(
              //                       color: Color(0xFF9B9B9B),
              //                       fontSize: 14,
              //                       fontFamily: poppinsRegular,
              //                       fontWeight: FontWeight.w400,
              //                     ),
              //                     border: OutlineInputBorder(
              //                         borderSide: const BorderSide(
              //                             color: Color(0xFFCCCCCC)),
              //                         borderRadius: BorderRadius.circular(8)),
              //                     focusedBorder: OutlineInputBorder(
              //                         borderSide: const BorderSide(
              //                             color: Color(0xFF2A9DA0)),
              //                         borderRadius: BorderRadius.circular(8)),
              //                     enabledBorder: OutlineInputBorder(
              //                         borderSide: const BorderSide(
              //                             color: Color(0xFFCCCCCC)),
              //                         borderRadius: BorderRadius.circular(8)),
              //                     prefixIcon: Image.asset(
              //                       "assets/icons/Search.png",
              //                       color: searchValue.isNotEmpty
              //                           ? PrimaryColors().black900
              //                           : null,
              //                     ),
              //                     suffixIcon: searchValue.isNotEmpty
              //                         ? Image.asset("assets/icons/cancel.png")
              //                         : const SizedBox(width: 0, height: 0),
              //                   ),
              //                   cursorColor: Colors.black,
              //                   onChanged: (value) {
              //                     setState(() {
              //                       searchValue = value;
              //                     });
              //                   },
              //                 ),
              //                 24.ph,
              //                 FutureBuilder(
              //                   future: locationsGetApi(),
              //                   builder: (context, snapshot) {
              //                     if (snapshot.hasData) {
              //                       return ListView.separated(
              //                         shrinkWrap: true,
              //                         physics:
              //                             const NeverScrollableScrollPhysics(),
              //                         itemCount: getLocationList.length,
              //                         separatorBuilder:
              //                             (BuildContext context, int index) {
              //                           return const Divider(thickness: 1);
              //                         },
              //                         itemBuilder: (context, index) {
              //                           return ListTile(
              //                             onTap: () {
              //                               Navigator.pop(context);
              //                               showModalBottomSheet(
              //                                 context: context,
              //                                 isScrollControlled: true,
              //                                 shape:
              //                                     const RoundedRectangleBorder(
              //                                   borderRadius: BorderRadius.only(
              //                                     topLeft: Radius.circular(20),
              //                                     topRight: Radius.circular(20),
              //                                   ),
              //                                 ),
              //                                 builder: (context) {
              //                                   return Container(
              //                                     width: width,
              //                                     height: 300,
              //                                     decoration:
              //                                         const BoxDecoration(
              //                                       color: Colors.white,
              //                                       borderRadius:
              //                                           BorderRadius.only(
              //                                         topLeft:
              //                                             Radius.circular(20),
              //                                         topRight:
              //                                             Radius.circular(20),
              //                                       ),
              //                                     ),
              //                                     child: Padding(
              //                                       padding: const EdgeInsets
              //                                           .symmetric(
              //                                           horizontal: 15.0),
              //                                       child: Column(
              //                                         crossAxisAlignment:
              //                                             CrossAxisAlignment
              //                                                 .center,
              //                                         children: [
              //                                           Row(
              //                                             mainAxisAlignment:
              //                                                 MainAxisAlignment
              //                                                     .end,
              //                                             crossAxisAlignment:
              //                                                 CrossAxisAlignment
              //                                                     .center,
              //                                             children: [
              //                                               IconButton(
              //                                                 onPressed: () =>
              //                                                     Navigator.pop(
              //                                                         context),
              //                                                 icon: const Icon(
              //                                                   Icons.close,
              //                                                   size: 15,
              //                                                 ),
              //                                               )
              //                                             ],
              //                                           ),
              //                                           7.ph,
              //                                           const Text(
              //                                             'Are you sure to change your event location?',
              //                                             style: TextStyle(
              //                                               color: Color(
              //                                                   0xFF1D2939),
              //                                               fontSize: 20,
              //                                               fontFamily:
              //                                                   serifRegular,
              //                                               fontWeight:
              //                                                   FontWeight.w400,
              //                                             ),
              //                                             textAlign:
              //                                                 TextAlign.center,
              //                                           ),
              //                                           7.ph,
              //                                           Text(
              //                                             'On changing the location the items added in your cart will be removed',
              //                                             style: TextStyle(
              //                                               color: Colors
              //                                                   .grey.shade600,
              //                                               fontFamily:
              //                                                   poppinsMedium,
              //                                               fontWeight:
              //                                                   FontWeight.w400,
              //                                             ),
              //                                             textAlign:
              //                                                 TextAlign.center,
              //                                           ),
              //                                           20.ph,
              //                                           MaterialButton(
              //                                             onPressed: () {
              //                                               updateLocationApi(
              //                                                       getLocationList[
              //                                                               index]
              //                                                           .id
              //                                                           .toString())
              //                                                   .then((value) {
              //                                                 setLocation(
              //                                                     getLocationList[
              //                                                             index]
              //                                                         .name);
              //                                                 Navigator.pop(
              //                                                     context);
              //                                                 showSnackBar(
              //                                                     context,
              //                                                     "Location changed successfully...");
              //                                               });
              //                                             },
              //                                             minWidth: width,
              //                                             height: 40,
              //                                             color: PrimaryColors()
              //                                                 .primarycolor,
              //                                             shape:
              //                                                 RoundedRectangleBorder(
              //                                               borderRadius:
              //                                                   BorderRadius
              //                                                       .circular(
              //                                                           36),
              //                                             ),
              //                                             child: Text(
              //                                               'Yes, Change the location'
              //                                                   .toUpperCase(),
              //                                               style:
              //                                                   const TextStyle(
              //                                                 color:
              //                                                     Colors.white,
              //                                                 fontSize: 12,
              //                                                 fontFamily:
              //                                                     poppinsSemiBold,
              //                                                 fontWeight:
              //                                                     FontWeight
              //                                                         .w600,
              //                                               ),
              //                                             ),
              //                                           ),
              //                                           TextButton(
              //                                             onPressed: () =>
              //                                                 Navigator.pop(
              //                                                     context),
              //                                             child: Text(
              //                                               "Cancel",
              //                                               style: TextStyle(
              //                                                 color:
              //                                                     PrimaryColors()
              //                                                         .black900,
              //                                               ),
              //                                             ),
              //                                           )
              //                                         ],
              //                                       ),
              //                                     ),
              //                                   );
              //                                 },
              //                               ).then((value) {
              //                                 setState(() {});
              //                               });
              //                             },
              //                             dense: true,
              //                             horizontalTitleGap: 0,
              //                             leading: Image.asset(
              //                                 "assets/icons/location.png"),
              //                             title: Text(
              //                               getLocationList[index]
              //                                   .name
              //                                   .toString(),
              //                               style: const TextStyle(
              //                                 color: Color(0xFF333333),
              //                                 fontSize: 14,
              //                                 fontFamily: poppinsRegular,
              //                                 fontWeight: FontWeight.w400,
              //                               ),
              //                             ),
              //                           );
              //                         },
              //                       );
              //                     }
              //                     return const CustomProgressBar();
              //                   },
              //                 ),
              //               ],
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   },
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       SvgPicture.asset("assets/HappyBash/location-1.svg"),
              //       2.ph,
              //       Text(
              //         getLocation(prefs),
              //         style: const TextStyle(
              //           color: Color(0xFF333333),
              //           fontSize: 14,
              //           fontFamily: poppinsSemiBold,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      )).then((value) {
                    setState(() {});
                  }),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(top: cartCount == 0 ? 18.0 : 5.0),
                        child: SvgPicture.asset(
                          "assets/HappyBash/cart.svg",
                          width: 28,
                        ),
                      ),
                      cartCount != 0
                          ? Badge(
                              backgroundColor: PrimaryColors().primarycolor,
                              textColor: PrimaryColors().white,
                              label: Text(cartCount.toString()),
                            )
                          : Container(),

                      // Positioned(
                      //   // top: -1,
                      //   child: Container(
                      //     width: 10,
                      //     height: 10,
                      //     decoration: BoxDecoration(
                      //       color: PrimaryColors().primarycolor,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         cartCount.toString(),
                      //         style: TextStyle(color: PrimaryColors().white),
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
                10.pw,
              ],
            ),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/home-bg.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 20,
                    right: -100,
                    child: Opacity(
                      opacity: 0.10,
                      child: Image.asset(ImageConstant.logoIcon),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 10.ph,
                        const Text(
                          'What’s on your mind?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: serifRegular,
                            fontWeight: FontWeight. w400,
                          ),
                        ),
                        20.ph,
                        searchOfEventAndProducts(context),
                        30.ph,
                        browseByCategories(),
                        20.ph,
                        yourEventBanner(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const CustomProgressBar();
      },
    );
  }

  //.......Search Filed for Event and Product with time periods...........//
  Widget searchOfEventAndProducts(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: DefaultTabController(
          length: 2,
          animationDuration: const Duration(microseconds: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                labelColor: PrimaryColors().primarycolor,
                // splashBorderRadius: BorderRadius.zero,
                overlayColor:
                    const WidgetStatePropertyAll(Colors.transparent),
                labelStyle: const TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 14,
                  fontFamily: poppinsSemiBold,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelColor: const Color(0xFF9B9B9B),
                unselectedLabelStyle: const TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 14,
                  fontFamily: poppinsMedium,
                  fontWeight: FontWeight.w600,
                ),
                indicatorColor: PrimaryColors().primarycolor,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (value) {
                  printMsgTag("tabbar", value);
                  setState(() {
                    tabValue = value;
                  });
                },
                tabs: const [
                  Tab(
                    text: "Categories",
                  ),
                  Tab(
                    text: "Products",
                  )
                ],
              ),
              SizedBox(
                height: tabValue == 1 ? 170 : 170,
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // --- event ---- //
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        20.ph,
                        // const Text(
                        //   'Select event type',
                        //   style: TextStyle(
                        //     color: Color(0xFF595959),
                        //     fontSize: 12,
                        //     fontFamily: poppinsRegular,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                        // 10.ph,
                        DropdownButtonFormField(
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: PrimaryColors().secondarycolor,
                          ),
                          items: categoriesList.map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            for (var element in categoriesList) {
                              if (element.id == value) {
                                setState(() {
                                  selectEventId = value.toString();
                                  selectEventName = element.name.toString();
                                  selectEventImageUrl =
                                      element.imageUrl.toString();
                                });
                              }
                            }

                            printMsgTag(selectEventId, selectEventId);
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            isDense: true,
                            hintText: 'Select Category',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 12,
                              fontFamily: poppinsRegular,
                              fontWeight: FontWeight.w400,
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFDED5D5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: PrimaryColors().primarycolor),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFDED5D5)),
                            ),
                          ),
                        ),
                        20.ph,
                        MaterialButton(
                          onPressed: () {
                            if (selectEventId.isNotEmpty
                            // &&
                                // startFormattedDate.isNotEmpty &&
                                // endFormattedDate.isNotEmpty
                            ) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoriesPage(
                                      categoryId: int.parse(selectEventId),
                                      categoryName: selectEventName,
                                    ),
                                  )).then((value) {
                                setState(() {});
                              });
                            } else {
                              ModelUtils.showSimpleAlertDialog(
                                context,
                                title: const Text("Happy Bash"),
                                content:
                                    "Please select event type",
                                okBtnFunction: () => Navigator.pop(context),
                              );
                            }
                          },
                          minWidth: width,
                          height: 40,
                          color: PrimaryColors().primarycolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: const Text(
                            'VIEW CATEGORY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: poppinsSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // --- products ---- //
                    Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            20.ph,
                            const Text(
                              'Search Product',
                              style: TextStyle(
                                color: Color(0xFF595959),
                                fontSize: 12,
                                fontFamily: poppinsRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            20.ph,
                            TextFormField(
                              controller: selectedProductName,
                              decoration: InputDecoration(
                                // isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                hintText: 'Search product',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 14,
                                  fontFamily: poppinsRegular,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFFDED5D5)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      // color: Color(0xFFDED5D5),
                                      color: PrimaryColors().primarycolor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDED5D5),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Image.asset(
                                  "assets/icons/Search.png",
                                  color: PrimaryColors().secondarycolor,
                                ),
                              ),

                              cursorColor: Colors.black,
                              validator: (email) {
                                if (email == null || email.isEmpty) {
                                  return "Please enter email";
                                }

                                return null;
                              },
                              // onChanged: (value) {
                              //   setState(() {
                              //     _searchValue = value;
                              //   });
                              // },
                              // onSaved: (value) {
                              //   allergies = value!;
                              //   printMsgTag("allergies", allergies);
                              // },
                            ),
                            20.ph,
                            // const Text(
                            //   'Select event dates',
                            //   style: TextStyle(
                            //     color: Color(0xFF595959),
                            //     fontSize: 12,
                            //     fontFamily: poppinsRegular,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            // 10.ph,
                            // GestureDetector(
                            //   onTap: () async {
                            //     final result = await showDateRangePicker(
                            //       context: context,
                            //       firstDate: DateTime.now(),
                            //       lastDate: DateTime(2100),
                            //     );
                            //     if (result != null) {
                            //       setState(() {
                            //         startDate = result.start;
                            //         endDate = result.end;
                            //       });
                            //
                            //       printMsgTag("startDate", startDate);
                            //       printMsgTag("endDate", endDate);
                            //     }
                            //   },
                            //   child: Card(
                            //     surfaceTintColor: Colors.transparent,
                            //     color: Colors.transparent,
                            //     elevation: 0.0,
                            //     margin: EdgeInsets.zero,
                            //     child: Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Row(
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: [
                            //             Container(
                            //               width: 30,
                            //               height: 30,
                            //               decoration: const ShapeDecoration(
                            //                 color: Color(0xFFF6F6F6),
                            //                 shape: CircleBorder(),
                            //               ),
                            //               child: Center(
                            //                 child: Image.asset(
                            //                     ImageConstant.calendar),
                            //               ),
                            //             ),
                            //             10.pw,
                            //             Text(
                            //               // '29 Jan 2023 - 31 Jan 2023',
                            //               startFormattedDate.isNotEmpty &&
                            //                       endFormattedDate.isNotEmpty
                            //                   ? '$startFormattedDate - $endFormattedDate'
                            //                   : "Start Date - End Date",
                            //               style: const TextStyle(
                            //                 color: Color(0xFF333333),
                            //                 fontSize: 14,
                            //                 fontFamily: poppinsRegular,
                            //                 fontWeight: FontWeight.w400,
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //         Image.asset("assets/icons/chevron-left.png")
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // 20.ph,
                            MaterialButton(
                              onPressed: () {
                                if (selectedProductName.text.isNotEmpty
                                    // &&
                                    // startFormattedDate.isNotEmpty &&
                                    // endFormattedDate.isNotEmpty
                                ) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchPage(
                                          searchValue: selectedProductName.text,
                                          eventDate:
                                              '$startFormattedDate - $endFormattedDate',
                                        ),
                                      )).then((value) {
                                    setState(() {});
                                  });
                                } else {
                                  ModelUtils.showSimpleAlertDialog(
                                    context,
                                    title: const Text("Happy Bash"),
                                    content:
                                    "Please enter something in search bar",
                                    okBtnFunction: () =>
                                        Navigator.pop(context),
                                  );
                                }
                              },
                              minWidth: width,
                              height: 40,
                              color: PrimaryColors().primarycolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Text(
                                'Search product'.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: poppinsSemiBold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget browseByCategories() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse by',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 20,
            fontFamily: serifRegular,
            fontWeight: FontWeight.w400,
          ),
        ),
        10.ph, // Reduced vertical padding
        FutureBuilder(
          future: categoriesGetApi().then((value) {
            for (var e in value) {
              if (e.name == 'Events') {
                subCategoriesGetApi(e.id!);
              }
            }
            return true;
          }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoriesList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16, // Increased spacing
                  crossAxisSpacing: 16, // Increased spacing
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubCategoriesPage(
                              categoryId: categoriesList[index].id!,
                              categoryName: categoriesList[index].name.toString(),
                            ),
                          )).then((value) {
                        setState(() {});
                      });
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              categoriesList[index].imageUrl.toString(),
                              width: double.infinity, // Fill the available width
                              fit: BoxFit.cover, // Fill the ImageView while maintaining aspect ratio
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          child: Text(
                            categoriesList[index].name.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 12, // Adjusted font size for space
                              fontFamily: poppinsMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
            return const CustomProgressBar();
          },
        ),
      ],
    );
  }
  // Widget browseByCategories() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Browse by',
  //           style: TextStyle(
  //             color: Color(0xFF1D2939),
  //             fontSize: 24,
  //             fontFamily: serifRegular,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         SizedBox(height: 12),
  //         FutureBuilder(
  //           future: categoriesGetApi().then((value) {
  //             for (var e in value) {
  //               if (e.name == 'Events') {
  //                 subCategoriesGetApi(e.id!);
  //               }
  //             }
  //             return true;
  //           }),
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               return GridView.builder(
  //                 shrinkWrap: true,
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 itemCount: categoriesList.length,
  //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 3,
  //                   mainAxisSpacing: 12, // Reduced spacing for better visual balance
  //                   crossAxisSpacing: 12, // Reduced spacing for better visual balance
  //                   childAspectRatio: 0.75, // Adjusted to make the grid items more visually balanced
  //                 ),
  //                 itemBuilder: (context, index) {
  //                   return GestureDetector(
  //                     onTap: () {
  //                       Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => SubCategoriesPage(
  //                               categoryId: categoriesList[index].id!,
  //                               categoryName: categoriesList[index].name.toString(),
  //                             ),
  //                           )).then((value) {
  //                         setState(() {});
  //                       });
  //                     },
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(16),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.grey.withOpacity(0.2),
  //                             spreadRadius: 2,
  //                             blurRadius: 6,
  //                             offset: Offset(0, 3),
  //                           ),
  //                         ],
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                         children: [
  //                           ClipRRect(
  //                             borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //                             child: Image.network(
  //                               categoriesList[index].imageUrl.toString(),
  //                               height: 120, // Increased height for all images to maintain uniformity
  //                               width: double.infinity,
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.all(8),
  //                             child: Text(
  //                               categoriesList[index].name.toString(),
  //                               textAlign: TextAlign.center,
  //                               style: const TextStyle(
  //                                 color: Color(0xFF333333),
  //                                 fontSize: 14,
  //                                 fontFamily: poppinsMedium,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //             return const CustomProgressBar();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget yourEventBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      //height: 156,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/estimate_banner.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'YOUR EVENT OUR RESPONSIBILTY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              15.pw,
              Expanded(
                child: Container(
                  // width: 100,
                  height: 1,
                  color: const Color.fromRGBO(133, 203, 51, 1),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const ShapeDecoration(
                  color: Color.fromRGBO(133, 203, 51, 1),
                  shape: CircleBorder(),
                ),
              )
            ],
          ),
          // 15.ph,
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: const Text(
                  'Provide your event details\nand our experts will manage\neverything',
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 16,
                    fontFamily: serifRegular,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          // 1.ph,
          // GestureDetector(
          //   onTap: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const ContactUsPage())).then((value) {
          //     setState(() {});
          //   }),
          //   child: Row(
          //     children: [
          //       const Text(
          //         'Get an estimate',
          //         style: TextStyle(
          //           color: Color(0xFF2A9DA0),
          //           fontSize: 14,
          //           fontFamily: poppinsSemiBold,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //       7.pw,
          //       const Icon(
          //         Icons.arrow_forward,
          //         color: Color(0xFF2A9DA0),
          //       )
          //     ],
          //   ),
          // ),
          // 6.ph,
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const QuotationScreen())).then((value) {
              setState(() {});
            }),
            child: Row(
              children: [
                const Text(
                  'Get an quotation',
                  style: TextStyle(
                    color: Color(0xFF2A9DA0),
                    fontSize: 13.5,
                    fontFamily: poppinsSemiBold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                7.pw,
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF2A9DA0),
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}
