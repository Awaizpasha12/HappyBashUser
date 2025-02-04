import 'package:flutter/material.dart';
import 'package:happy_bash/core/reusable.dart';

import '../../../../core/constants/static_words.dart';
import '../../../../theme/theme_helper.dart';

class FAOSPage extends StatefulWidget {
  const FAOSPage({Key? key}) : super(key: key);

  @override
  State<FAOSPage> createState() => _FAOSPageState();
}

class _FAOSPageState extends State<FAOSPage> {
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
          'FAQs',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            20.ph,
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: const ExpansionTile(
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                // childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  "I have booked an event but not received any confirmation?",
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 12,
                    fontFamily: poppinsMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "When the product/service you choose shows it's unavailable, you can join the waiting list so a representative from Happy Bash can contact you if the item gets available on the date you chose.",
                      style: TextStyle(
                        color: Color(0xFF595959),
                        fontSize: 12,
                        fontFamily: poppinsMedium,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(thickness: 0.7),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: const ExpansionTile(
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                // childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  "What is the refund policy?",
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 12,
                    fontFamily: poppinsMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "When the product/service you choose shows it's unavailable, you can join the waiting list so a representative from Happy Bash can contact you if the item gets available on the date you chose.",
                      style: TextStyle(
                        color: Color(0xFF595959),
                        fontSize: 12,
                        fontFamily: poppinsMedium,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(thickness: 0.7),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: const ExpansionTile(
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                childrenPadding: EdgeInsets.zero,
                // childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  "The event is postponed and I have updated on the app but still showing the same",
                  style: TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 12,
                    fontFamily: poppinsMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "When the product/service you choose shows it's unavailable, you can join the waiting list so a representative from Happy Bash can contact you if the item gets available on the date you chose.",
                      style: TextStyle(
                        color: Color(0xFF595959),
                        fontSize: 12,
                        fontFamily: poppinsMedium,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
