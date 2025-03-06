
import 'dart:async' show Completer, Future, StreamSubscription, Timer;
import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:flutter/material.dart' show AlertDialog, Align, Alignment, AppBar, Border, BorderRadius, BoxDecoration, BoxShape, BuildContext, Center, CircleBorder, CircularProgressIndicator, Colors, Column, Container, EdgeInsets, ElevatedButton, Icon, IconButton, IconData, Icons, InputDecoration, Key, MainAxisAlignment, MainAxisSize, Material, MaterialApp, MaterialPageRoute, Navigator, OutlineInputBorder, Padding, RoundedRectangleBorder, Row, Scaffold, SingleChildScrollView, SizedBox, State, StatefulWidget, StatelessWidget, Text, TextButton, TextEditingController, TextField, TextStyle, Widget, WidgetsBinding, WidgetsBindingObserver, WidgetsFlutterBinding, WillPopScope, runApp, showDialog;
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart' show FlutterBackgroundService;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nanoid/nanoid.dart' show customAlphabet;
import '../API/Globals.dart' show PostingStatus, checkAndSetInitializationDateTime, currentPostId, isClockedIn, locationbool, secondsPassed, shopAddress, timer, userBrand, userCitys, userDesignation, userId, userNames;
import '../Models/AttendanceModel.dart';
import '../main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/newDatabaseOutPuts.dart';
import '../Tracker/trac.dart';
import '../View_Models/AttendanceViewModel.dart';
import '../View_Models/LocationViewModel.dart';
import '../View_Models/OrderViewModels/OrderDetailsViewModel.dart';
import '../View_Models/OrderViewModels/OrderMasterViewModel.dart';
import '../View_Models/OrderViewModels/ReturnFormDetailsViewModel.dart';
import '../View_Models/OrderViewModels/ReturnFormViewModel.dart';
import '../View_Models/OwnerViewModel.dart';
import '../View_Models/RecoveryFormViewModel.dart';
import '../View_Models/ShopViewModel.dart';
import '../View_Models/ShopVisitViewModel.dart';
import '../View_Models/StockCheckItems.dart';
import '../location00.dart';
import 'OrderBookingStatus.dart';
import 'RecoveryFormPage.dart';
import 'ReturnFormPage.dart';
import 'ShopPage.dart';
import 'ShopVisit.dart';
import '../Databases/DBHelper.dart';
import 'dart:io' show File, InternetAddress, SocketException;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatus, PermissionStatusGetters, openAppSettings;

import 'package:http/http.dart' as http;
import 'dart:convert';


//tarcker
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final myUid = userId;
final name = userNames;


bool showButton = false;


class MyIcons {
  static const IconData addShop = IconData(0xf52a, fontFamily: 'MaterialIcons');
  static const IconData store = Icons.store;
  static const IconData returnForm = IconData(0xee93, fontFamily: 'MaterialIcons');
  static const IconData person = Icons.person;
  static const IconData orderBookingStatus = IconData(0xf52a, fontFamily: 'MaterialIcons');
}



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Initializing view models
  final ownerViewModel = Get.put(OwnerViewModel());
  final attendanceViewModel = Get.put(AttendanceViewModel());
  final shopisitViewModel = Get.put(ShopVisitViewModel());
  final stockcheckitemsViewModel = Get.put(StockCheckItemsViewModel());
  final shopViewModel = Get.put(ShopViewModel());
  final recoveryformViewModel = Get.put(RecoveryFormViewModel());
  final returnformdetailsViewModel = Get.put(ReturnFormDetailsViewModel());
  final returnformViewModel = Get.put(ReturnFormViewModel());
  final ordermasterViewModel = Get.put(OrderMasterViewModel());
  final orderdetailsViewModel = Get.put(OrderDetailsViewModel());
  final locationViewModel = Get.put(LocationViewModel());

  // Instance of ShopVisitState
  final ownerViewModeldata = ShopVisitState();

  // Controllers for text input fields for Allowance and Fuel
  TextEditingController allowanceController = TextEditingController();
  TextEditingController fuelController = TextEditingController();

  // List to store shop names
  List<String> shopList = [];
  String? selectedShop2; // Selected shop variable
  int? attendanceId; // Variable to store attendance ID
  Timer? _timer; // Timer for scheduled tasks
  int? attendanceId1; // Another variable for attendance ID
  double? globalLatitude1; // Global latitude variable
  double? globalLongitude1; // Global longitude variable

  // Database helper instance
  DBHelper dbHelper = DBHelper();

  bool isLoadingReturn = false; // Loading state for return
  bool isLoadingReturn3 = false; // Another loading state for return

  // Location object
  final loc.Location location = loc.Location();
  bool isLoading = false; // Loading state variable
  late StreamSubscription<
      ServiceStatus> locationServiceStatusStream; // Stream subscription for location service status

  // Additional variables
  bool isNetworkAvailable = true; // To check network availability
  bool isDatabaseSynced = false; // To check if database is synced
  DateTime? lastSyncTime; // To store last sync time


  @override
  void initState() {
    super.initState();
    checkAndSetInitializationDateTime();
    _monitorLocationService();
    // backgroundTask();
    WidgetsBinding.instance.addObserver(this);
    _loadClockStatus();
    fetchShopList();
    _retrieveSavedValues();
    _clockRefresh();

    if (kDebugMode) {
      print("B1000 ${name.toString()}");
    }
    //_requestPermission();
    // location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);
    _getFormattedDate();
    data();
    _checkForUpdate(); // Check for updates when the screen opens
  }

