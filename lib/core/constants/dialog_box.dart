import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:happy_bash/theme/theme_helper.dart';

class ModelUtils {
  static void showSimpleAlertDialog(
    BuildContext context, {
    required Widget title,
    required String content,
    String okBtnText = "OK",
    String cancelBtnText = "Cancel",
    bool routePop = true,
    required Function() okBtnFunction,
  }) {
    // okBtnText = getlabel(LabelCode.ok, prefs);
    // cancelBtnText = getlabel(LabelCode.cancel, prefs);
    okBtnText = "Okay";
    cancelBtnText = "Cancel";
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 300),
      ),
      builder: (_) {
        return AlertDialog(
          title: title,
          content: Text(content),
          actions: <Widget>[
            MaterialButton(
              color: PrimaryColors().primarycolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              onPressed: okBtnFunction,
              child: Text(
                okBtnText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showCustomAlertDialog(
    BuildContext context, {
    required String title,
    required Widget content,
    String okBtnText = "OK",
    String cancelBtnText = "Cancel",
    bool routePop = true,
    required Function() okBtnFunction,
  }) {
    // okBtnText = getlabel(LabelCode.ok, prefs);
    // cancelBtnText = getlabel(LabelCode.cancel, prefs);
    okBtnText = "Okay";
    cancelBtnText = "Cancel";
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 300),
      ),
      builder: (_) {
        return AlertDialog(
          // actionsAlignment: MainAxisAlignment.center,
          title: Text(title),
          // titlePadding: EdgeInsets.zero,
          content: content,
          actions: <Widget>[
            MaterialButton(
              color: PrimaryColors().primarycolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              onPressed: okBtnFunction,
              child: Text(
                okBtnText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MaterialButton(
              color: PrimaryColors().white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                cancelBtnText,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
