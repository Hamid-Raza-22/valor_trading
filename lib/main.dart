import 'dart:async' show Future, Timer;
import 'dart:io' as io;
import 'dart:io' show Directory, InternetAddress, Platform, SocketException;
import 'dart:ui' show DartPluginRegistrant;
import 'package:connectivity/connectivity.dart';
import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' show MaterialApp, WidgetsFlutterBinding, runApp;
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart' show AndroidConfiguration, FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:flutter_background_service_android/flutter_background_service_android.dart' show AndroidServiceInstance;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' show AndroidFlutterLocalNotificationsPlugin, AndroidInitializationSettings, AndroidNotificationChannel, AndroidNotificationDetails, DarwinInitializationSettings, FlutterLocalNotificationsPlugin, Importance, InitializationSettings, NotificationDetails;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/ip_addresses/IP_addresses.dart';

import '../Tracker/trac.dart' show startTimer;
import '../Views/PolicyDBox.dart';
import '../location00.dart' show LocationService;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart' show Workmanager;
import 'API/DatabaseOutputs.dart';
import 'API/Globals.dart';
import 'API/newDatabaseOutPuts.dart';
import 'Databases/DBHelper.dart';
import 'View_Models/AttendanceViewModel.dart';
import 'View_Models/ShopVisitViewModel.dart';
import 'View_Models/StockCheckItems.dart';
import 'Views/splash_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:upgrader/upgrader.dart' show Upgrader;
import '../View_Models/LocationViewModel.dart';
import '../View_Models/OrderViewModels/OrderDetailsViewModel.dart';
import '../View_Models/OrderViewModels/OrderMasterViewModel.dart';
import '../View_Models/OrderViewModels/ReturnFormDetailsViewModel.dart';
import '../View_Models/OrderViewModels/ReturnFormViewModel.dart';
import '../View_Models/RecoveryFormViewModel.dart';
import '../View_Models/ShopViewModel.dart';
DBHelper dbHelper = DBHelper();
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Upgrader;
  try {
    //await getIpAddress();
    if (kDebugMode) {
      print('IP Address: $IP_Address');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to get IP Address: $e');
    }
  }
// await dbHelper.db;
  // Clear previous database if exists
  //await _clearDatabaseIfFirstLaunch();
  //iqra
// hamid
  // // AndroidAlarmManager.initialize();
  //
  // Initialize the FlutterBackground plugin
  // await FlutterBackground.initialize();
  //
  // // Enable background execution
  // await FlutterBackground.enableBackgroundExecution();
  newDatabaseOutputs outputs = newDatabaseOutputs();
  outputs.initializeLoginData();

  // Request notification permissions
  // await _requestPermissions();

  // await initializeServiceLocation();

  // Ensure Firebase is initialized before running the apm
  await Firebase.initializeApp();
  await Hive.initFlutter();
  // await BackgroundLocator.initialize();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}
final shopViewModel = Get.put(ShopViewModel());
final attendanceViewModel = Get.put(AttendanceViewModel());
final shopisitViewModel = Get.put(ShopVisitViewModel());
final stockcheckitemsViewModel = Get.put(StockCheckItemsViewModel());
final recoveryformViewModel = Get.put(RecoveryFormViewModel());
final returnformdetailsViewModel = Get.put(ReturnFormDetailsViewModel());
final returnformViewModel = Get.put(ReturnFormViewModel());
final ordermasterViewModel = Get.put(OrderMasterViewModel());
final orderdetailsViewModel = Get.put(OrderDetailsViewModel());
final locationViewModel = Get.put(LocationViewModel());
Future<void> _requestPermissions() async {
  // Request notification permission
  if (await Permission.notification.request().isDenied) {
    // Notification permission not granted
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return;
  }

  // Request location permission
  if (await Permission.location.request().isDenied) {
    // Location permission not granted
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

// Future<void> initializeDatabase() async {
//
//   await dbHelper.db;
// }
Future<void> _clearDatabaseIfFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'valorTrading.db');

    if (await io.File(path).exists()) {
      // await deleteDatabase(path);
      await _logOut();
      if (kDebugMode) {
        print('Previous database cleared.');
      }
    } else {
      if (kDebugMode) {
        print('No previous database found to clear.');
      }
    }

    await prefs.setBool('isFirstLaunch', false);
  } else {
    if (kDebugMode) {
      print('This is not the first launch. Database was not cleared.');
    }
  }
}
Future<void> _logOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Clear the user ID or any other relevant data from SharedPreferences
  prefs.remove('userId');
  prefs.remove('userCitys');
  prefs.remove('userNames');
  prefs.remove('userDesignation');
  prefs.remove('userBrand');
  if (kDebugMode) {
    print('Previous SharedPreferences cleared.');
  }
  // Add any additional logout logic here
}
void callbackDispatcher(){
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print("WorkManager MMM ");
    }
    return Future.value(true);
  });
}
// Future<void> deleteDatabaseFile() async {
//   io.Directory documentDirectory = await getApplicationDocumentsDirectory();
//   String path = join(documentDirectory.path, 'shop.db');
//   await deleteDatabase(path);
// }
Future<void> initializeServiceLocation() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
  monitorInternetConnection(); // Add this line to monitor connectivity changes

}


