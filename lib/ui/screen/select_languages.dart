import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/image_constants.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/ui/screen/onboard_screen.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String selectedLanguage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select your language',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 24,
                    fontFamily: serifRegular,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            32.ph,
            GestureDetector(
              onTap: () {
                setLanguage("arabic");
                setState(() {
                  selectedLanguage = "arabic";
                });
              },
              child: Container(
                width: 124,
                height: 124,
                decoration: ShapeDecoration(
                  // color: const Color(0xFFEAF5F5),
                  color: selectedLanguage == "arabic"
                      ? const Color(0xFFEAF5F5)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: selectedLanguage == "arabic"
                          ? const Color(0xFF2A9DA0)
                          : const Color(0xFFEDEDED),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: [
                    selectedLanguage == "arabic"
                        ? const BoxShadow(
                            color: Color(0x26264D4E),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          )
                        : const BoxShadow(color: Colors.transparent)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageConstant.arabic),
                    8.ph,
                    const Text(
                      'Arabic',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
            24.ph,
            GestureDetector(
              onTap: () {
                setLanguage("english");
                setState(() {
                  selectedLanguage = "english";
                });
              },
              child: Container(
                width: 124,
                height: 124,
                decoration: ShapeDecoration(
                  color: selectedLanguage == "english"
                      ? const Color(0xFFEAF5F5)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: selectedLanguage == "english"
                          ? const Color(0xFF2A9DA0)
                          : const Color(0xFFEDEDED),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: [
                    selectedLanguage == "english"
                        ? const BoxShadow(
                            color: Color(0x26264D4E),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          )
                        : const BoxShadow(color: Colors.transparent)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageConstant.english),
                    8.ph,
                    const Text(
                      'English',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: poppinsSemiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (selectedLanguage.isNotEmpty) {
                navigateAddScreen(context, const OnBoardScreen());
              } else {
                ModelUtils.showSimpleAlertDialog(
                  context,
                  title: const Text('Happy bash'),
                  content: "Please select language",
                  okBtnFunction: () {
                    Navigator.pop(context);
                  },
                );
              }
            },
            child: Container(
              width: 312,
              height: 50,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A9DA0),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Center(
                child: Text(
                  'CONFIRM AND CONTINUE',
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
        ],
      ),
    );
  }
}
