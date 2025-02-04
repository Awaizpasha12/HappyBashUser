import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/core/utils/size_utils.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/bottom_navigation_screen.dart';
import 'package:happy_bash/ui/screen/login_screen.dart';
import 'package:happy_bash/ui/screen/quotation_screen.dart';
import 'package:happy_bash/ui/screen/sign_up_screen.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the device width
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // The main content is scrollable
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Use a Stack for the gradient container and top guest button
            Stack(
              children: [
                Container(
                  width: width,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, -1.00),
                      end: Alignment(0, 1),
                      colors: [Color(0xFFEAF5F5), Color(0x00EAF5F5)],
                    ),
                  ),
                ),
                // Position the guest button at the top-right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => navigateReplaceAll(
                        context,
                        BottomNavigationBarScreen(selectedIndex: 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Continue as guest",
                            style: TextStyle(
                              color: PrimaryColors().primarycolor,
                              fontSize: 14,
                              fontFamily: poppinsSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Image.asset(ImageConstant.forwardIcon)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Add vertical spacing as needed
            // 50.ph,
            // Main illustration
            SvgPicture.asset(ImageConstant.onBording),
            // The headline using RichText
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Easily',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Color(0xFF2A9DA0),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  Quickly',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Color(0xFF2A9DA0),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  Happily',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Color(0xFF2A9DA0),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                20.ph,
                const Text(
                  'Elevate your event planning for every occasion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 22,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Add extra spacing at the bottom to ensure
            // the scrollable area does not hide behind the fixed buttons.
            const SizedBox(height: 100),
          ],
        ),
      ),
      // Fixed bottom buttons using the bottomNavigationBar property.
      bottomNavigationBar: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE2E2E2),
              blurRadius: 10,
              offset: Offset(0, -2),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () {
                  navigateAddScreen(context, const LoginScreen());
                },
                child: Container(
                  width: 150,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: PrimaryColors().primarycolor,
                      ),
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        color: PrimaryColors().primarycolor,
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  navigateAddScreen(context, const SignUpScreen());
                },
                child: Container(
                  width: 150,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: PrimaryColors().primarycolor,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Center(
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
