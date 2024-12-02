import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Databases/DBHelper.dart';
import '../main.dart';
class PostingStatus {
  static final ValueNotifier<bool> isPosting = ValueNotifier<bool>(false);
}

DBHelper dbHelper = DBHelper();
String currentPostId= "";
bool _isPosting = false;
dynamic version = "v: 0.6.1";
String pending ="PENDING";
String SellectedproductName= "";
double? globalnetBalance;
String selectedShopCity= '';
String userDesignation = "";
String userBrand = "";
int? highestSerial;
int? RecoveryhighestSerial;
String userNames = "";
dynamic userNSM = "";
dynamic userRSM = "";
dynamic userSM = "";
String username= "";
String username2="";
String userId= "";
String userCitys= "";
String orderno= "";
String Receipt = "REC";
String globalselectedbrand= "";
String orderMasterid= "";
bool isClockedIn = false;
late Timer timer;
int secondsPassed=0;
String selectedorderno ="";
String globalselectedimageurl ="";
String userid="95";
String checkbox1="";
String checkbox2="";
String checkbox3="";
String checkbox4="";
String shopName="";
String OrderMasterid= "";
// String address = "";
dynamic shopAddress = "";
bool locationbool = true;
//dynamic serialCounter ='';
String globalcurrentMonth= DateFormat('MMM').format(DateTime.now());

List<String>? cachedShopNames =[];


Future<void> checkAndSetInitializationDateTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if 'lastInitializationDateTime' is already stored
  String? lastInitDateTime = prefs.getString('lastInitializationDateTime');

  if (lastInitDateTime == null) {
    // If not, set the current date and time
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
    await prefs.setString('lastInitializationDateTime', formattedDateTime);
    if (kDebugMode) {
      print('lastInitializationDateTime was not set, initializing to: $formattedDateTime');
    }
  } else {
    if (kDebugMode) {
      print('lastInitializationDateTime is already set to: $lastInitDateTime');
    }
  }
}
Future<bool> isInternetConnected() async {
  bool isConnected = await isInternetAvailable();
  if (kDebugMode) {
    print('Internet Connected: $isConnected');
  }
  return isConnected;
}

Future<void> headsBackgroundTask() async {
  try {
    bool isConnected = await isInternetConnected();

    if (isConnected) {
      if (kDebugMode) {
        print('Internet connection is available. Initiating background data synchronization.');
      }
      await synchronizeData();
      if (kDebugMode) {
        print('Background data synchronization completed.');
      }
    } else {
      if (kDebugMode) {
        print('No internet connection available. Skipping background data synchronization.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in backgroundTask: $e');
    }
  }
}

Future<void> synchronizeData() async {
  if (kDebugMode) {
    print('Synchronizing data in the background.');
  }
  await postShopVisitData();
}
Future<void> postShopVisitData() async {
  await shopisitViewModel.postHeadsShopVisit();
}