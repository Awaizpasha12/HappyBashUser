import 'package:flutter/material.dart';

navigateAddScreen(BuildContext context, StatefulWidget screenName) {
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => screenName));
}

navigateFromDrawer(BuildContext context, StatefulWidget screenName) {
  Navigator.pop(context);
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => screenName));
}

navigateReplaceAll(BuildContext context, StatefulWidget screenName) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => screenName),
      (Route<dynamic> route) => false);
}
