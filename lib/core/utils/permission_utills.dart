import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Utils class manage permissions requests.
class PermissionUtils {
  static permissionServiceCall() async {
    await permissionServices().then(
          (value) {
        if (value != null) {
          if (value[Permission.notification]?.isGranted == true) {
            // All Permissions granted
          }
        }
      },
    );
  }

  /// Permission services
  static Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification
      //add more permission to request here.
    ].request();
    // if (statuses[Permission.notification]?.isPermanentlyDenied == true) {
    //   await openAppSettings().then(
    //     (value) async {
    //       if (value) {
    //         if (await Permission.notification.status.isPermanentlyDenied ==
    //                 true &&
    //             await Permission.notification.status.isGranted == false) {
    //           openAppSettings();
    //           //permissionServiceCall(); /* opens app settings until permission is granted */
    //         }
    //       }
    //     },
    //   );
    // } else {
    //   if (statuses[Permission.notification]?.isDenied == true) {
    //     permissionServiceCall();
    //   }
    // }
    // if (statuses[Permission.phone]?.isPermanentlyDenied == true) {
    //   await openAppSettings().then(
    //     (value) async {
    //       if (value) {
    //         if (await Permission.phone.status.isPermanentlyDenied == true &&
    //             await Permission.phone.status.isGranted == false) {
    //           openAppSettings();
    //           //permissionServiceCall(); /* opens app settings until permission is granted */
    //         }
    //       }
    //     },
    //   );
    // } else {
    //   if (statuses[Permission.phone]?.isDenied == true) {
    //     permissionServiceCall();
    //   }
    // }

    // if (statuses[Permission.systemAlertWindow]?.isPermanentlyDenied == true) {
    //   await openAppSettings().then(
    //     (value) async {
    //       if (value) {
    //         if (await Permission.systemAlertWindow.status.isPermanently  Denied ==
    //                 true &&
    //             await Permission.systemAlertWindow.status.isGranted == false) {
    //           openAppSettings();
    //           // permissionServiceCall(); /* opens app settings until permission is granted */
    //         }
    //       }
    //     },
    //   );
    //   //openAppSettings();
    //   //setState(() {});
    // } else {
    //   if (statuses[Permission.systemAlertWindow]?.isDenied == true) {
    //     permissionServiceCall();
    //   }
    // }
    /*{Permission.camera: PermissionStatus.granted, Permission.storage: PermissionStatus.granted}*/
    return statuses;
  }

  /// Method used to check all permissions are granted or not?
  static Future<bool> allPermissionsGranted() async {
    if (await Permission.notification.isGranted) {
      debugPrint("@@> allPermissionsGranted: $allPermissionsGranted");
      return true;
    } else {
      debugPrint("@@> allPermissionsGranted: $allPermissionsGranted");
      return false;
    }
  }
}
