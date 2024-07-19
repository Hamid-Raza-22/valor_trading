import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import 'login.dart';

class PolicyDialog extends StatefulWidget {
  const PolicyDialog({Key? key}) : super(key: key);

  @override
  _PolicyDialogState createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("App Policies"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "By using this app, you agree to the following policies:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "- This app collects location data to enable tracking and share your location to server even when the app is closed or not in use.",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "- This app requires access to your camera for posting images to the server through APIs.",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "- This app uses APIs to share app data onto the server.",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "- This app uses storage to store app data.",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "- This app uses battery for background services.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isChecked = newValue ?? false;
                    });
                  },
                ),
                const Text("I agree to the above policies"),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Handle "Deny" button press
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          child: const Text("Deny"),
        ),
        TextButton(
          onPressed: _isChecked
              ? () {
                  _showProminentDisclosure();
                }
              : null, // Disable the button if checkbox is not checked
          child: const Text("Agree"),
        ),
      ],
    );
  }

  void _showProminentDisclosure() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Background Location Access"),
        content: const Text(
          "This app collects location data to enable tracking and share your location to server even when the app is closed or not in use. This is necessary to provide you with real-time updates and notifications.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissions();
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {

    if (kDebugMode) {
      print('Requesting notification permission...');
    }
    if (await Permission.notification.request().isDenied) {
      // Notification permission not granted
      if (kDebugMode) {
        print('Notification permission denied');
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }

    if (kDebugMode) {
      print('Requesting location permission...');
    }
    if (await Permission.location.request().isDenied) {
      // Location permission not granted
      if (kDebugMode) {
        print('Location permission denied');
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else if (await Permission.location.request().isGranted) {
      if (kDebugMode) {
        print('Location permission granted');
      }
      // Check and request background location permission if necessary
      if (await Permission.locationAlways.request().isDenied) {
        // Background location permission not granted
        if (kDebugMode) {
          print('Background location permission denied');
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        if (kDebugMode) {
          print('All permissions granted');
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginForm(),
          ),
        );
        // Navigate to the login page if all permissions are granted
      }
    }
  }
  // Future<void> _requestPermissions() async {
  //   // Request notification permission
  //   if (await Permission.notification
  //       .request()
  //       .isDenied) {
  //     // @@ -105,6 +116,19 @@ class _PolicyDialogState extends State<PolicyDialog> {
  //     if (await Permission.location
  //         .request()
  //         .isDenied) {
  //       // Location permission not granted
  //       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //     } else if (await Permission.location
  //         .request()
  //         .isGranted) {
  //       // Check and request background location permission if necessary
  //       if (await Permission.locationAlways
  //           .request()
  //           .isDenied) {
  //         // Background location permission not granted
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       } else {
  //         // Navigate to the login page if all permissions are granted
  //         Navigator.of(context).push(
  //             MaterialPageRoute(
  //                 builder: (context) => const LoginForm()
  //             )
  //         );
  //       }
  //     }
  //   }
  // }
}