// Function to check for updates based on user designation
  Future<void> checkUserIdAndFetchShopNames() async {
    // Get the instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDesignation = prefs.getString('userDesignation');

    // Check user designation and fetch shop names accordingly
    if (userDesignation == 'NSM' || userDesignation == 'RSM' ||
        userDesignation == 'SM' || userDesignation == 'SPO' ||
        userDesignation == 'SOS') {
      await fetchShopNamesAll();
    } else {
      await fetchShopNames();
    }
  }

  /// Monitors if the location service is enabled and updates `locationbool`
  void _monitorLocationService() {
    locationServiceStatusStream = Geolocator.getServiceStatusStream().listen((
        ServiceStatus status) async {
      // Handle clock out if location service is disabled
      if (status == ServiceStatus.disabled && isClockedIn) {
        await _handleClockOut();
      }
    });
  }

// Function to save current location
  Future<void> saveCurrentLocation(BuildContext context) async {
    // Check if the widget is still mounted
    if (!mounted) return;

    // Request location permission
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude1 = position.latitude;
        globalLongitude1 = position.longitude;

        // Print latitude and longitude in debug mode
        if (kDebugMode) {
          print('Latitude: $globalLatitude1, Longitude: $globalLongitude1');
        }

        // Default address to "Pakistan" initially
        String address1 = "Pakistan";

        try {
          // Attempt to get the address from coordinates
          List<Placemark> placemarks = await placemarkFromCoordinates(
              globalLatitude1!, globalLongitude1!);
          Placemark? currentPlace = placemarks.isNotEmpty
              ? placemarks[0]
              : null;

          if (currentPlace != null) {
            // Construct address from placemark data
            address1 =
            "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ??
                ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ??
                ''}, ${currentPlace.country ?? ''}";

            // Check if the constructed address is empty, fallback to "Pakistan"
            if (address1
                .trim()
                .isEmpty) {
              address1 = "Pakistan";
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting placemark: $e');
          }
          // Keep the address as "Pakistan" in case of error
        }

        shopAddress = address1;

        // Print the address in debug mode
        if (kDebugMode) {
          print('Address is: $address1');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
        // Handle GPS not enabled case
      }
    }
  }

