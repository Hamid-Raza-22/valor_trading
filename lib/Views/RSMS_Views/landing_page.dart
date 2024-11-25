import 'package:flutter/material.dart';

import '../NSM/nsm_homepage.dart';
import '../SM/sm_homepage.dart';
import 'RSM_HomePage.dart';


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildNavigationCard(context, 'RSM', Icons.location_city, const RSMHomepage()),
            const SizedBox(height: 16.0),
            _buildNavigationCard(context, 'SM', Icons.business_center, const SMHomepage()),
            const SizedBox(height: 16.0),
            _buildNavigationCard(context, 'NSM', Icons.public, const NSMHomepage()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 50.0, color: Colors.green),
              const SizedBox(width: 16.0),
              Container(
                width: 1,
                height: 60,
                color: Colors.green,
              ),
              const SizedBox(width: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontFamily: 'avenir next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

