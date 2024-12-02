import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/get_apis/Get_apis.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/ip_addresses/IP_addresses.dart';
import '../API/ApiServices.dart';
import '../Views/ShopVisit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Globals.dart';
import '../API/newDatabaseOutPuts.dart';
import '../Databases/DBHelper.dart';
import '../Models/loginModel.dart';
import '../View_Models/OwnerViewModel.dart';
import '../main.dart';
import 'HomePage.dart';
import 'NSM/nsm_homepage.dart';
import 'RSMS_Views/RSM_HomePage.dart';
import 'SM/sm_homepage.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  int _loadingProgress = 0;
  final  ownerViewModel = Get.put(OwnerViewModel());
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

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

  final dblogin = DBHelper();

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter ID and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // Exit the method if either field is empty
    }

    setState(() {
      _isLoading = true; // Set loading to true when button is pressed
      _loadingProgress = 0; // Reset progress
    });

    bool isConnected = await isInternetAvailable();
    if (isConnected) {

      await _login();
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
      _isLoading = false; // Set loading to false after login function is complete
    });
  }

  Future<void> _login() async {


    var response = await dblogin.login(
      LoginModel(user_id: _emailController.text, password: _passwordController.text, user_name: ''),
    );

    if (response) {
      var userName = await dblogin.getUserName(_emailController.text);
      var userCity = await dblogin.getUserCity(_emailController.text);
      var designation = await dblogin.getUserDesignation(_emailController.text);
      var brand = await dblogin.getUserBrand(_emailController.text);
      var userRSM = await dblogin.getUserRSM(_emailController.text);
      var userSM = await dblogin.getUserSM(_emailController.text);
      var userNSM = await dblogin.getUserNSM(_emailController.text);

      if (userName != null && userCity != null && designation != null && brand != null) {
        if (kDebugMode) {
          print('User Name: $userName, City: $userCity, Designation: $designation, Brand: $brand, RSM: $userRSM, SM: $userSM, NSM: $userNSM');
        }

        userRSM = userRSM ?? 'NULL';
        userSM = userSM ?? 'NULL';
        userNSM = userNSM ?? 'NULL';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _emailController.text);
        await prefs.setString('userNames', userName);
        await prefs.setString('userCitys', userCity);
        await prefs.setString('userDesignation', designation);
        await prefs.setString('userBrand', brand);
        await  prefs.setString('userRSM', userRSM);
        await prefs.setString('userSM', userSM);
        await prefs.setString('userNSM', userNSM);

        await initializeData();

      } else {
        if (kDebugMode) {
          print('Failed to fetch user name or city');
        }
      }

      Fluttertoast.showToast(msg: "Successfully logged in", toastLength: Toast.LENGTH_LONG);
    } else {
      if (response == 'wrong_password') {
        Fluttertoast.showToast(msg: "Wrong password", toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(msg: "Failed login", toastLength: Toast.LENGTH_LONG);
      }
    }
  }
  _loginRetrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userNames = prefs.getString('userNames') ?? '';
      userCitys = prefs.getString('userCitys') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userSM = prefs.getString('userSM') ?? '';
      userNSM = prefs.getString('userNSM') ?? '';
      userRSM= prefs.getString('userRSM') ?? '';
    });
  }
  Future<void> initializeData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');
    String? brand = prefs.getString('userBrand');
    // DateTime now = DateTime.now();
    // String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
    // await prefs.setString('lastInitializationDateTime', formattedDateTime);

    setState(() {
      _loadingProgress = 05;
    });
    await fetchOwnerData(api, db);
    setState(() {
      _loadingProgress = 10;
    });
    await fetchOwnerData2(api, db);
    setState(() {
      _loadingProgress = 15;
    });
    await fetchOwnerData3(api, db);
    setState(() {
      _loadingProgress = 20;
    });
    await fetchOwnerData3(api, db);

    setState(() {
      _loadingProgress = 25;
    });
    await fetchNetBalanceData(api, db, id);

    setState(() {
      _loadingProgress = 30;
    });
    await fetchRecoveryFormData(api, db, id);

    setState(() {
      _loadingProgress = 40;
    });
    await fetchProductCategoryData(api, db, id);

    setState(() {
      _loadingProgress = 50;
    });
    await fetchPakCitiesData(api, db);

    setState(() {
      _loadingProgress = 60;
    });
    await fetchOrderDetailsData(api, db, id);

    setState(() {
      _loadingProgress = 70;
    });
    await fetchOrderMasterData(api, db, id);

    setState(() {
      _loadingProgress = 80;
    });
    await fetchProductsData(api, db, brand);

    setState(() {
      _loadingProgress = 90;
    });
    await fetchAccountsData(api, db, id);

    setState(() {
      _loadingProgress = 100;
    });
    await fetchOrderBookingStatusData(api, db, id);
    await _loginRetrieveSavedValues();
    bool isLoggedIn = await _checkLoginStatus();
    if (isLoggedIn) {
      Map<String, dynamic> dataToPass = {
        'userName': userNames,
      };

      if (kDebugMode) {
        print('Navigating to homepage for designation: $userDesignation');
      }

      switch (userDesignation) {

        case 'RSM':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RSMHomepage(),
            ),
          );
          break;

        case 'SM':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SMHomepage(),
            ),
          );
          break;

        case 'NSM':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NSMHomepage(),
            ),
          );
          break;

        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: RouteSettings(arguments: dataToPass),
            ),
          );
          break;
      }

      // return;
    }
  }


  Future<void> fetchAccountsData(ApiServices api, DBHelper db, String? id) async {
    var accountsdata = await db.getAccoutsDB();
    if (accountsdata == null || accountsdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$accountApi$id");
        inserted = await db.insertAccountsData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Accounts Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/accounts/get/$id");
          inserted = await db.insertAccountsData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Accounts Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Accounts data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Accounts data is available.");
      }
    }
  }

  Future<void> fetchNetBalanceData(ApiServices api, DBHelper db, String? id) async {
    var netBalancedata = await db.getNetBalanceDB();
    if (netBalancedata == null || netBalancedata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$balance$id");
        inserted = await db.insertNetBalanceData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Net Balance Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/allbalance/get/$id");
          inserted = await db.insertNetBalanceData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Net Balance Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Net Balance data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Net Balance data is available.");
      }
    }
  }

  Future<void> fetchRecoveryFormData(ApiServices api, DBHelper db, String? id) async {
    var recoveryFormGetData = await db.getAllRecoveryFormGetData();
    if (recoveryFormGetData == null || recoveryFormGetData.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$recoveryForm$id");
        inserted = await db.insertRecoveryFormGetData(response);
        if (inserted) {
          if (kDebugMode) {
            print("RecoveryFormGet Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/recovery1/get/$id");
          inserted = await db.insertRecoveryFormGetData(response);
          if (inserted) {
            if (kDebugMode) {
              print("RecoveryFormGet Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert RecoveryFormGet data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("RecoveryFormGet data is available.");
      }
    }
  }

  Future<void> fetchProductCategoryData(ApiServices api, DBHelper db, String? id) async {
    var pCdata = await db.getAllProductCategoryData();
    if (pCdata == null || pCdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$brandsApi$id");
        inserted = await db.insertProductCategoryData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Product Category Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/brand1/get/$id");
          inserted = await db.insertProductCategoryData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Product Category Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Product Category data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Product Category data is available.");
      }
    }
  }

  Future<void> fetchPakCitiesData(ApiServices api, DBHelper db) async {
    var pakCities = await db.getPakCitiesDB();
    if (pakCities == null || pakCities.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi(city);
        inserted = await db.insertPakCitiesData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Pak Cities Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/city/get/");
          inserted = await db.insertPakCitiesData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Pak Cities Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Pak Cities data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Pak Cities data is available.");
      }
    }
  }

  Future<void> fetchOrderDetailsData(ApiServices api, DBHelper db, String? id) async {
    var orderDetailsdata = await db.getAllOrderDetailsData();
    if (orderDetailsdata == null || orderDetailsdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$orderDetails$id");
        inserted = await db.insertOrderDetailsData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Order Details Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/detailsget/get/$id");
          inserted = await db.insertOrderDetailsData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Order Details Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Order Details data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Order Details data is available.");
      }
    }
  }

  Future<void> fetchOrderMasterData(ApiServices api, DBHelper db, String? id) async {
    var orderMasterdata = await db.getAllOrderMasterData();
    if (orderMasterdata == null || orderMasterdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$orderMaster$id");
        inserted = await db.insertOrderMasterData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Order Master Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/masterget1/get/$id");
          inserted = await db.insertOrderMasterData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Order Master Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Order Master data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Order Master data is available.");
      }
    }
  }

  Future<void> fetchProductsData(ApiServices api, DBHelper db, String? brand) async {
    var productsdata = await db.getAllProductsData();
    if (productsdata == null || productsdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi(productsApi);
        inserted = await db.insertProductsData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Products Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/product1/get/$brand");
          inserted = await db.insertProductsData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Products Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Products data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Products data is available.");
      }
    }
  }

  Future<void> fetchOwnerData(ApiServices api, DBHelper db) async {
    var ownersdata = await db.getAllownerData();
    if (ownersdata == null || ownersdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi(shopDetails);
        inserted = await db.insertownerData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Owner Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/shopp1/get/");
          inserted = await db.insertownerData(response);
          if (inserted) {
            if (kDebugMode) {
              print("Owner Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Owner data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Owner data is available.");
      }
    }
  }
  Future<void> fetchOwnerData2(ApiServices api, DBHelper db) async {
    bool inserted = false;
    try {
      var response = await api.getApi(shopDetails2);
      inserted = await db.insertownerData(response);
      if (inserted) {
        if (kDebugMode) {
          print("Owner Data inserted successfully.");
        }
      } else {
        throw Exception('Insertion failed with first API');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error with first API. Trying second API.");
      }
      try {
        var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/shopp1/get/");
        inserted = await db.insertownerData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Owner Data inserted successfully using second API.");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data using second API.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with second API as well. Unable to fetch or insert Owner data.");
        }
      }
    }
  }
  Future<void> fetchOwnerData3(ApiServices api, DBHelper db) async {
    bool inserted = false;
    try {
      var response = await api.getApi(shopDetails3);
      inserted = await db.insertownerData(response);
      if (inserted) {
        if (kDebugMode) {
          print("Owner Data inserted successfully.");
        }
      } else {
        throw Exception('Insertion failed with first API');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error with first API. Trying second API.");
      }
      try {
        var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/shopp1/get/");
        inserted = await db.insertownerData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Owner Data inserted successfully using second API.");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data using second API.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with second API as well. Unable to fetch or insert Owner data.");
        }
      }
    }
  }
  Future<void> fetchOwnerData4(ApiServices api, DBHelper db) async {
    bool inserted = false;
    try {
      var response = await api.getApi(shopDetails4);
      inserted = await db.insertownerData(response);
      if (inserted) {
        if (kDebugMode) {
          print("Owner Data inserted successfully.");
        }
      } else {
        throw Exception('Insertion failed with first API');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error with first API. Trying second API.");
      }
      try {
        var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/shopp1/get/");
        inserted = await db.insertownerData(response);
        if (inserted) {
          if (kDebugMode) {
            print("Owner Data inserted successfully using second API.");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data using second API.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with second API as well. Unable to fetch or insert Owner data.");
        }
      }
    }
  }

  Future<void> fetchOrderBookingStatusData(ApiServices api, DBHelper db, String? id) async {
    var orderBookingStatusdata = await db.getallOrderBookingStatusDB();
    if (orderBookingStatusdata == null || orderBookingStatusdata.isEmpty) {
      bool inserted = false;
      try {
        var response = await api.getApi("$orderBookingStatus$id");
        inserted = await db.insertOrderBookingStatusData1(response);
        if (inserted) {
          if (kDebugMode) {
            print("Order Booking Status Data inserted successfully.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi("https://apex.oracle.com/pls/apex/metaxpertss/statusget1/get/$id");
          inserted = await db.insertOrderBookingStatusData1(response);
          if (inserted) {
            if (kDebugMode) {
              print("Order Booking Status Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error with second API as well. Unable to fetch or insert Order Booking Status data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Order Booking Status data is available.");
      }
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userNames = prefs.getString('userNames');
    String? userCitys = prefs.getString('userCitys');
    String? userDesignation = prefs.getString('userDesignation');
    String? userBrand = prefs.getString('userBrand');
    String? userRSM = prefs.getString('userRSM');
    String? userSM = prefs.getString('userSM');
    String? userNSM = prefs.getString('userNSM');

    return userId != null && userId.isNotEmpty &&
        userNames != null && userNames.isNotEmpty &&
        userCitys != null && userCitys.isNotEmpty &&
        userDesignation != null && userDesignation.isNotEmpty &&
        userBrand != null && userBrand.isNotEmpty &&
        userSM != null && userSM.isNotEmpty &&
        userRSM != null && userRSM.isNotEmpty &&
        userNSM != null && userNSM.isNotEmpty;
  }
  // Future<void> checkUserIdAndFetchShopNames() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userDesignation = prefs.getString('userDesignation');
  //
  //   if (userDesignation == 'ASM' || userDesignation == 'SPO' ||
  //       userDesignation == 'SOS') {
  //     await fetchShopNamesAll();
  //   } else {
  //     await fetchShopNames();
  //   }
  // }
  //
  // Future<void> fetchShopNames() async {
  //   // Fetch shop names from database
  //  await ownerViewModel.fetchShopNamesbycities();
  //   List<String> shopNames = ownerViewModel.shopNamesbycites
  //       .map((dynamic item) => item.toString())
  //       .toSet()
  //       .toList(); // Ensure data is unique and converted to a list of strings
  //   //shopOwners = (await dbHelper.getOwnersDB())!;// Example: Replace with actual fetch from your database
  //   // Save shop names to Hive
  //   var box = await Hive.openBox('shopNamesByCities');
  //   await box.put('shopNamesByCities', shopNames);
  //   List<String> shopNamesByCities = box.get('shopNamesByCities', defaultValue: <String>[]);
  //   if (kDebugMode) {
  //     print('Shop names by cities: $shopNamesByCities');
  //   }
  //   await box.close();
  // }
  //
  // Future<void> fetchShopNamesAll() async {
  //   // Fetch shop names from database
  //  await ownerViewModel.fetchShopNames();// Example: Replace with actual fetch from your database
  //   List<String> shopNames = ownerViewModel.shopNames
  //       .map((dynamic item) => item.toString())
  //       .toSet()
  //       .toList(); // Ensure data is unique and converted to a list of strings
  //   //shopOwners = (await dbHelper.getOwnersDB())!;
  //   // Save shop names to Hive
  //   var box = await Hive.openBox('shopNames');
  //   await box.put('shopNames', shopNames);
  //   List<String> allShopNames = box.get('shopNames', defaultValue: <String>[]);
  //   if (kDebugMode) {
  //     print('All shop names: $allShopNames');
  //   }
  //   await box.close();
  //
  // }
  // Future<void> checkStoredData() async {
  //   var box = await Hive.openBox('shopNamesByCities');
  //   List<String> shopNamesByCities = box.get('shopNamesByCities', defaultValue: <String>[]);
  //   if (kDebugMode) {
  //     print('Shop names by cities: $shopNamesByCities');
  //   }
  //   await box.close();
  //
  //   box = await Hive.openBox('shopNames');
  //   List<String> shopNames = box.get('shopNames', defaultValue: <String>[]);
  //   if (kDebugMode) {
  //     print('All shop names: $shopNames');
  //   }
  //   await box.close();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => !_isLoading, // Prevent back button if loading
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          'assets/images/mxlogo-01.png',
                          width: 300.0,
                          height: 250.0,
                        ),
                      ),
                      const SizedBox(height: 0.0),
                      const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF212529),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'User ID',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(1.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color:const Color(0xFF212529),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color:Color(0xFF212529), width: 0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(1.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF212529),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        height: 40,
                        width: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF212529),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _isLoading ? 200 * _loadingProgress / 100 : 0,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF212529),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLoading ? '$_loadingProgress%' : 'Login',
                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                    const Icon(Icons.arrow_forward, color: Colors.white,),
                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),

                      ),
                      const SizedBox(height: 10.0),
                     Center(
                        child: Text(
                          version,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // Makes the text bold
                            color: Colors.black,        // Sets the text color to black
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    'assets/images/b1.png',
                                    width: 23.0,
                                    height: 23.0,
                                  ),
                                  const Text(
                                    'MetaXperts',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    '03456699233',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 6,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) // Show the modal barrier and loading indicator if _isLoading is true
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
