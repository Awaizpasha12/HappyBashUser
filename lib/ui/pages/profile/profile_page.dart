import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/profile/WishList/whishlist_page.dart';
import 'package:happy_bash/ui/pages/profile/YourProfile/your_profile_page.dart';
import 'package:happy_bash/ui/pages/profile/address/address_page.dart';
import 'package:happy_bash/ui/pages/profile/contact/contact_us.dart';
import 'package:happy_bash/ui/pages/profile/setting/settings_page.dart';
import 'package:happy_bash/ui/screen/login_screen.dart';
import 'package:happy_bash/ui/screen/onboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/base_url.dart';
import 'FAQs/faqs_pages.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences prefs;
  Future<SharedPreferences> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  void deleteAccount() async {
    // String token = "2|S4EsXOMBw7d8I6jf7bNDjnzbVAq6rtzSVCyX0qnw40ebdc41";
    String token = await getToken();
    final response = await http.delete(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.deleteAccount}"),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    try {
      if (response.statusCode == 200) {
        setIsUserLogin(false);
        setLocation("");
        setToken("");
        setIsFcmRegistered(false);
        navigateReplaceAll(context,
            const OnBoardScreen());
      } else {
        // printMsgTag("Error meaasge", responseData["Message"]);
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("addToCartPostApi catch", exception.toString());
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 0.0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
          future: getSharedPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              prefs = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.ph,
                    getIsUserLogin(prefs)
                        ?
                        //const Padding(
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: 20.0, vertical: 10),
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           "Hello",
                        //           style: TextStyle(
                        //             fontFamily: poppinsBold,
                        //             fontSize: 20,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   )
                        Container()
                        : Container(
                            width: width,
                            height: 56,
                            color: const Color(0xFFEAF5F5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Log in or SIgn up',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: poppinsSemiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    navigateAddScreen(
                                        context, const LoginScreen());
                                  },
                                  color: const Color(0xFF2A9DA0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: const Text(
                                    'LOGIN/SIGNUP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16.0),
                      child: Container(
                        width: width,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            getIsUserLogin(prefs)
                                ? profileListTile(
                                    onTap: () => navigateAddScreen(
                                        context, const YourProfilePage()),
                                    image: "assets/icons/user_2.svg",
                                    title: "Your profile",
                                    isIcon: true,
                                    belowLine: true,
                                  )
                                : Container(),
                            // const Divider(thickness: 1),
                            getIsUserLogin(prefs)
                                ? profileListTile(
                                    onTap: () => navigateAddScreen(
                                        context, const AddressPage()),
                                    image: "assets/icons/user_2.svg",
                                    title: "My address",
                                    isIcon: true,
                                    belowLine: true,
                                  )
                                : Container(),
                            profileListTile(
                              onTap: () => navigateAddScreen(
                                  context, const WishListPage()),
                              image: "assets/icons/Heart.svg",
                              title: "My wishlist",
                              isIcon: true,
                              belowLine: true,
                            ),
                            // const Divider(thickness: 1),
                            profileListTile(
                              onTap: () =>
                                  navigateAddScreen(context, const FAOSPage()),
                              image: "assets/icons/info_circle.svg",
                              title: "FAQ’s",
                              isIcon: true,
                              belowLine: true,
                            ),
                            // const Divider(thickness: 1),
                            profileListTile(
                              onTap: () => navigateAddScreen(
                                  context, const ContactUsPage()),
                              image: "assets/icons/Phone.svg",
                              title: "Contact us",
                              isIcon: true,
                              belowLine: true,
                            ),
                            // const Divider(thickness: 1),
                            profileListTile(
                              onTap: () => navigateAddScreen(context, const SettingsPage()),
                              image: "assets/icons/Setting.svg",
                              title: "Settings",
                              isIcon: true,
                              belowLine: false,
                            ),
                            getIsUserLogin(prefs)
                                ? Column(
                                    children: [
                                      const Divider(thickness: 1),
                                      ListTile(
                                        onTap: () {

                                          ModelUtils.showCustomAlertDialog(
                                            context,
                                            title: "Logout",
                                            content: const Text(
                                                'Are you sure want to logout'),
                                            okBtnFunction: () {
                                              setIsUserLogin(false);
                                              setLocation("");
                                              setToken("");
                                              setIsFcmRegistered(false);
                                              navigateReplaceAll(context,
                                                  const OnBoardScreen());
                                            },
                                          );
                                        },
                                        leading:
                                            const Icon(Icons.logout_rounded),
                                        title: const Text(
                                          "Logout",
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 14,
                                            fontFamily: poppinsMedium,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            getIsUserLogin(prefs)
                                ? Column(
                              children: [
                                const Divider(thickness: 1),
                                ListTile(
                                  onTap: () {

                                    ModelUtils.showCustomAlertDialog(
                                      context,
                                      title: "Delete Account",
                                      content: const Text(
                                          'Are you want to delete the account?'),
                                      okBtnFunction: () {
                                        deleteAccount();
                                      },
                                    );
                                  },
                                  leading:
                                  const Icon(Icons.delete_forever),
                                  title: const Text(
                                    "Delete Account",
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: poppinsMedium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Container()

                          ],
                        ),
                      ),
                    ),
                    50.ph,
                    Opacity(
                      opacity: 0.05,
                      child: Image.asset(
                        "assets/images/Isolation_Mode.png",
                        width: 152,
                        height: 50,
                        color: const Color.fromRGBO(89, 89, 89, 1),
                      ),
                    )
                  ],
                ),
              );
            }
            return const CustomProgressBar();
          }),
    );
  }

  Widget profileListTile({
    required String image,
    required String title,
    required bool isIcon,
    required bool belowLine,
    required Function() onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: SvgPicture.asset(image, width: 20, height: 20),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontFamily: poppinsMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: isIcon
              ? SvgPicture.asset(ImageConstant.rightArrow,
                  width: 20, height: 20)
              : null,
        ),
        belowLine ? const Divider(thickness: 1) : Container(),
      ],
    );
  }
}
