import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/get_wishlist_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/ui/pages/Categories/detail_page.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/static_words.dart';
import '../../../../theme/theme_helper.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({Key? key}) : super(key: key);

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  List<GetWishlistModel> wishlistList = [];
  List<String> favoriteDataList = [];

  Future<List<GetWishlistModel>> getWishlistApi() async {

    String token = await getToken();
    favoriteDataList = await futuregetFavouriteId();

    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.wishlist}"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    var responseData = jsonDecode(response.body.toString());
    wishlistList.clear();
    try {
      if (response.statusCode == 200) {
        printMsgTag("getWishlistApi ResponseData", responseData);
        for (Map i in responseData) {
          var data = GetWishlistModel.fromJson(i);
          if(data.product != null) {
            wishlistList.add(GetWishlistModel.fromJson(i));
          }
        }

        return wishlistList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getWishlistApi catch", exception.toString());
    }

    return wishlistList;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 0.0,
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getWishlistApi(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (wishlistList.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: wishlistList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => navigateAddScreen(
                          context,
                          DetailPage(
                              productId: wishlistList[index].product!.id!)),
                      minVerticalPadding: 15,
                      leading: Container(
                        width: 64,
                        height: 84,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              wishlistList[index]
                                  .product!
                                  .images![0]
                                  .imageUrl
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
                            wishlistList[index].product!.name.toString(),
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
                              // const Text(
                              //   'KD 120.00',
                              //   style: TextStyle(
                              //     color: Color(0xFF9B9B9B),
                              //     fontSize: 14,
                              //     fontFamily: 'Poppins',
                              //     fontWeight: FontWeight.w400,
                              //     decoration: TextDecoration.lineThrough,
                              //   ),
                              // ),
                              // 10.pw,
                              Text(
                                // 'KD ${wishlistList[index].product!.pricePerDay ?? ""}',
                                wishlistList[index].product!.pricePerDay != null ? 'KD ${wishlistList[index].product!.pricePerDay ?? ""}' : '',
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
                      subtitle: GestureDetector(
                        onTap: () {
                          ModelUtils.showCustomAlertDialog(
                            context,
                            title: "Wishlist Remove",
                            content: const Text(
                                "Are you sure want to remove from wishlist"),
                            okBtnFunction: () {
                              removeWishlistDeleteApi(
                                      wishlistList[index].product!.id!)
                                  .then((value) {
                                if (value['message'] ==
                                    "Product removed from wishlist") {
                                  favoriteDataList.remove(wishlistList[index]
                                      .product!
                                      .id
                                      .toString());
                                  setFavouriteId(favoriteDataList);
                                  Navigator.pop(context);
                                  showSnackBar(context, value['message']);
                                  setState(() {});
                                }
                              });
                            },
                          );
                        },
                        child: const Text(
                          "Remove",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(thickness: 1);
                  },
                ),
              );
            } else {
              return const Center(
                child: Text("Your wishlist is empty"),
              );
            }
          }
          // return const CustomProgressBar();
          return const Text(
            ""
          );
        },
      ),
    );
  }
}
