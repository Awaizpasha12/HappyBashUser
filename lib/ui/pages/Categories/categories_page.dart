import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/categories_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/ui/pages/Categories/sub_categories.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/static_words.dart';
import '../../../theme/theme_helper.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> discover = [
    {"image": "assets/icons/category_events_cp.svg", "title": "Events"},
    {"image": "assets/icons/category_food_cp.svg", "title": "Food"},
    {"image": "assets/icons/category_activity_cp.svg", "title": "Activity"},
    {"image": "assets/icons/category_snacks_cp.svg", "title": "Snacks"},
    {"image": "assets/icons/category_shows_cp.svg", "title": "Shows"},
    {"image": "assets/icons/category_dj_cp.svg", "title": "DJ"},
    {"image": "assets/icons/category_host_cp.svg", "title": "Host"},
  ];

  List<CategoriesModel> categoriesList = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 1.0,
        title: const Text(
          'Category',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
        future: categoriesGetApi(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 126,
                ),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                physics: const BouncingScrollPhysics(),
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      navigateAddScreen(
                        context,
                        SubCategoriesPage(
                          categoryId: categoriesList[index].id!,
                          categoryName: categoriesList[index].name.toString(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 80.0, // Set a consistent height
                            width: double.infinity, // Set to match the container's width
                            decoration: BoxDecoration(
                              color: Colors.white, // Optional: Add a background color
                              borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                            ),
                            child: Image.network(
                              categoriesList[index].imageUrl ?? "https://example.com/default.png",
                              fit: BoxFit.fill, // Ensures the image covers the container
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                return Icon(Icons.error); // Show an error icon if loading fails
                              },
                            ),
                          ),
                          Text(
                            categoriesList[index].name.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontFamily: poppinsMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const CustomProgressBar();
        },
      ),
    );
  }
}
