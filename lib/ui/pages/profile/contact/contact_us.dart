import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_bash/core/reusable.dart';

import '../../../../core/constants/static_words.dart';
import '../../../../theme/theme_helper.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 1.0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: PrimaryColors().black900,
            size: 20,
          ),
        ),
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'We would love to hear from you. You can get back to us via Call, Email or WhatsApp.',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                fontFamily: poppinsRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
            24.ph,
            SizedBox(
              height: 80,
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icons/whatsapp.svg"),
                        12.pw,
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Color(0xFF1D2939),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Ask your queries anytime on +965 96662062',
                              style: TextStyle(
                                color: Color(0xFF595959),
                                fontSize: 12,
                                fontFamily: poppinsRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            24.ph,
            SizedBox(
              height: 110,
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset("assets/icons/call.svg"),
                        12.pw,
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Call',
                              style: TextStyle(
                                color: Color(0xFF1D2939),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                'Call us at (+965) 96662062. We are\navailable in working days from 09:00 AM\n to 05:00 PM',
                                style: TextStyle(
                                  color: Color(0xFF595959),
                                  fontSize: 12,
                                  fontFamily: poppinsRegular,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            24.ph,
            SizedBox(
              height: 80,
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icons/email.svg"),
                        12.pw,
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xFF1D2939),
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Email us at info@thehappybash.com',
                              style: TextStyle(
                                color: Color(0xFF595959),
                                fontSize: 12,
                                fontFamily: poppinsRegular,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
