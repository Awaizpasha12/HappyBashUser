import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/models/sub_categories_model.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/Categories/listing_page.dart';

import 'package:http/http.dart' as http;

import '../../../core/constants/navigator.dart';
import '../../../core/reusable.dart';
import '../../../network/base_url.dart';

class SubCategoriesPage extends StatefulWidget {
  const SubCategoriesPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  final int categoryId;
  final String categoryName;

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  List<SubCategoriesModel> subCategoriesList = [];

  Future<List<SubCategoriesModel>> subCategoriesGetApi() async {
    int categoriesId = widget.categoryId;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new,
                color: PrimaryColors().black900)),
        title: Text(
          widget.categoryName,
          style: TextStyle(color: PrimaryColors().black900),
        ),
      ),
      body: FutureBuilder(
        future: subCategoriesGetApi(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (subCategoriesList.isNotEmpty) {
              if (widget.categoryId == 1) {
                return Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: subCategoriesList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: SizedBox(
                              height: 100,
                              child: GestureDetector(
                                onTap: () {
                                  navigateAddScreen(
                                      context,
                                      EventsDetailPage(
                                        imageUrl: subCategoriesList[index]
                                            .imageUrl
                                            .toString(),
                                        headerName: subCategoriesList[index]
                                            .name
                                            .toString(),
                                        subcategoriesId:
                                            subCategoriesList[index].id!,
                                      ));
                                },
                                child: Card(
                                  surfaceTintColor: Colors.transparent,
                                  elevation: 3.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              // 'Popcorn',
                                              subCategoriesList[index]
                                                  .name
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Color(0xFF1D2939),
                                                fontSize: 16,
                                                fontFamily: serifRegular,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            2.ph,
                                            Text(
                                              '10 products and services',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontFamily: poppinsRegular,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 100,
                                        width: 120,
                                        // width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(13),
                                            bottomRight: Radius.circular(13),
                                          ),
                                          child: Image.network(
                                            // "assets/images/dish-3.jpg",
                                            subCategoriesList[index]
                                                .imageUrl
                                                .toString(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    20.ph,
                  ],
                );
              } else {
                return Column(
                  children: [
                    Flexible(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: subCategoriesList.length,
                        // itemCount: 4,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          mainAxisExtent: 115,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              navigateAddScreen(
                                  context,
                                  EventsDetailPage(
                                    imageUrl: subCategoriesList[index]
                                        .imageUrl
                                        .toString(),
                                    headerName: subCategoriesList[index]
                                        .name
                                        .toString(),
                                    subcategoriesId:
                                        subCategoriesList[index].id!,
                                  ));
                            },
                            // child: Column(
                            //   children: [
                            //     // Container(
                            //     //   width: 48,
                            //     //   height: 48,
                            //     //   decoration: const ShapeDecoration(
                            //     //     color: Color(0xFFFCF4EA),
                            //     //     shape: CircleBorder(),
                            //     //   ),
                            //     //   // child: Image.asset(discover[index]['image']),
                            //     //   child: SvgPicture.asset(discover[index]['image']),
                            //     // ),
                            //     SvgPicture.asset(discover[index]['image']),
                            //     5.ph,
                            //     Text(
                            //       // discover[index]['title'],
                            //       categoriesList[index].name.toString(),
                            //       textAlign: TextAlign.center,
                            //       style: const TextStyle(
                            //         color: Color(0xFF333333),
                            //         fontSize: 14,
                            //         fontFamily: poppinsMedium,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     )
                            //   ],
                            // ),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              height: 110,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x330D3131),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  subCategoriesList[index].imageUrl != null
                                      ? SizedBox(
                                          height: 74,
                                          width: double.infinity,
                                          child: Image.network(
                                            // "assets/images/dish-3.jpg",
                                            subCategoriesList[index]
                                                .imageUrl
                                                .toString(),
                                            fit: BoxFit.fill,
                                          ),
                                          //     CachedNetworkImage(
                                          //   imageUrl: subCategoriesList[index]
                                          //       .imageUrl!,
                                          //   imageBuilder:
                                          //       (context, imageProvider) =>
                                          //           Container(
                                          //     decoration: BoxDecoration(
                                          //       borderRadius:
                                          //           BorderRadius.circular(10),
                                          //       image: DecorationImage(
                                          //         image: imageProvider,
                                          //         fit: BoxFit.fill,
                                          //       ),
                                          //     ),
                                          //   ),
                                          //   placeholder: (context, url) {
                                          //     // const CustomProgressBar(),
                                          //     return Padding(
                                          //       padding:
                                          //           const EdgeInsets.all(8.0),
                                          //       // child: Image.asset(
                                          //       //   Assets.noImage,
                                          //       //   width: 5,
                                          //       //   color: textColor,
                                          //       //   fit: BoxFit.fill,
                                          //       // ),
                                          //       child: Container(),
                                          //     );
                                          //   },
                                          //   errorWidget: (context, url, error) {
                                          //     return Padding(
                                          //       padding:
                                          //           const EdgeInsets.all(8.0),
                                          //       // child: Image.asset(
                                          //       //   Assets.noImage,
                                          //       //   width: 5,
                                          //       //   color: textColor,
                                          //       //   fit: BoxFit.fill,
                                          //       // ),
                                          //       child: Container(),
                                          //     );
                                          //   },
                                          // ),
                                          //
                                        )
                                      : const SizedBox(
                                          height: 74,
                                          width: double.infinity,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8.0),
                                    child: Center(
                                      child: Text(
                                        // 'Popcorn',
                                        subCategoriesList[index].name.toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF1D2939),
                                          fontSize: 16,
                                          fontFamily: serifRegular,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    20.ph,
                  ],
                );
              }
            } else {
              return const Center(
                child: Text(
                  "No data Found",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
          }
          return const CustomProgressBar();
        },
      ),
      // body: Column(
      //   children: [
      //     Flexible(
      //       child: GridView.builder(
      //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      //         shrinkWrap: true,
      //         // physics: const NeverScrollableScrollPhysics(),
      //         scrollDirection: Axis.vertical,
      //         // itemCount: subCategoriesList.length,
      //         itemCount: 4,
      //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: 2,
      //           mainAxisSpacing: 20,
      //           crossAxisSpacing: 20,
      //           mainAxisExtent: 115,
      //         ),
      //         itemBuilder: (context, index) {
      //           return GestureDetector(
      //             onTap: () {
      //               navigateAddScreen(
      //                   context,
      //                   EventsDetailPage(
      //                     imageUrl: "assets/images/dish-3.jpg",
      //                     // headerName: subCategoriesList[index].name.toString(),
      //                     headerName: "HeaderName",
      //                   ));
      //             },
      //             // child: Column(
      //             //   children: [
      //             //     // Container(
      //             //     //   width: 48,
      //             //     //   height: 48,
      //             //     //   decoration: const ShapeDecoration(
      //             //     //     color: Color(0xFFFCF4EA),
      //             //     //     shape: CircleBorder(),
      //             //     //   ),
      //             //     //   // child: Image.asset(discover[index]['image']),
      //             //     //   child: SvgPicture.asset(discover[index]['image']),
      //             //     // ),
      //             //     SvgPicture.asset(discover[index]['image']),
      //             //     5.ph,
      //             //     Text(
      //             //       // discover[index]['title'],
      //             //       categoriesList[index].name.toString(),
      //             //       textAlign: TextAlign.center,
      //             //       style: const TextStyle(
      //             //         color: Color(0xFF333333),
      //             //         fontSize: 14,
      //             //         fontFamily: poppinsMedium,
      //             //         fontWeight: FontWeight.w500,
      //             //       ),
      //             //     )
      //             //   ],
      //             // ),
      //             child: Container(
      //               clipBehavior: Clip.antiAlias,
      //               height: 110,
      //               decoration: ShapeDecoration(
      //                 color: Colors.white,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(16),
      //                 ),
      //                 shadows: const [
      //                   BoxShadow(
      //                     color: Color(0x330D3131),
      //                     blurRadius: 4,
      //                     offset: Offset(0, 2),
      //                     spreadRadius: 0,
      //                   )
      //                 ],
      //               ),
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.start,
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   SizedBox(
      //                     height: 74,
      //                     width: double.infinity,
      //                     child: Image.asset(
      //                       "assets/images/dish-3.jpg",
      //                       fit: BoxFit.fill,
      //                     ),
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.symmetric(
      //                         vertical: 8, horizontal: 8.0),
      //                     child: Text(
      //                       'Popcorn',
      //                       // subCategoriesList[index].name.toString(),
      //                       style: const TextStyle(
      //                         color: Color(0xFF1D2939),
      //                         fontSize: 16,
      //                         fontFamily: serifRegular,
      //                         fontWeight: FontWeight.w400,
      //                       ),
      //                       overflow: TextOverflow.ellipsis,
      //                     ),
      //                   )
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //     20.ph,
      //   ],
      // ),
    );
  }
}
