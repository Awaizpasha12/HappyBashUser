import 'dart:convert';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/product_model.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/Categories/detail_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/shared_preferences_utils.dart';
import '../../../network/base_url.dart';

class EventsDetailPage extends StatefulWidget {
  const EventsDetailPage({
    Key? key,
    required this.imageUrl,
    required this.headerName,
    required this.subcategoriesId,
  }) : super(key: key);
  final String imageUrl;
  final String headerName;
  final int subcategoriesId;

  @override
  State<EventsDetailPage> createState() => _EventsDetailPageState();
}

class _EventsDetailPageState extends State<EventsDetailPage> {
  late ScrollController _scrollController;
  int pageIndex = 0;
  bool lastStatus = true;
  DateTime? startDate;
  DateTime? endDate;
  String startFormattedDate = "";
  String endFormattedDate = "";
  List<ProductModel> productList = [];
  List<ProductModel> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> favoriteDataList = [];
  int productListCount = 0;
  late Future<List<ProductModel>> _productsFuture;

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.position.pixels > 70;
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _productsFuture = productGetApi();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<List<ProductModel>> productGetApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    favoriteDataList = await futuregetFavouriteId();
    final response = await http.get(
      Uri.parse(
          "${BaseUrl.globalUrl}/${BaseUrl.products}?subcategory_id=${widget.subcategoriesId}"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    productList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("productGetApi ResponseData", responseData);
        for (Map i in responseData) {
          productList.add(ProductModel.fromJson(i));
        }
        _filteredProducts = productList;
        return productList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("productGetApi catch", exception.toString());
    }
    _filteredProducts = productList;
    return productList;
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
  Widget build(BuildContext context) {
    if (startDate != null && endDate != null) {
      // Convert string to DateTime object
      DateTime originalStartDate = DateTime.parse(startDate.toString());
      DateTime originalEndDate = DateTime.parse(endDate.toString());

      // Format the DateTime object as required
      startFormattedDate = DateFormat('dd MMM yyyy').format(originalStartDate);
      endFormattedDate = DateFormat('dd MMM yyyy').format(originalEndDate);
    }
    printMsgTag("favoriteDataList", favoriteDataList);

    return Scaffold(
        body: Container(
        child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // SliverAppBar(
          //   backgroundColor: PrimaryColors().white,
          //   elevation: 0.0,
          //   pinned: true,
          //   automaticallyImplyLeading: true,
          //   // expandedHeight: 170,
          //   centerTitle: true,
          //   leading: IconButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.arrow_back_ios_new_outlined,
          //       color: Colors.black,
          //       // color: isShrink == true ? Colors.black : Colors.white,
          //     ),
          //   ),
          //   // actions: [
          //   //   Icon(
          //   //     Icons.share,
          //   //     color: Colors.black,
          //   //     // color: isShrink == true ? Colors.black : Colors.white,
          //   //   ),
          //   //   15.pw,
          //   // ],
          //   // flexibleSpace: FlexibleSpaceBar(
          //   //   centerTitle: true,
          //   //   // titlePadding: isShrink == true
          //   //   //     ? null
          //   //   //     : const EdgeInsets.symmetric(vertical: 30),
          //   //   title: Column(
          //   //     mainAxisSize: MainAxisSize.min,
          //   //     children: [
          //   //       Text(
          //   //         widget.headerName,
          //   //         style: TextStyle(
          //   //           // color: isShrink ? Colors.black : Colors.white,
          //   //           color: Colors.black,
          //   //           fontSize: 20,
          //   //           fontFamily: serifRegular,
          //   //           fontWeight: FontWeight.w400,
          //   //         ),
          //   //       ),
          //   //       startFormattedDate.isNotEmpty && endFormattedDate.isNotEmpty
          //   //           ? Text(
          //   //               // '29 Jan 2023 - 31 Jan 2023',
          //   //               '$startFormattedDate - $endFormattedDate',
          //   //               style: TextStyle(
          //   //                 // color: isShrink ? Colors.black : Colors.white,
          //   //                 color: Colors.black,
          //   //                 fontSize: 10,
          //   //                 fontFamily: poppinsRegular,
          //   //                 fontWeight: FontWeight.w400,
          //   //               ),
          //   //             )
          //   //           : Container()
          //   //     ],
          //   //   ),
          //   //   background: Container(
          //   //     decoration: BoxDecoration(
          //   //       image: DecorationImage(
          //   //           image: NetworkImage(
          //   //               // "assets/images/dish-3.jpg",
          //   //               widget.imageUrl),
          //   //           fit: BoxFit.contain,
          //   //           colorFilter: ColorFilter.mode(
          //   //             Colors.black.withOpacity(0.3),
          //   //             BlendMode.darken,
          //   //           )),
          //   //     ),
          //   //   ),
          //   // ),
          // ),

          SliverAppBar(
            backgroundColor: PrimaryColors().white,
            elevation: 0.0,
            pinned: true,
            automaticallyImplyLeading: true,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
            ),
            title: _isSearching
                ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              onChanged: _filterProducts,
            )
                : Text(
              '',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (_isSearching) {
                    _stopSearch();
                  } else {
                    _startSearch();
                  }
                },
                icon: Icon(
                  _isSearching ? Icons.clear : Icons.search,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  16.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flexible(
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 15.0),
                      //     child: Text(
                      //       "",
                      //       // "$productListCount products",
                      //       style: const TextStyle(
                      //         color: Color(0xFF333333),
                      //         fontSize: 16,
                      //         fontFamily: poppinsSemiBold,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                      //   child: const SizedBox(
                      //     width: 70,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.end,
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Icon(Icons.filter_alt_outlined)
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  24.ph,
                  FutureBuilder(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (_filteredProducts.isNotEmpty) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            productId: _filteredProducts[index].id!),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    elevation: 0.0,
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // CarouselSlider.builder(
                                        //   itemCount: _filteredProducts[index].images!.length,
                                        //   options: CarouselOptions(
                                        //     height: 140,
                                        //     scrollDirection: Axis.horizontal,
                                        //     viewportFraction: 1,
                                        //     autoPlayCurve: Curves.ease,
                                        //     autoPlayAnimationDuration: const Duration(milliseconds: 600),
                                        //     onPageChanged: (index, reason) {  // This is necessary to update the indicator
                                        //       setState(() {
                                        //         pageIndex = index;  // Update the pageIndex on slide change
                                        //       });
                                        //     },
                                        //   ),
                                        //   itemBuilder: (BuildContext context, int imageindex, int realIndex) {
                                        //     return Stack(
                                        //       children: [
                                        //         Container(
                                        //           width: MediaQuery.of(context).size.width,
                                        //           height: 140,
                                        //           margin: const EdgeInsets.symmetric(horizontal: 5),
                                        //           decoration: BoxDecoration(
                                        //             borderRadius: BorderRadius.circular(20.0),
                                        //             image: DecorationImage(
                                        //               image: NetworkImage(_filteredProducts[index].images![imageindex].imageUrl.toString()),
                                        //               fit: BoxFit.contain,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //         Align(
                                        //           alignment: Alignment.bottomCenter,
                                        //           child: Padding(
                                        //             padding: const EdgeInsets.only(bottom: 10.0),
                                        //             child: CarouselIndicator(
                                        //               count: _filteredProducts[index].images!.length,
                                        //               index: pageIndex,
                                        //               activeColor: Colors.white,
                                        //               color: Colors.black,
                                        //               height: 8,
                                        //               width: 8,
                                        //               cornerRadius: 10,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     );
                                        //   },
                                        // ),
                                        CarouselSlider.builder(
                                          itemCount: _filteredProducts[index].images!.length,
                                          options: CarouselOptions(
                                            height: 240,
                                            scrollDirection: Axis.horizontal,
                                            viewportFraction: 1,
                                            autoPlayCurve: Curves.ease,
                                            autoPlayAnimationDuration: const Duration(milliseconds: 600),
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                pageIndex = index; // Update the pageIndex on slide change
                                              });
                                            },
                                          ),
                                          itemBuilder: (BuildContext context, int imageindex, int realIndex) {
                                            return Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 240,
                                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                    // borderRadius: BorderRadius.circular(20.0),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        _filteredProducts[index].images![imageindex].imageUrl.toString(),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: 10.0),
                                                    child: CarouselIndicator(
                                                      count: _filteredProducts[index].images!.length,
                                                      index: pageIndex,
                                                      activeColor: Colors.white,
                                                      color: Colors.black,
                                                      height: 8,
                                                      width: 8,
                                                      cornerRadius: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        12.ph,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _filteredProducts[index]
                                                        .name
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Color(0xFF1D2939),
                                                      fontSize: 18,
                                                      fontFamily: serifRegular,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (favoriteDataList
                                                          .contains(_filteredProducts[
                                                                  index]
                                                              .id
                                                              .toString())) {
                                                        removeWishlistDeleteApi(
                                                                _filteredProducts[
                                                                        index]
                                                                    .id!)
                                                            .then((value) {
                                                          favoriteDataList.remove(
                                                              _filteredProducts[index]
                                                                  .id
                                                                  .toString());
                                                          setFavouriteId(
                                                              favoriteDataList);
                                                          setState(() {});
                                                        });
                                                      } else {
                                                        addToWishlistPostApi(
                                                                _filteredProducts[
                                                                        index]
                                                                    .id!)
                                                            .then((value) {
                                                          favoriteDataList.add(
                                                              _filteredProducts[index]
                                                                  .id
                                                                  .toString());
                                                          setFavouriteId(
                                                              favoriteDataList);
                                                          showSnackBar(context,
                                                              "Added to Wishlist");
                                                          setState(() {});
                                                        });
                                                      }
                                                    },
                                                    child: favoriteDataList
                                                            .contains(
                                                                _filteredProducts[
                                                                        index]
                                                                    .id
                                                                    .toString())
                                                        ? const Icon(
                                                            Icons
                                                                .favorite_rounded,
                                                            color: Colors.red,
                                                          )
                                                        : const Icon(Icons
                                                            .favorite_border_rounded),
                                                  )
                                                ],
                                              ),
                                              // 8.ph,
                                              // Row(
                                              //   crossAxisAlignment:
                                              //       CrossAxisAlignment.center,
                                              //   children: [
                                              //     SvgPicture.asset(
                                              //         ImageConstant.star),
                                              //     2.pw,
                                              //     Text.rich(
                                              //       TextSpan(
                                              //         children: [
                                              //           TextSpan(
                                              //             text: _filteredProducts[index].rating.toString(),
                                              //             style: const TextStyle(
                                              //               color: Color(
                                              //                   0xFFE38E31),
                                              //               fontSize: 14,
                                              //               fontFamily:
                                              //                   poppinsSemiBold,
                                              //               fontWeight:
                                              //                   FontWeight.w600,
                                              //             ),
                                              //           ),
                                              //           TextSpan(
                                              //             // text:" (${_filteredProducts[index].timesRated}) • ${_filteredProducts[index].timesBooked} +booked",
                                              //             text:" (${_filteredProducts[index].timesRated})",
                                              //             // text:
                                              //             //     ' (21) • 1K+ booked',
                                              //             style: const TextStyle(
                                              //               color: Color(
                                              //                   0xFF595959),
                                              //               fontSize: 14,
                                              //               fontFamily:
                                              //                   poppinsMedium,
                                              //               fontWeight:
                                              //                   FontWeight.w400,
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              8.ph,
                                              Row(
                                                children: [
                                                  //  Text(
                                                  //   'KD ${_filteredProducts[index].originalPrice}',
                                                  //   style: TextStyle(
                                                  //     color: Color(0xFF9B9B9B),
                                                  //     fontSize: 14,
                                                  //     fontFamily:
                                                  //         poppinsRegular,
                                                  //     fontWeight:
                                                  //         FontWeight.w400,
                                                  //     decoration: TextDecoration
                                                  //         .lineThrough,
                                                  //   ),
                                                  // ),
                                                  // 10.pw,
                                                  Text(
                                                    // 'KD 80.00',
                                                    _filteredProducts[index].pricePerDay != null ? 'KD ${_filteredProducts[index].pricePerDay}' : '',
                                                    style: const TextStyle(
                                                      color: Color(0xFF333333),
                                                      fontSize: 16,
                                                      fontFamily: poppinsBold,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  if(_filteredProducts[index].priceType == "price_per_day" && _filteredProducts[index].productType != "Variation")
                                                    const Text(
                                                    ' per day',
                                                    style: TextStyle(
                                                      color: Color(0xFF333333),
                                                      fontSize: 14,
                                                      fontFamily:
                                                          poppinsRegular,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              // Row(
                                              //   mainAxisAlignment: MainAxisAlignment.start, // Aligns children to the left
                                              //   children: [
                                              //     if (_filteredProducts[index].checkOutType!.isNotEmpty)
                                              //       RichText(
                                              //         text: TextSpan(
                                              //           children: [
                                              //             WidgetSpan(
                                              //               alignment: PlaceholderAlignment.middle,
                                              //               child: Container(
                                              //                 width: 6, // Adjust size as necessary
                                              //                 height: 6, // Adjust size as necessary
                                              //                 margin: EdgeInsets.symmetric(horizontal: 4), // Space around the dot
                                              //                 decoration: BoxDecoration(
                                              //                   color: _filteredProducts[index].checkOutType == "Available" ? Color(0xFF00FF00) : Color(0xFFFFA500),
                                              //                   shape: BoxShape.circle,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             TextSpan(
                                              //               text: _filteredProducts[index].checkOutType,
                                              //               style: TextStyle(
                                              //                 color: _filteredProducts[index].checkOutType == "Available" ? Color(0xFF00FF00) : Color(0xFFFFA500),
                                              //                 fontSize: 14,
                                              //                 fontFamily: 'PoppinsRegular',
                                              //                 fontWeight: FontWeight.w400,
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //   ],
                                              // ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: ShapeDecoration(
                                                  color: _filteredProducts[index].checkOutType == "Available"
                                                      ? const Color(0xFF85CB33)
                                                      : _filteredProducts[index].checkOutType == "Waiting for confirmation"
                                                      ? const Color(0xFFFFA500) // Orange
                                                      : const Color(0xFFFF0000), // Red
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: _filteredProducts[index].checkOutType == "Available"
                                                            ? const Color(0xFF85CB33)
                                                            : _filteredProducts[index].checkOutType == "Waiting for confirmation"
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
                                                      _filteredProducts[index].checkOutType ?? "",
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


                                            ],
                                          ),
                                        ),
                                        24.ph,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "No Data Found",
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }
                        }
                        return const CustomProgressBar();
                      }),
                  20.ph,
                ],
              ),
            ),
          )
        ],
      ),
    ),);
  }
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredProducts = productList;
    });
  }
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = productList;
      } else {
        _filteredProducts = productList
            .where((product) => (product.name ?? "").toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}
