import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/shared_preferences_utils.dart';
import '../../../../theme/theme_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> openDocument(String assetPath) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');

      // Copy the asset file to the temporary directory
      final assetData = await DefaultAssetBundle.of(context).load(assetPath);
      await tempFile.writeAsBytes(assetData.buffer.asUint8List());

      // Open the file
      await OpenFile.open(tempFile.path);
    } catch (e) {
      // Handle errors (e.g., file not found)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: $e')),
      );
    }
  }
  bool isNotificationsEnabled = true; // Default to true unless loaded otherwise

  @override
  void initState() {
    super.initState();
    loadNotificationSetting();
  }

  Future<void> loadNotificationSetting() async {
    isNotificationsEnabled = await getIsNotificationEnabled();
    setState(() {}); // This call to setState will refresh the UI with the loaded value
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Turn on/off notifications'),
            value: isNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                isNotificationsEnabled = value;
              });
              setNotificationEnabled(value); // Update the shared preference
            },
            secondary: const Icon(Icons.notifications),
            activeColor: PrimaryColors().primarycolor, // Set the switch active color
          ),
          ListTile(
            title: const Text('Cancellation Policy'),
            subtitle: const Text('Read our cancellation policy'),
            onTap: () {
              // Functionality to open your cancellation policy document
              openDocument('assets/cancellation.docx');

            },
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            onTap: () {
              // Functionality to open your privacy policy document
              openDocument('assets/privacy.docx');

            },
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