// Function to handle clocking out
  Future<void> _handleClockOut() async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent users from dismissing the dialog
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          // Prevent back button from closing the dialog
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    Completer<void> completer = Completer<void>();

    final service = FlutterBackgroundService();
    bool newIsClockedIn = !isClockedIn;

    // Perform clock-out operations here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    service.invoke("stopService");
    await saveCurrentLocation(context); // Save the current location

    // Format the current date
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    double totalDistance = await calculateTotalDistance(
        "${downloadDirectory?.path}/track$date.gpx");
    totalDistance ??= 0; // Ensure distance is not null

    // Delay for demonstration purposes
    await Future.delayed(const Duration(seconds: 4));

    // Add attendance out record
    await attendanceViewModel.addAttendanceOut(AttendanceOutModel(
        id: prefs.getString('clockInId'),
        timeOut: _getFormattedtime(),
        totalTime: _formatDuration(newsecondpassed.toString()),
        date: _getFormattedDate(),
        userId: userId.toString(),
        latOut: globalLatitude1,
        lngOut: globalLongitude1,
        totalDistance: totalDistance,
        address: shopAddress
    ));

    isClockedIn = false;
    _saveClockStatus(false);

    // Additional delay for demonstration purposes
    await Future.delayed(const Duration(seconds: 10));
    await postFile(); // Post the file

    bool isConnected = await isInternetAvailable();
    if (isConnected) {
      await attendanceViewModel.postAttendanceOut();
    }

    _stopTimer();
    _clockRefresh();
    await prefs.remove('clockInId');
    await location.enableBackgroundMode(enable: false);

    setState(() {
      isClockedIn = newIsClockedIn;
    });

    // Show the confirmation dialog
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        // Prevent the user from dismissing the dialog
        builder: (context) =>
            WillPopScope(
              onWillPop: () async => false,
              // Prevent back button from closing the dialog
              child: AlertDialog(
                title: const Text('Clock Out'),
                content: const Text(
                    'You have been clocked out due to location services being disabled.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (
                              context) => const HomePage()),
                        );
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
      );
    }

    Navigator.pop(context); // Close the loading indicator dialog
    completer.complete();
    return completer.future;
  }

// Function to fetch shop names based on cities
  Future<void> fetchShopNames() async {
    var box = await Hive.openBox('shopNamesByCities');
    List<String> shopNamesByCities = box.get(
        'shopNamesByCities', defaultValue: <String>[]);

    // Check if data is already in Hive
    if (shopNamesByCities.isEmpty) {
      // Fetch shop names from database
      await ownerViewModel.fetchShopNamesbycities();
      List<String> shopNames = ownerViewModel.shopNamesbycites
          .map((dynamic item) => item.toString())
          .toSet()
          .toList(); // Ensure data is unique and converted to a list of strings

      // Save shop names to Hive
      await box.put('shopNamesByCities', shopNames);
      shopNamesByCities = shopNames; // Update the local variable
      if (kDebugMode) {
        print('Shop names by cities: $shopNamesByCities');
      }
    } else {
      if (kDebugMode) {
        print('Shop names by cities already exist in Hive: $shopNamesByCities');
      }
    }

    await box.close(); // Close the Hive box
  }

// Function to fetch all shop names
  Future<void> fetchShopNamesAll() async {
    var box = await Hive.openBox('shopNames');
    List<String> allShopNames = box.get('shopNames', defaultValue: <String>[]);

    // Check if data is already in Hive
    if (allShopNames.isEmpty) {
      // Fetch shop names from database
      await ownerViewModel.fetchShopNames();
      List<String> shopNames = ownerViewModel.shopNames
          .map((dynamic item) => item.toString())
          .toSet()
          .toList(); // Ensure data is unique and converted to a list of strings

      // Save shop names to Hive
      await box.put('shopNames', shopNames);
      allShopNames = shopNames; // Update the local variable
      if (kDebugMode) {
        print('All shop names: $allShopNames');
      }
    } else {
      if (kDebugMode) {
        print('All shop names already exist in Hive: $allShopNames');
      }
    }

    await box.close(); // Close the Hive box
  }

// Function to check for app updates
  void _checkForUpdate() async {
    try {
      // Check for available updates
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // If an update is available, perform an immediate update
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // Handle specific PlatformException error
      if (e is PlatformException && e.code == 'TASK_FAILURE' &&
          e.message?.contains('Install Error(-10)') == true) {
        if (kDebugMode) {
          print(
              "The app is not owned by any user on this device. Update check skipped.");
        }
      } else {
        if (kDebugMode) {
          print("Failed to check for updates: $e");
        }
      }
    }
  }

