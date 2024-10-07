import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/ip_addresses/IP_addresses.dart';
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
    bool isLoggedIn = await _checkLoginStatus();

    var response = await dblogin.login(
      Users(user_id: _emailController.text, password: _passwordController.text, user_name: ''),
    );

    if (response == true) {
      setState(() {
        _loadingProgress = 20; // Start progress
      });
      var userName = await dblogin.getUserName(_emailController.text);
      var userCity = await dblogin.getUserCity(_emailController.text);
      var designation = await dblogin.getUserDesignation(_emailController.text);
      // var brand = await dblogin.getUserBrand(_emailController.text);

      setState(() {
        _loadingProgress = 40; // Update progress
      });

      if (userName != null && userCity != null && designation != null) {
        if (kDebugMode) {
          print('User Name: $userName, City: $userCity, Designation: $designation');
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', _emailController.text);
        prefs.setString('userNames', userName);
        prefs.setString('userCitys', userCity);
        prefs.setString('userDesignation', designation);
        //prefs.setString('userBrand', brand);

        if (kDebugMode) {
          print('Saved userId: ${prefs.getString('userId')}');
          print('Saved userNames: ${prefs.getString('userNames')}');
          print('Saved userCitys: ${prefs.getString('userCitys')}');
          print('Saved userDesignation: ${prefs.getString('userDesignation')}');
          // print('Saved userBrand: ${prefs.getString('userBrand')}');
        }

        newDatabaseOutputs outputs = newDatabaseOutputs();
        setState(() {
          _loadingProgress = 75; // Update progress
        });
       // await getIpAddress();
        await outputs.checkFirstRun();
        setState(() {
          _loadingProgress = 90; // Update progress
        });
        // await checkUserIdAndFetchShopNames();

        // Call _checkUserIdAndFetchShopNames from ShopVisitState
        // await shopVisitState.checkUserIdAndFetchShopNames();
        // await ShopVisitState().checkUserIdAndFetchShopNames();
        if (isLoggedIn) {
          Map<String, dynamic> dataToPass = {
            'userName': userNames
          };
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: RouteSettings(arguments: dataToPass),
            ),
          );
          return;
        }

        setState(() {
          _loadingProgress = 100; // Update progress
        });

        Map<String, dynamic> dataToPass = {
          'userName': userName,
        };

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: RouteSettings(arguments: dataToPass),
          ),
        );
      } else {
        if (kDebugMode) {
          print('Failed to fetch user name or city');
        }
      }
      Fluttertoast.showToast(msg: "Successfully logged in", toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(msg: "Failed login", toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userNames = prefs.getString('userNames');
    String? userCitys = prefs.getString('userCitys');
    String? userDesignation = prefs.getString('userDesignation');
   // String? userBrand = prefs.getString('userBrand');
    return userDesignation != null && userId != null && userId.isNotEmpty && userCitys != null && userCitys.isNotEmpty && userNames != null && userNames.isNotEmpty;
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
                                  color:Color(0xFF212529),
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
                                  color: Color(0xFF212529),
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
                                color: Color(0xFF212529),
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
                                backgroundColor: Color(0xFF212529),
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
                          'V.1.0.0',
                          style: TextStyle(
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
