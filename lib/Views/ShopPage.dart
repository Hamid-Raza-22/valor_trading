import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, FontWeight, LengthLimitingTextInputFormatter, Size, TextEditingValue, TextInputFormatter, TextInputType, TextSelection;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart' show TextFieldConfiguration, TypeAheadFormField;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:flutter/foundation.dart' show Key, Uint8List, kDebugMode;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, Position;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nanoid/async.dart' show customAlphabet;
import '../API/Globals.dart' show shopAddress, userCitys, userDesignation, userId;
import '../View_Models/ShopViewModel.dart' show ShopViewModel;
import '../Views/HomePage.dart' show HomePage;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/DBHelper.dart';
import '../Models/ShopModel.dart';
import '../main.dart';



class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class AlphabeticInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow only alphabets
    final newText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CNICFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow only up to 13 digits
    if (text.length > 13) {
      return oldValue;
    }

    final newText = StringBuffer();

    // Add slashes after the first five digits and twelfth digit
    if (text.length > 5) {
      newText.write('${text.substring(0, 5)}-');
      if (text.length > 12) {
        newText.write('${text.substring(5, 12)}-');
        newText.write(text.substring(12));
      } else {
        newText.write(text.substring(5));
      }
    } else {
      newText.write(text);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _ShopPageState extends State<ShopPage> {

  final shopViewModel = Get.put(ShopViewModel());

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController shopAddressController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerCNICController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController alternativePhoneNoController = TextEditingController();

  final FocusNode shopNameFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode shopAddressFocusNode = FocusNode();
  final FocusNode ownerNameFocusNode = FocusNode();
  final FocusNode ownerCNICFocusNode = FocusNode();
  final FocusNode phoneNoFocusNode = FocusNode();
  final FocusNode alternativePhoneNoFocusNode = FocusNode();
  static double? globalLatitude;
  static double? globalLongitude;
  bool isButtonPressed2 = false;
  bool showLoading = false;
  int? shopId;
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isLocationAdded = false;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();
  get shopData => null;
  List<String> citiesDropdownItems = [];
bool isOrderConfirmedback = false;
  DBHelper dbHelper = DBHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> shopOwners = [];

  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDesignation = prefs.getString('userDesignation');

    if (userDesignation != 'ASM' && userDesignation != 'SPO' && userDesignation != 'SOS' ) {
      //  await fetchShopNames();
      setState(() {
        cityController.text = userCitys;
        //  distributorNameController.text = 'M.A Traders Sialkot';
        cityController.selection = TextSelection.collapsed(offset: cityController.text.length);
      });

    } else {
      await fetchCitiesNames();
      //await fetchShopNames1();
    }
  }

  Future<void> fetchCitiesNames() async {
    List<dynamic> bussinessName = await dbHelper.getCitiesNames();
    setState(() {
      // Explicitly cast each element to String
      citiesDropdownItems = bussinessName.map((dynamic item) => item.toString()).toSet().toList();
    });
  }

  // Future<void> fetchShopNames() async {
  //   String userCity = userCitys;
  //   List<dynamic> bussinessName = await dbHelper. getDistributorNamesForCity(userCity);
  //   setState(() {
  //     // Explicitly cast each element to String
  //     dropdownItems = bussinessName.map((dynamic item) => item.toString()).toSet().toList();
  //   });
  // }
  //
  // Future<void> fetchShopNames1() async {
  //   List<dynamic> bussinessName = await dbHelper.getDistributorsNames();
  //   setState(() {
  //     // Explicitly cast each element to String
  //     dropdownItems = bussinessName.map((dynamic item) => item.toString()).toSet().toList();
  //   });
  // }
  Future<void> saveImage()  async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/captured_image.jpg';

      // Compress the image76
      Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
        _imageFile!.path,
        minWidth: 400,
        minHeight: 600,
        quality:40,
      );

      // Save the compressed image
      await File(filePath).writeAsBytes(compressedImageBytes!);

      if (kDebugMode) {
        print('Compressed image saved successfully at $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing and saving image: $e');
      }
    }
  }

  @override
  void initState() {

    super.initState();
    saveCurrentLocation();
    _checkUserIdAndFetchShopNames();
  }

  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude  = position.latitude ;
        globalLongitude = position.longitude ;

        if (kDebugMode) {
          print('Latitude: $globalLatitude, Longitude: $globalLongitude');
        }
        // Using geocoding to convert latitude and longitude to an address
        List<Placemark> placemarks = await placemarkFromCoordinates(globalLatitude! , globalLongitude!);
        Placemark currentPlace = placemarks[0];

        String address1 = "${currentPlace.thoroughfare} ${currentPlace.subLocality}, ${currentPlace.locality}${currentPlace.postalCode}, ${currentPlace.country}";
        shopAddress = address1;

        if (kDebugMode) {
          print('Address is: $address1');
        }

        //print('Address is: $address1');
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location:$e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Location permission is not granted');
      }
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    cityController.dispose();
    shopAddressController.dispose();
    ownerNameController.dispose();
    ownerCNICController.dispose();
    phoneNoController.dispose();
    alternativePhoneNoController.dispose();

    shopNameFocusNode.dispose();
    cityFocusNode.dispose();
    shopAddressFocusNode.dispose();
    ownerNameFocusNode.dispose();
    ownerCNICFocusNode.dispose();
    phoneNoFocusNode.dispose();
    alternativePhoneNoFocusNode.dispose();

    super.dispose();
  }
  Future<void> _validateAndSave() async {
    setState(() {
      isButtonPressed2= true;
    });
    final form = _formKey.currentState;
    if (form!.validate()) {
      String selectedCity = cityController.text.trim();
      if (kDebugMode) {
        print('Selected City: $selectedCity');
      }
      bool isCityValid = true;
      if (userDesignation == 'RSM' || userDesignation == 'NSM' || userDesignation == 'SM' || userDesignation == 'ASM' || userDesignation == 'SPO' || userDesignation == 'SOS') {
        var box = await Hive.openBox('shopNames');
        List<String> shopNames = box.get('shopNames')?.cast<String>() ?? [];
        shopNames.add(shopNameController.text);
        await box.put('shopNames', shopNames);
        await box.close();
        if (kDebugMode) {
          print(' Hive shopNames');
        }
        isCityValid = selectedCity.isNotEmpty && citiesDropdownItems.contains(selectedCity);
      }else{
        var box = await Hive.openBox('shopNamesByCities');
        List<String> shopNamesByCities = box.get('shopNamesByCities')?.cast<String>() ?? [];
        shopNamesByCities.add(shopNameController.text);
        await box.put('shopNamesByCities', shopNamesByCities);
        await box.close();
        if (kDebugMode) {
          print(' Hive shopNamesby cities');
        }
      }

      if (isCityValid) {
      if (
      // _imageFile == null ||
          shopNameController.text.isEmpty ||
          cityController.text.isEmpty ||
          shopAddressController.text.isEmpty ||
          ownerNameController.text.isEmpty ||
          ownerCNICController.text.length < 13 ||
          phoneNoController.text.isEmpty ||
          alternativePhoneNoController.text.isEmpty) {
        // Show toast message for invalid input
        Fluttertoast.showToast(
          msg: 'Please fill all fields properly.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        // Highlight empty fields in red and focus on the first one
        if (shopNameController.text.isEmpty) {
          shopNameFocusNode.requestFocus();
        } else if (cityController.text.isEmpty) {
          cityFocusNode.requestFocus();
        } else if (shopAddressController.text.isEmpty) {
          shopAddressFocusNode.requestFocus();
        } else if (ownerNameController.text.isEmpty) {
          ownerNameFocusNode.requestFocus();
        } else if (ownerCNICController.text.length < 13) {
          ownerCNICFocusNode.requestFocus();
        } else if (phoneNoController.text.isEmpty) {
          phoneNoFocusNode.requestFocus();
        } else if (alternativePhoneNoController.text.isEmpty) {
          alternativePhoneNoFocusNode.requestFocus();
        }
        setState(() {
          isButtonPressed2= false;
        });

        return;
      }
      setState(() {
        showLoading = true;
      });
      isOrderConfirmedback= true;
      // Proceed with saving data if validation passes
      // Add your data saving logic here
      // String imagePath =  _imageFile!.path;
      // List<int> imageBytesList = await File(imagePath).readAsBytes();
      // Uint8List? imageBytes = Uint8List.fromList(imageBytesList);
       var id = await customAlphabet('1234567890', 12);

      // double? latitude = currentLocation['latitude'];
      // double? longitude = currentLocation['longitude'];

      shopViewModel.addShop(ShopModel(
        id: int.parse(id),
        shopName: shopNameController.text,
        city: cityController.text,
        date: currentDate,
        shopAddress: shopAddressController.text,
        ownerName: ownerNameController.text,
        ownerCNIC: ownerCNICController.text,
        phoneNo: phoneNoController.text,
        alternativePhoneNo: alternativePhoneNoController.text,
        latitude: globalLatitude,
        longitude: globalLongitude,
        userId: userId,
        address: shopAddress
        //body: imageBytes,
        // ... existing parameters ...
        // latitude: shopViewModel.latitude,
        // longitude: shopViewModel.longitude,
      ));


      String shopid = await shopViewModel.fetchLastShopId();
      shopId = int.parse(shopid);



      //
      //
      // shopNameController.text = "";
      // cityController.text = "";
      // shopAddressController.text = "";
      // ownerNameController.text = "";
      // ownerCNICController.text = "";
      // phoneNoController.text = "";
      // alternativePhoneNoController.text = "";
      bool isConnected = await isInternetAvailable();
      if (isConnected== true) {
        shopViewModel.postShop();
      }

      // DBHelper dbmaster = DBHelper();
      //
      // dbmaster.postShopTable();

      // Navigate to the home page after saving
      // Inside the ShopPage where you navigate back to HomePage
      // Introduce a 5-second delay

      await Future.delayed(const Duration(seconds: 8));

      Navigator.pop(context);
      const HomePage(); // Stop the timer when navigating back

      // Show success toast message
      Fluttertoast.showToast(
        msg: 'Data saved successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      // Show toast message for invalid city
      Fluttertoast.showToast(
        msg: 'Please select a valid city.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    } else {
      // Show toast message for invalid input
      Fluttertoast.showToast(
        msg: 'Please fill all fields properly.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      isOrderConfirmedback=false;
    }
    setState(() {
      showLoading = false;
      isButtonPressed2 = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Check if the order is confirmed
      if (isOrderConfirmedback) {
        // Order is confirmed, prevent going back
        return false;
      } else {
        return true;
      }
    },
    child: SafeArea(
     child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                  children: <Widget>[Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Display the live date
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ' Date: $currentDate',
                            style: const TextStyle(
                              fontSize: 13,

                            ),
                          ),
                        ),
                      ), const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Text Field 1 - Shop Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Shop Name',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: shopNameController,
                                  focusNode: shopNameFocusNode,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[/\\]')), // Filter out the '/' and '\' characters
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjust the padding as needed
                                    labelText: 'Enter Shop Name',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter shop name';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'City',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (userDesignation != 'SM' && userDesignation != 'NSM' && userDesignation != 'RSM' && userDesignation != 'SPO'  && userDesignation != 'SOS') TextFormField(
                                  controller: cityController,

                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: 'Enter City',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ) else TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: cityController,
                                    focusNode: cityFocusNode,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                      labelText: 'Enter City',
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please select a valid city';
                                    } else {
                                      return null; // Return null if validation passes
                                    }
                                  },
                                  suggestionsCallback: (pattern) {
                                    return citiesDropdownItems.where((city) => city.toLowerCase().contains(pattern.toLowerCase())).toList();
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    if (citiesDropdownItems.contains(suggestion)) {
                                      setState(() {
                                        cityController.text = suggestion;
                                      });
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Invalid City'),
                                            content: const Text('Please select a city from the provided list.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Text Field 2 - Shop Address
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Shop Address',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: shopAddressController,
                                  focusNode: shopAddressFocusNode,
                                  decoration: InputDecoration( contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),                              labelText: 'Enter Shop Address',
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter shop address';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Text Field 3 - Owner Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Owner Name',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: ownerNameController,
                                  focusNode: ownerNameFocusNode,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: 'Enter Owner Name',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter owner name';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height:10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Owner CNIC',
                                    style:       TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: ownerCNICController,
                                  focusNode: ownerCNICFocusNode,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                    CNICFormatter(),
                                  ],
                                  keyboardType: TextInputType.phone, // Set the keyboard type to phone
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: '_____-_______-_',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter CNIC';
                                    }
                                    if (value.length < 13) {
                                      return 'CNIC must be at least 13 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Text Field 5 - Phone Number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Phone Number',
                                    style:       TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: phoneNoController,
                                  focusNode: phoneNoFocusNode,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11), // Limit the length to 11 characters
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: '03_________',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter mobile num';
                                    } else if (value.length != 11) {
                                      return 'Phone number must be 11 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),


                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Alternative Phone Number',
                                    style:  TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: alternativePhoneNoController,
                                  focusNode: alternativePhoneNoFocusNode,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11), // Limit the length to 11 characters
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: '03_________',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty && value.length != 11) {
                                      return 'Alternative phone number / Enter 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                             const SizedBox(height: 20),
                            // ElevatedButton(
                            //   onPressed: () async {
                            //     try {
                            //       final image = await _imagePicker.getImage(
                            //         source: ImageSource.camera,
                            //         imageQuality: 40, // Adjust the quality (0 to 100)
                            //       );
                            //
                            //       if (image != null) {
                            //         setState(() {
                            //           _imageFile = File(image.path);
                            //
                            //           shopData?['imagePath'] = _imageFile!.path;
                            //
                            //           // // Convert the image file to bytes and store it in _imageBytes
                            //           // List<int> imageBytesList = _imageFile!.readAsBytesSync();
                            //           // _imageBytes = Uint8List.fromList(imageBytesList);
                            //         });
                            //
                            //         // Save only the image
                            //         await saveImage();
                            //
                            //       } else {
                            //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            //           content: Text('No image selected.'),
                            //         ));
                            //       }
                            //     } catch (e) {
                            //       if (kDebugMode) {
                            //         print('Error capturing image: $e');
                            //       }
                            //     }
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.green,
                            //     foregroundColor: Colors.white,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(5),
                            //     ),
                            //   ),
                            //   child: const Text('+ Add Photo'),
                            // ),
                            //
                            // const SizedBox(height: 10),
                            // // Add the Stack widget to overlay the warning icon on top of the image
                            // Stack(
                            //   alignment: Alignment.center,
                            //   children: [
                            //     if (_imageFile != null)
                            //       Image.file(
                            //         _imageFile!,
                            //         height: 300,
                            //         width: 400,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     if (_imageFile == null)
                            //       const Icon(
                            //         Icons.warning,
                            //         color: Colors.red,
                            //         size: 48,
                            //       ),
                            //   ],
                            // ),
                            // const SizedBox(height: 20),
                            // Align the "save" button to the bottom right
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: 100,
                                height: 30,
                                child: ElevatedButton(
                                 onPressed: isButtonPressed2 || showLoading
                                         ? null
                                     : () async {_validateAndSave();},

                                   style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(200, 50),
                                  ),

                                  child:  showLoading
                                ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                                 : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                ),


                              ),
                            ),
                            )

                          ],
                        ),
                      ),
                    ],
                  ),
                  ]),
            ),
          ),
        )
    ));
    }
}