// Function to check location permission
  Future<bool> _checkLocationPermission() async {
    // Check the current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // Return true if permission is granted, false otherwise
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

// Function to request location permission
  Future<void> _requestLocationPermission() async {
    // Request location permission from the user
    LocationPermission permission = await Geolocator.requestPermission();

    // If permission is denied, show a toast message
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      Fluttertoast.showToast(
        msg: "Location permissions are required to clock in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

// Function to retrieve saved values from SharedPreferences
  _retrieveSavedValues() async {
    // Get instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Update state with retrieved values
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userNames = prefs.getString('userNames') ?? '';
      userCitys = prefs.getString('userCitys') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      // userBrand = prefs.getString('userBrand') ?? '';
    });
  }

// Function to toggle clock-in and clock-out
  Future<void> _toggleClockInOut() async {
    final service = FlutterBackgroundService();
    Completer<void> completer = Completer<void>();

    // Check if location services are enabled
    bool isLocationEnabled = await _isLocationEnabled();
    if (!isLocationEnabled) {
      Fluttertoast.showToast(
        msg: "Please enable GPS or location services before clocking in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      completer.complete();
      return completer.future;
    }

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent users from dismissing the dialog
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          // Prevent back button from closing the dialog
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    // Check if location permission is granted
    bool isLocationPermissionGranted = await _checkLocationPermission();
    if (!isLocationPermissionGranted) {
      await _requestLocationPermission();
      Navigator.pop(
          context); // Close the loading indicator dialog if permission is not granted
      completer.complete();
      return completer.future;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _getCurrentLocation();

    bool newIsClockedIn = !isClockedIn;

    if (newIsClockedIn) {
      // Clock-in operations
      await initializeServiceLocation();
      await location.enableBackgroundMode(enable: true);
      await location.changeSettings(
          interval: 300, accuracy: loc.LocationAccuracy.high);
       locationbool = true;
      service.startService();

      var id = customAlphabet('1234567890', 10);
      await prefs.setString('clockInId', id);
      _saveCurrentTime();
      _saveClockStatus(true);
      _clockRefresh();
      isClockedIn = true;
      await Future.delayed(const Duration(seconds: 5));
      await attendanceViewModel.addAttendance(AttendanceModel(
        id: prefs.getString('clockInId'),
        timeIn: _getFormattedtime(),
        date: _getFormattedDate(),
        userId: userId.toString(),
        latIn: globalLatitude1,
        lngIn: globalLongitude1,
        bookerName: userNames,
        city: userCitys,
        designation: userDesignation,
      ));
      bool isConnected = await isInternetAvailable();

      if (isConnected) {
        await attendanceViewModel.postAttendance();
      }

      if (kDebugMode) {
        print('HomePage:$currentPostId');
      }
    } else {
      // Clock-out operations
      service.invoke("stopService");

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      double totalDistance = await calculateTotalDistance(
          "${downloadDirectory?.path}/track$date.gpx");
      totalDistance ??= 0;
      await Future.delayed(const Duration(seconds: 4));
      await attendanceViewModel.addAttendanceOut(AttendanceOutModel(
        id: prefs.getString('clockInId'),
        timeOut: _getFormattedtime(),
        totalTime: _formatDuration(newsecondpassed.toString()),
        date: _getFormattedDate(),
        userId: userId.toString(),
        latOut: globalLatitude1,
        lngOut: globalLongitude1,
        totalDistance: totalDistance,
      ));
      isClockedIn = false;
      _saveClockStatus(false);
      await Future.delayed(const Duration(seconds: 10));

      await postFile();
      bool isConnected = await isInternetAvailable();

      if (isConnected) {
        await attendanceViewModel.postAttendanceOut();
      }

      _stopTimer();
      _clockRefresh();
      await prefs.remove('clockInId');
      await location.enableBackgroundMode(enable: false);
    }

    // Update state and close the loading indicator dialog
    setState(() {
      isClockedIn = newIsClockedIn;
    });
    await Future.delayed(const Duration(seconds: 10));
    Navigator.pop(context);
    completer.complete();
    return completer.future;
  }

// Function to check if location services are enabled
  Future<bool> _isLocationEnabled() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    return isLocationEnabled;
  }

// Function to get the formatted current time
  String _getFormattedtime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss a');
    return formatter.format(now);
  }

// Function to load clock status from SharedPreferences
  _loadClockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isClockedIn = prefs.getBool('isClockedIn') ?? false;
    if (isClockedIn == true) {
      startTimerFromSavedTime();
      // Uncomment these lines if needed
      // final service = FlutterBackgroundService();
      // service.startService();
      // _clockRefresh();
    } else {
      prefs.setInt('secondsPassed', 0);
    }
  }

// Function to save clock status to SharedPreferences
  _saveClockStatus(bool clockedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isClockedIn', clockedIn);
    isClockedIn = clockedIn;
  }

// Function to retrieve data from the database
  data() {
    DBHelper dbHelper = DBHelper();
    if (kDebugMode) {
      print('data0');
    }
    dbHelper.getRecoveryHighestSerialNo();
    dbHelper.getHighestSerialNo();
  }

