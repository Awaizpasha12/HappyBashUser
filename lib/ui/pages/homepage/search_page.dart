import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/ui/pages/Categories/detail_page.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/shared_preferences_utils.dart';
import '../../../core/constants/static_words.dart';
import '../../../core/reusable.dart';
import '../../../models/product_model.dart';
import '../../../network/base_url.dart';
import '../../../theme/theme_helper.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key, required this.searchValue, required this.eventDate});

  String searchValue;
  String eventDate;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ProductModel> productList = [];
  List<ProductModel> searchProductList = [];

  Future<List<ProductModel>> productGetApi() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.products}"),
      // headers: await getHeaders(),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        // "Authorization": "Bearer $token",
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
        return productList;
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("productGetApi catch", exception.toString());
    }

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        titleSpacing: 0.0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.searchValue,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 15,
                fontFamily: poppinsSemiBold,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.eventDate,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 12,
                fontFamily: poppinsRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: productGetApi(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (widget.searchValue.isNotEmpty) {
              searchProductList = productList
                  .where((element) => element.name!
                      .toLowerCase()
                      .contains(widget.searchValue.toLowerCase()))
                  .toList();
            }
            return widget.searchValue.isNotEmpty
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: searchProductList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          navigateAddScreen(
                              context,
                              DetailPage(
                                  productId: searchProductList[index].id!));
                        },
                        dense: true,
                        horizontalTitleGap: 10,
                        leading: SizedBox(
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              searchProductList[index]
                                  .images![0]
                                  .imageUrl
                                  .toString(),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        title: Text(
                          searchProductList[index].name.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: poppinsMedium,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            // const Text(
                            //   'KD 120.00',
                            //   style: TextStyle(
                            //     color: Color(0xFF9B9B9B),
                            //     fontSize: 14,
                            //     fontFamily: poppinsRegular,
                            //     fontWeight: FontWeight.w400,
                            //     decoration: TextDecoration.lineThrough,
                            //   ),
                            // ),
                            // 10.pw,
                            Text(
                              // 'KD 80.00',
                              'KD ${searchProductList[index].pricePerDay}',
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if(searchProductList[index].priceType == "price_per_day")
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
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 1);
                    },
                  )
                : const Center(
                    child: Text("No result found"),
                  );
          }
          return const CustomProgressBar();
        },
      ),
    );
  }
}