void monitorInternetConnection() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      // backgroundTask();
    }
  });
}
Future<bool> isInternetAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  } else {
    return false; // No connectivity
  }
  return false;
}

// Future<void> initializeServiceBackGroundData() async {
//   final service1 = FlutterBackgroundService();
//
//   await service1.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart1,
//       autoStart: true,
//       isForegroundMode: false, // Change this to false
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart1,
//     ),
//   );
// }

@pragma('vm:entry-point')
void onStart1(ServiceInstance service1) async {
  DartPluginRegistrant.ensureInitialized();

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service1 is AndroidServiceInstance) {
      if (await service1.isForegroundService()) {
        backgroundTask();
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device1;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device1 = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device1 = iosInfo.model;
    }

    service1.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device1,
      },
    );
  }
  );
}


@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  LocationService locationService = LocationService();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      backgroundTask();
      //ls.listenLocation();
    });
  }

  service.on('stopService').listen((event) async {
    locationService.stopListening();
    locationService.deleteDocument();
    Workmanager().cancelAll();
    service.stopSelf();
    //stopListeningLocation();
    FlutterLocalNotificationsPlugin().cancelAll();
  });
  monitorInternetConnection(); // Add this line to monitor connectivity changes

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        backgroundTask();
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device1;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device1 = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device1 = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device1,
      },
    );
  }
  );

  Workmanager().registerPeriodicTask("1", "simpleTask", frequency: const Duration(minutes: 15));

  if(isClockedIn == false){
    startTimer();
    locationService.listenLocation();
  }

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {

        // flutterLocalNotificationsPlugin.show(
        //   888,
        //   'COOL SERVICE',
        //   'Awesome',
        //   const NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       'my_foreground',
        //       'MY FOREGROUND SERVICE',
        //       icon: 'ic_bg_service_small',
        //       ongoing: true,
        //       priority: Priority.high,
        //     ),
        //   ),
        // );

        // flutterLocalNotificationsPlugin.show(
        //   889,
        //   'Location',
        //   'Longitude ${locationService.longi} , Latitute ${locationService.lat}',
        //   const NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       'my_foreground',
        //       'MY FOREGROUND SERVICE',
        //       icon: 'ic_bg_service_small',
        //       ongoing: true,
        //     ),
        //   ),
        // );

        service.setForegroundNotificationInfo(
          title: "ClockIn",
          content: "Timer ${_formatDuration(secondsPassed.toString())}",
        );
      }
    }



    final deviceInfo = DeviceInfoPlugin();
    String? device;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}


String _formatDuration(String secondsString) {
  int seconds = int.parse(secondsString);
  Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$secondsFormatted';
}


backgroundTask() async {

  try {
    bool isConnected = await isInternetAvailable();
    DatabaseOutputs outputs = DatabaseOutputs();
    if (isConnected) {
      if (kDebugMode) {
        print('Internet connection is available. Initiating background data synchronization.');
      }
      await synchronizeData();
      // await outputs.initializeDatalogin();

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
Future<void> postLocationData() async {
  await locationViewModel.postLocation();
}
Future<void> postShopVisitData() async {
  await shopisitViewModel.postShopVisit();
}

Future<void> postStockCheckItems() async {
  await stockcheckitemsViewModel.postStockCheckItems();
}

Future<void> postAttendanceOutTable() async {
  await attendanceViewModel.postAttendanceOut();
}

Future<void> postAttendanceTable() async {
  await attendanceViewModel.postAttendance();

}

Future<void> postMasterTable() async {
  await ordermasterViewModel.postOrderMaster();

}

Future<void> postOrderDetails() async {
  await orderdetailsViewModel.postOrderDetails();

}

Future<void> postShopTable() async {
  await shopViewModel.postShop();
}

Future<void> postReturnFormTable() async {
  if (kDebugMode) {
    print('Attempting to post Return data');
  }
  await returnformViewModel.postReturnForm();

  if (kDebugMode) {
    print('Return data posted successfully');
  }
}

Future<void> postReturnFormDetails() async {

  await returnformdetailsViewModel.postReturnFormDetails();
}

Future<void> postRecoveryFormTable() async {
  await recoveryformViewModel.postRecoveryForm();

}