// Function to save the current time to SharedPreferences
  void _saveCurrentTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    String formattedTime = _formatDateTime(currentTime);
    prefs.setString('savedTime', formattedTime);
    if (kDebugMode) {
      print("Save Current Time");
    }
  }

// Function to format DateTime object to a string
  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }

  int newsecondpassed = 0;

// Function to refresh the clock timer
  void _clockRefresh() async {
    newsecondpassed = 0;
    timer = Timer.periodic(const Duration(seconds: 0), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.reload();
        newsecondpassed = prefs.getInt('secondsPassed')!;
      });
    });
  }

// Function to stop the timer and get the total time passed
  Future<String> _stopTimer() async {
    _timer?.cancel();
    String totalTime = _formatDuration(newsecondpassed.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('secondsPassed', 0);
    setState(() {
      secondsPassed = 0;
    });
    return totalTime;
  }

// Function to format duration in seconds to a string
  String _formatDuration(String secondsString) {
    int seconds = int.parse(secondsString);
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secondsFormatted';
  }


  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    // Remove this widget as a binding observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

// Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      // Save the location into the database (you need to implement this part)
      globalLatitude1 = position.latitude;
      globalLongitude1 = position.longitude;
      // Show a toast (consider adding implementation)
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
    }
  }

// Function to determine the current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled.');
    }

    // Check the location permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied
      throw Exception('Location permissions are permanently denied.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }

// Function to fetch the shop list
  Future<void> fetchShopList() async {
    List<String> fetchShopList = await fetchData();
    if (fetchShopList.isNotEmpty) {
      setState(() {
        shopList = fetchShopList;
        selectedShop2 = shopList.first;
      });
    }
  }

// Mock function to fetch data (should be implemented)
  Future<List<String>> fetchData() async {
    return [];
  }

// Function to get the formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

// Function to handle shop change
  void handleShopChange(String? newShop) {
    setState(() {
      selectedShop2 = newShop;
    });
  }

  bool _isButtonDisabled = false;

// Function to handle refresh operation
  void _handleRefresh() async {
    setState(() {
      _isButtonDisabled = true;
    });

    bool isPostingData = await isDataBeingPosted();
    if (isPostingData) {
      Fluttertoast.showToast(
        msg: "Data is being posted, please wait.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color(0xFF9615DB),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

    showLoadingIndicator(context);

    bool isConnected = await isInternetAvailable();
    Navigator.of(context, rootNavigator: true).pop();

    if (isConnected) {
      newDatabaseOutputs outputs = newDatabaseOutputs();
      bool tasksCompleted = false;

      // Run both functions in parallel with a timeout
      showLoadingIndicator(context);
      await Future.any([
        Future.wait([
          backgroundTask(),
          outputs.refreshData(),
        ]).then((_) {
          tasksCompleted = true;
        }),
        Future.delayed(const Duration(minutes: 1)),
      ]);

      // Hide the loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      if (!tasksCompleted) {
        Fluttertoast.showToast(
          msg: "Network Problem!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "No internet connection.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    setState(() {
      _isButtonDisabled = false;
    });
  }


//Mock function to check if data is being posted to the server
  Future<bool> isDataBeingPosted() async {
    return PostingStatus.isPosting.value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent going back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF212529),
          toolbarHeight: 80.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Timer: ${_formatDuration(newsecondpassed.toString())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Material(
                    elevation: 10.0, // Set the elevation here
                    shape: const CircleBorder(),
                    color: Colors.purple.shade400,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 0.1,
                        ),
                        //borderRadius: BorderRadius.circular(1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.white, iconSize: 20,
                        onPressed: _isButtonDisabled ? null : _handleRefresh,
                        //   () async {
                        //     // Check internet connection before refresh
                        //     showLoadingIndicator(context);
                        //     bool isConnected = await isInternetAvailable();
                        //     Navigator.of(context, rootNavigator: true).pop();
                        //
                        //     if (isConnected) {
                        //       // Internet connection is available
                        //       newDatabaseOutputs outputs = newDatabaseOutputs();
                        //       // Run both functions in parallel
                        //       showLoadingIndicator(context);
                        //
                        //       await Future.wait([
                        //       backgroundTask(),
                        // //        Future.delayed(Duration(seconds: 10)),
                        //         //outputs.checkFirstRun(),
                        //         outputs.refreshData(),
                        //        // outputs.initializeDatalogin()
                        //       ]);
                        //       // After 10 seconds, hide the loading indicator and perform the refresh logic
                        //       Navigator.of(context, rootNavigator: true).pop();
                        //     } else {
                        //       // No internet connection
                        //       Fluttertoast.showToast(
                        //         msg: "No internet connection.",
                        //         toastLength: Toast.LENGTH_SHORT,
                        //         gravity: ToastGravity.BOTTOM,
                        //         backgroundColor: Colors.red,
                        //         textColor: Colors.white,
                        //         fontSize: 16.0,
                        //       );
                        //     }
                        //   },
                      ),
                    ),
                  )


                  // PopupMenuButton<int>(
                  //   icon: Icon(Icons.more_vert),
                  //   color: Colors.white,
                  //   onSelected: (value) async {
                  //     switch (value) {
                  //       case 1:
                  //       // Check internet connection before refresh
                  //         final bool isConnected = await InternetConnectionChecker().hasConnection;
                  //         if (!isConnected) {
                  //           // No internet connection
                  //           Fluttertoast.showToast(
                  //             msg: "No internet connection.",
                  //             toastLength: Toast.LENGTH_SHORT,
                  //             gravity: ToastGravity.BOTTOM,
                  //             backgroundColor: Colors.red,
                  //             textColor: Colors.white,
                  //             fontSize: 16.0,
                  //           );
                  //         } else {
                  //           // Internet connection is available
                  //           DatabaseOutputs outputs = DatabaseOutputs();
                  //           // Run both functions in parallel
                  //           showLoadingIndicator(context);
                  //           await Future.wait([
                  //             backgroundTask(),
                  //             postFile(),
                  //             outputs.checkFirstRun(),
                  //             Future.delayed(Duration(seconds: 10)),
                  //           ]);
                  //           // After 10 seconds, hide the loading indicator and perform the refresh logic
                  //           Navigator.of(context, rootNavigator: true).pop();
                  //         }
                  //         break;
                  //
                  //       case 2:
                  //       // Handle the action for the second menu item (Log Out)
                  //         if (isClockedIn) {
                  //           // Check if the user is clocked in
                  //           Fluttertoast.showToast(
                  //             msg: "Please clock out before logging out.",
                  //             toastLength: Toast.LENGTH_SHORT,
                  //             gravity: ToastGravity.BOTTOM,
                  //             backgroundColor: Colors.red,
                  //             textColor: Colors.white,
                  //             fontSize: 16.0,
                  //           );
                  //         } else {
                  //           await _logOut();
                  //           // If the user is not clocked in, proceed with logging out
                  //           Navigator.pushReplacement(
                  //             // Replace the current page with the login page
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => LoginForm(),
                  //             ),
                  //           );
                  //         }
                  //         break;
                  //     }
                  //   },
                  //   itemBuilder: (BuildContext context) {
                  //     return [
                  //       PopupMenuItem<int>(
                  //         value: 1,
                  //         child: Text('Refresh'),
                  //       ),
                  //       PopupMenuItem<int>(
                  //         value: 2,
                  //         child: Text('Log Out'),
                  //       ),
                  //     ];
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ), body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isClockedIn) {
                              await checkUserIdAndFetchShopNames();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopPage(),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      title: const Text('Clock In Required'),
                                      content: const Text(
                                          'Please clock in before adding a shop.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF212529),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.addShop,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Add Shop'),
                            ],
                          ),
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        ],
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isClockedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShopVisit(),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      title: const Text('Clock In Required'),
                                      content: const Text(
                                          'Please clock in before visiting a shop.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF212529),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Shop Visit'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading =
                              true; // assuming isLoading is a boolean state variable
                            });
                            bool isConnected = await isInternetAvailable();
                            if (!isClockedIn) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      title: const Text('Clock In Required'),
                                      content: const Text(
                                          'Please clock in before accessing the Return Page.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            } else if (!isConnected) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      title: const Text(
                                          'Internet Data Required'),
                                      content: const Text(
                                          'Please check your internet connection before accessing the Return Page.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              newDatabaseOutputs outputs = newDatabaseOutputs();
                              await outputs.updateOrderBookingStatusData();
                              await outputs.updateAccountsData();

                              await Navigator.push(context, MaterialPageRoute(
                                  builder: (
                                      context) => const ReturnFormPage()));
                            }
                            setState(() {
                              isLoading =
                              false; // set loading state to false after execution
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF212529),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator() // Show a loading indicator
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.returnForm,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Return Form'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingReturn =
                                true; // assuming isLoading is a boolean state variable
                              });

                              // Delay for 5 seconds
                              // await Future.delayed(Duration(seconds: 5));

                              bool isConnected = await isInternetAvailable();

                              if (!isClockedIn) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: const Text('Clock In Required'),
                                        content: const Text(
                                            'Please clock in before accessing the Recovery.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              } else if (!isConnected) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: const Text(
                                            'Internet Data Required'),
                                        content: const Text(
                                            'Please check your internet connection before accessing the Recovery.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              } else {
                                // SharedPreferences prefs = await SharedPreferences.getInstance();
                                // await prefs.remove('balance');
                                newDatabaseOutputs outputs = newDatabaseOutputs();
                                await outputs.updateOrderBookingStatusData();
                                await outputs.updateAccountsData();

                                await Navigator.push(context, MaterialPageRoute(
                                    builder: (
                                        context) => const RecoveryFromPage()));
                              }

                              setState(() {
                                isLoadingReturn =
                                false; // set loading state to false after execution
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF212529),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoadingReturn
                                ? const CircularProgressIndicator() // Show a loading indicator
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Recovery'),
                              ],
                            ),
                          )

                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingReturn3 =
                                true; // assuming isLoading is a boolean state variable
                              });

                              // Delay for 5 seconds
                              // await Future.delayed(Duration(seconds: 5));

                              bool isConnected = await isInternetAvailable();

                              if (!isClockedIn) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: const Text('Clock In Required'),
                                        content: const Text(
                                            'Please clock in before accessing the adding the Allowance/Fuel.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              } else if (!isConnected) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: const Text(
                                            'Internet Data Required'),
                                        content: const Text(
                                            'Please check your internet connection before adding the Allowance/Fuel.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }

                              else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Enter Allowance and Fuel'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: allowanceController,
                                              keyboardType: TextInputType
                                                  .number,
                                              decoration: InputDecoration(
                                                labelText: 'Allowance (Rs)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(Icons.money),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            TextField(
                                              controller: fuelController,
                                              keyboardType: TextInputType
                                                  .number,
                                              decoration: InputDecoration(
                                                labelText: 'Fuel (Rs)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(
                                                    Icons.local_gas_station),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            String allowance = allowanceController
                                                .text;
                                            String fuel = fuelController.text;

                                            // API call
                                            var response = await http.post(
                                              Uri.parse(
                                                  'http://103.149.32.30:8080/ords/valor_trading/allowances/post/'),
                                              headers: <String, String>{
                                                'Content-Type': 'application/json; charset=UTF-8',
                                              },
                                              body: jsonEncode(
                                                  <String, String>{
                                                    'userId': userId,
                                                    'userName': userNames,
                                                    'time': _getFormattedtime(),
                                                    'allowanceDate': _getFormattedDate(),
                                                    'allowance': allowance,
                                                    'fuel': fuel,
                                                  }),
                                            );

                                            if (response.statusCode == 200) {
                                              // If the server returns a 200 OK response
                                              if (kDebugMode) {
                                                print(
                                                    'Data posted successfully');
                                              }
                                            } else {
                                              // If the server did not return a 200 OK response
                                              if (kDebugMode) {
                                                print('Failed to post data');
                                              }
                                            }

                                            Navigator.pop(context);
                                          },
                                          child: const Text('Submit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }

                              setState(() {
                                isLoadingReturn3 =
                                false; // set loading state to false after execution
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF212529),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoadingReturn3
                                ? const CircularProgressIndicator() // Show a loading indicator
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payment,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Allowance/Fuel'),
                              ],
                            ),
                          )

                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            //await initializeDatabase();
                            // await deleteDatabaseFile();
                            // if (isClockedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (
                                    context) => const OrderBookingStatus(),
                              ),
                            );
                            // } else {
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) => AlertDialog(
                            //       title: Text('Clock In Required'),
                            //       content: Text('Please clock in before checking Order Booking Status.'),
                            //       actions: [
                            //         TextButton(
                            //           onPressed: () => Navigator.pop(context),
                            //           child: Text('OK'),
                            //         ),
                            //       ],
                            //     ),
                            //   );
                            // }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF212529),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MyIcons.orderBookingStatus,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Order Booking Status'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ]
            ),
          ),
        ),
      ),
        //
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),

            child: ElevatedButton.icon(
              onPressed: () async {
                // await MoveToBackground.moveTaskToBack();

                await _toggleClockInOut();
              },
              icon: Icon(
                isClockedIn ? Icons.timer_off : Icons.timer,
                color: isClockedIn ? Colors.white : Colors.white,
              ),
              label: Text(
                isClockedIn ? 'Clock Out' : 'Clock In',
                style: const TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: isClockedIn ? Colors.white : Colors.white,
                backgroundColor: Color(0xFF212529),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }


// Function to request permissions for notifications and location
  Future<bool> requestPermissions(BuildContext context) async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;

    // Request notification permission if not granted
    if (!notificationStatus.isGranted) {
      PermissionStatus newNotificationStatus = await Permission.notification
          .request();

      if (newNotificationStatus.isDenied ||
          newNotificationStatus.isPermanentlyDenied) {
        // Show dialog if permission is denied or permanently denied
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  'Notification permission is required for this app to function properly. Please grant it in the app settings.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    }

    // Request location permission if not granted
    if (!locationStatus.isGranted) {
      PermissionStatus newLocationStatus = await Permission.location.request();

      if (newLocationStatus.isDenied || newLocationStatus.isPermanentlyDenied) {
        // Show dialog if permission is denied or permanently denied
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  'Location permission is required for this app to function properly. Please grant it in the app settings.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    }

    return true;
  }

// Function to show a loading indicator
  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button press
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Please Wait..."),
              ],
            ),
          ),
        );
      },
    );
  }

