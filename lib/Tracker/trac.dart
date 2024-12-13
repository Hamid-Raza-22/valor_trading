import 'dart:async' show Future, Timer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/LocationModel.dart';
import '../View_Models/LocationViewModel.dart';
import '../location00.dart';
import '../main.dart';

final locationViewModel = Get.put(LocationViewModel());
String gpxString = "";
Timer? _timer;

// Function to start a timer
Future<void> startTimer() async {
  startTimerFromSavedTime();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Periodically update the timer every second
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    secondsPassed++;
    await prefs.setInt('secondsPassed', secondsPassed);
  });
}

// Function to start the timer from saved time in SharedPreferences
void startTimerFromSavedTime() {
  SharedPreferences.getInstance().then((prefs) async {
    // Retrieve saved time and calculate the total saved seconds
    String savedTime = prefs.getString('savedTime') ?? '00:00:00';
    List<String> timeComponents = savedTime.split(':');
    int hours = int.parse(timeComponents[0]);
    int minutes = int.parse(timeComponents[1]);
    int seconds = int.parse(timeComponents[2]);
    int totalSavedSeconds = hours * 3600 + minutes * 60 + seconds;

    // Calculate the current time in seconds
    final now = DateTime.now();
    int totalCurrentSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    secondsPassed = totalCurrentSeconds - totalSavedSeconds;

    // Ensure secondsPassed is not negative
    if (secondsPassed < 0) {
      secondsPassed = 0;
    }
    await prefs.setInt('secondsPassed', secondsPassed);
    if (kDebugMode) {
      print("Loaded Saved Time");
    }
  });
}

// Function to post a GPX file
Future<void> postFile() async {
  final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final downloadDirectory = await getDownloadsDirectory();
  final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
  final maingpxFile = File(gpxFilePath);

  double totalDistance = await calculateTotalDistance("${downloadDirectory?.path}/track$date.gpx");
  if (!maingpxFile.existsSync()) {
    if (kDebugMode) {
      print('GPX file does not exist');
    }
    return;
  }

  // Read the GPX file
  List<int> gpxBytesList = await maingpxFile.readAsBytes();
  Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);

  var id = customAlphabet('1234567890', 10);

  locationViewModel.addLocation(LocationModel(
    id: int.parse(id),
    userId: userId,
    userName: userNames,
    totalDistance: totalDistance.toString(),
    fileName: "${_getFormattedDate1()}.gpx",
    date: _getFormattedDate1(),
    body: gpxBytes,
  ));

  if (kDebugMode) {
    print(userId);
    print(userid);
    print(userNames);
  }
  bool isConnected = await isInternetAvailable();

  if (isConnected == true) {
    await locationViewModel.postLocation();
  }
}

// Function to get the formatted date and time
String _getFormattedDate1() {
  final now = DateTime.now();
  final formatter = DateFormat('dd-MMM-yyyy  [hh:mm a] ');
  return formatter.format(now);
}
