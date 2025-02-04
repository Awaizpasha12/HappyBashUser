import 'package:flutter/material.dart';
import 'package:happy_bash/theme/theme_helper.dart';

extension PaddingwithSizedBox on num {
  SizedBox get ph => SizedBox(height: toDouble());
  SizedBox get pw => SizedBox(width: toDouble());
}

bool showLog = true;

printMsgTag(tag, message) {
  if (showLog) print(tag + "==>" + message.toString());
}

void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: PrimaryColors().secondarycolor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: PrimaryColors().primarycolor,
        // backgroundColor: Colors.grey,
      ),
    );
  }
}