// Function to check if internet is connected
  Future<bool> isInternetConnected() async {
    bool isConnected = await isInternetAvailable();
    if (kDebugMode) {
      print('Internet Connected: $isConnected');
    }
    return isConnected;
  }

// Function to perform background tasks such as data synchronization
  Future<void> backgroundTask() async {
    try {
      bool isConnected = await isInternetConnected();

      if (isConnected) {
        if (kDebugMode) {
          print(
              'Internet connection is available. Initiating background data synchronization.');
        }
        await synchronizeData(); // Synchronize data
        if (kDebugMode) {
          print('Background data synchronization completed.');
        }
      } else {
        if (kDebugMode) {
          print(
              'No internet connection available. Skipping background data synchronization.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in backgroundTask: $e');
      }
    }
  }


// Function to synchronize data in the background
  Future<void> synchronizeData() async {
    if (kDebugMode) {
      print('Synchronizing data in the background.');
    }
    // Post various data tables
    await postAttendanceTable();
    await postAttendanceOutTable();
    await postLocationData();
    await postShopTable();
    await postShopVisitData();
    await postStockCheckItems();
    await postMasterTable();
    await postOrderDetails();
    await postReturnFormTable();
    await postReturnFormDetails();
    await postRecoveryFormTable();
  }

// Function to post location data
  Future<void> postLocationData() async {
    await locationViewModel.postLocation();
  }

// Function to post shop visit data
  Future<void> postShopVisitData() async {
    await shopisitViewModel.postShopVisit();
  }

// Function to post stock check items
  Future<void> postStockCheckItems() async {
    await stockcheckitemsViewModel.postStockCheckItems();
  }

// Function to post attendance out data
  Future<void> postAttendanceOutTable() async {
    await attendanceViewModel.postAttendanceOut();
  }

// Function to post attendance data
  Future<void> postAttendanceTable() async {
    await attendanceViewModel.postAttendance();
  }

// Function to post master order data
  Future<void> postMasterTable() async {
    await ordermasterViewModel.postOrderMaster();
  }

// Function to post order details
  Future<void> postOrderDetails() async {
    await orderdetailsViewModel.postOrderDetails();
  }

// Function to post shop data
  Future<void> postShopTable() async {
    await shopViewModel.postShop();
  }

// Function to post return form data
  Future<void> postReturnFormTable() async {
    if (kDebugMode) {
      print('Attempting to post Return data');
    }
    await returnformViewModel.postReturnForm();

    if (kDebugMode) {
      print('Return data posted successfully');
    }
  }

// Function to post return form details
  Future<void> postReturnFormDetails() async {
    DBHelper dbHelper = DBHelper();
    await returnformdetailsViewModel.postReturnFormDetails();
  }

// Function to post recovery form data
  Future<void> postRecoveryFormTable() async {
    await recoveryformViewModel.postRecoveryForm();
  }

// Function to request location permission
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print('done');
      }
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}