import 'dart:async' show Future, Timer;
import 'package:flutter/material.dart';
import '../API/Globals.dart';
import '../Views/HomePage.dart';
import '../Views/PolicyDBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NSM/nsm_homepage.dart';
import 'RSMS_Views/RSM_HomePage.dart';
import 'SM/sm_homepage.dart';
import 'login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userDesignation="";
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () async {
      dynamic isLoggedIn = await _checkLoginStatus();

      if (isLoggedIn) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userDesignation = prefs.getString('userDesignation');
        switch (userDesignation) {
          case 'RSM':
          // Redirect to the RSM Homepage
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RSMHomepage(),
              ),
            );
            break;
          case 'SM':
          // Redirect to the SM Homepage
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SMHomepage(),
              ),
            );
            break;
          case 'NSM':
          // Redirect to the NSM Homepage
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NSMHomepage(),
              ),
            );
            break;
        // case 'SO':
        // case 'SPO':
        // case 'ASM':
        // case 'SOS':
        // // Redirect to the HomePage for general designations
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) => const HomePage(),
        //     ),
        //   );
        //   break;
          default:

          // Handle cases where designation does not match any of the above
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HomePage(), // Replace with your default page
              ),
            );
            break;
        }
      } else {
        // Redirect to the login page if the user is not logged in
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PolicyDialog(),
          ),
        );
      }

    });
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userNames = prefs.getString('userNames');
    String? userCitys = prefs.getString('userCitys');
    String? userDesignation = prefs.getString('userDesignation');
    String? userRSM = prefs.getString('userRSM');
    String? userSM = prefs.getString('userSM');
    String? userNSM = prefs.getString('userNSM');
    return userRSM != null && userRSM.isNotEmpty && userSM != null && userSM.isNotEmpty && userNSM != null && userNSM.isNotEmpty &&userId != null && userId.isNotEmpty && userCitys!=null && userCitys.isNotEmpty && userNames!=null && userNames.isNotEmpty && userDesignation!=null && userDesignation.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/images/mxlogo-01.png'))

    );
  }
}
