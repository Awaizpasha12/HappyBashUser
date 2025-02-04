import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/dialog_box.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/shared_preferences_utils.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/static_words.dart';
import '../../../../theme/theme_helper.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notificationList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotificationData();
  }

  Future<void> fetchNotificationData() async {
    setState(() {
      isLoading = true;
    });

    String token = await getToken();

    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.notification}"),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      var responseData = jsonDecode(response.body.toString());
      notificationList.clear();

      if (response.statusCode == 200) {
        printMsgTag("getNotificationApi ResponseData", responseData);
        for (Map<String, dynamic> item in responseData['data']) {
          var notification = NotificationModel.fromJson(item);
          notificationList.add(notification);
        }
      } else {
        throw Exception();
      }
    } catch (exception) {
      printMsgTag("getNotificationApi catch", exception.toString());
    } finally {
      setState(() {
        isLoading = false;
        // notificationList.add(NotificationModel(
        //   id: 999,
        //   title: "Dummy Notification",
        //   message: "This is a dummy notification to test the UI.",
        //   createdAt: "12-01-2025",
        // ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 0.0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationList.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: notificationList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {},
              minVerticalPadding: 15,
              title: Text(
                notificationList[index].title,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: poppinsSemiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationList[index].message,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notificationList[index].createdAt,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(thickness: 1);
          },
        ),
      )
          : const Center(
        child: Text("You have no notifications"),
      ),
    );
  }
}
