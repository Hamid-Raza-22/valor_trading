import 'dart:io' show File;

import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nanoid/async.dart' show customAlphabet;
import '../API/Globals.dart' show shopAddress, userBrand, userCitys, userDesignation, userId;
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

// Formatter to allow only alphabets
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

// Formatter to format CNIC input
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

  // Controllers for text input fields
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController shopAddressController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerCNICController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController alternativePhoneNoController = TextEditingController();

  // Focus nodes for managing focus in text fields
  final FocusNode shopNameFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode shopAddressFocusNode = FocusNode();
  final FocusNode ownerNameFocusNode = FocusNode();
  final FocusNode ownerCNICFocusNode = FocusNode();
  final FocusNode phoneNoFocusNode = FocusNode();
  final FocusNode alternativePhoneNoFocusNode = FocusNode();
  static double? globalLatitude;
  static double? globalLongitude;
  bool isLocationFetched = false;
  bool isLocationChecked = false; // Checkbox state
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

  // Function to check user ID and fetch shop names
  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDesignation = prefs.getString('userDesignation');

    // Check user designation and set cityController text accordingly
    if (userDesignation != 'SM' && userDesignation != 'NSM' &&
        userDesignation != 'RSM' && userDesignation != 'ASM' &&
        userDesignation != 'SPO' && userDesignation != 'SOS') {
      setState(() {
        cityController.text = userCitys;
        cityController.selection = TextSelection.collapsed(offset: cityController.text.length);
      });
    } else {
      await fetchCitiesNames();
    }
  }

  // Function to fetch city names
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
// Function to save an image
  Future<void> saveImage() async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/captured_image.jpg';

      // Compress the image
      Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
        _imageFile!.path,
        minWidth: 400,
        minHeight: 600,
        quality: 40,
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
    // Save current location when initializing (if needed)
    // saveCurrentLocation(context);
    _checkUserIdAndFetchShopNames();
  }

  bool isSwitchDisabled = false; // State variable to disable switch

// Function to save the current location
  Future<void> saveCurrentLocation(BuildContext context) async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      isLoadingLocation = true; // Start loading
      isSwitchDisabled = true;  // Disable the switch while loading
    });

    // Request location permission
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        // Get the current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude = position.latitude;
        globalLongitude = position.longitude;

        if (kDebugMode) {
          print('Latitude: $globalLatitude, Longitude: $globalLongitude');
        }

        // Default address to "Pakistan" initially
        String address1 = "Pakistan";

        try {
          // Attempt to get the address from coordinates
          List<Placemark> placemarks = await placemarkFromCoordinates(
              globalLatitude!, globalLongitude!);
          Placemark? currentPlace = placemarks.isNotEmpty ? placemarks[0] : null;

          if (currentPlace != null) {
            // Construct the address from the placemark
            address1 = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";

            // Check if the constructed address is empty, fallback to "Pakistan"
            if (address1.trim().isEmpty) {
              address1 = "Pakistan";
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting placemark: $e');
          }
          // Keep the address as "Pakistan"
        }

        shopAddress = address1;
        isLocationFetched = true; // Set location fetched to true
        isGpsEnabled = true; // GPS is enabled

        if (kDebugMode) {
          print('Address is: $address1');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
        isGpsEnabled = false; // GPS is not enabled
      }
    } else {
      if (kDebugMode) {
        print('Location permission is not granted');
      }
      // Ensure GPS remains disabled
      isGpsEnabled = false;
      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

    if (!mounted) return; // Check again before calling setState
    setState(() {
      isLoadingLocation = false; // Stop loading
      isSwitchDisabled = false;  // Re-enable the switch after loading
    });
  }


  @override
  void dispose() {
    // Dispose controllers to free up resources
    shopNameController.dispose();
    cityController.dispose();
    shopAddressController.dispose();
    ownerNameController.dispose();
    ownerCNICController.dispose();
    phoneNoController.dispose();
    alternativePhoneNoController.dispose();

    // Dispose focus nodes to free up resources
    shopNameFocusNode.dispose();
    cityFocusNode.dispose();
    shopAddressFocusNode.dispose();
    ownerNameFocusNode.dispose();
    ownerCNICFocusNode.dispose();
    phoneNoFocusNode.dispose();
    alternativePhoneNoFocusNode.dispose();

    super.dispose();
  }

// Function to validate and save shop information
  Future<void> _validateAndSave() async {
    setState(() {
      isButtonPressed2 = true;
    });
    final form = _formKey.currentState;
    if (form!.validate()) {
      String selectedCity = cityController.text.trim();
      if (kDebugMode) {
        print('Selected City: $selectedCity');
      }
      bool isCityValid = true;
      if (userDesignation == 'RSM' || userDesignation == 'NSM' ||
          userDesignation == 'SM' || userDesignation == 'ASM' ||
          userDesignation == 'SPO' || userDesignation == 'SOS') {
        // Add shop name to Hive box for shop names
        var box = await Hive.openBox('shopNames');
        List<String> shopNames = box.get('shopNames')?.cast<String>() ?? [];
        shopNames.add(shopNameController.text);
        await box.put('shopNames', shopNames);
        await box.close();
        if (kDebugMode) {
          print(' Hive shopNames');
        }
        isCityValid = selectedCity.isNotEmpty && citiesDropdownItems.contains(selectedCity);
      } else {
        // Add shop name to Hive box for shop names by cities
        var box = await Hive.openBox('shopNamesByCities');
        List<String> shopNamesByCities = box.get('shopNamesByCities')?.cast<String>() ?? [];
        shopNamesByCities.add(shopNameController.text);
        await box.put('shopNamesByCities', shopNamesByCities);
        await box.close();
        if (kDebugMode) {
          print(' Hive shopNames by cities');
        }
      }

      if (isCityValid) {
        // Validate all required fields
        if (isLocationFetched == false ||
            shopNameController.text.isEmpty ||
            cityController.text.isEmpty ||
            shopAddressController.text.isEmpty ||
            ownerNameController.text.isEmpty ||
            ownerCNICController.text.length < 13 ||
            phoneNoController.text.isEmpty ||
            alternativePhoneNoController.text.isEmpty) {
          // Show toast message for invalid input
          Fluttertoast.showToast(
            msg: 'Please fill all fields properly and enable GPS.',
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
            isButtonPressed2 = false;
          });

          return;
        }
        setState(() {
          showLoading = true;
        });
        isOrderConfirmedback = true;

        // Save shop information if validation passes
        var id = await customAlphabet('1234567890', 12);

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
            brand: userBrand,
            address: shopAddress
        ));

        String shopid = await shopViewModel.fetchLastShopId();
        shopId = int.parse(shopid);

        bool isConnected = await isInternetAvailable();
        if (isConnected == true) {
          shopViewModel.postShop();
        }

        // Navigate to the home page after saving
        await Future.delayed(const Duration(seconds: 8));
        Navigator.pop(context);
        const HomePage(); // Stop the timer when navigating back

        // Show success toast message
        Fluttertoast.showToast(
          msg: 'Data saved successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
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
      isOrderConfirmedback = false;
    }
    setState(() {
      showLoading = false;
      isButtonPressed2 = false;
    });
  }

  bool isGpsEnabled = false;
  bool isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isOrderConfirmedback ? false : true,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(('Add Shop Details'),
              style:  TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Date: $currentDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTextField(
                          'Shop Name', shopNameController, shopNameFocusNode,
                          'Enter Shop Name', Icons.store),
                      // const SizedBox(height: 0),
                      _buildCityField(),
                      // const SizedBox(height: 2),
                      _buildTextField('Shop Address', shopAddressController,
                          shopAddressFocusNode, 'Enter Shop Address',
                          Icons.location_on),
                      // const SizedBox(height: 1),
                      _buildTextField(
                          'Owner Name', ownerNameController, ownerNameFocusNode,
                          'Enter Owner Name', Icons.person),
                      // const SizedBox(height: 10),
                      _buildCnicField(),
                      // const SizedBox(height: 10),
                      _buildPhoneNumberField(
                          phoneNoController, phoneNoFocusNode, 'Phone Number'),
                      // const SizedBox(height: 10),
                      _buildPhoneNumberField(alternativePhoneNoController,
                          alternativePhoneNoFocusNode,
                          'Alternative Phone Number'),
                      // const SizedBox(height: 5),
                      _buildGpsStatusWidget(),
                      const SizedBox(height: 1),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      FocusNode focusNode, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          // Set the label color to black
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCnicField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ownerCNICController,
        focusNode: ownerCNICFocusNode,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(r'^\d{0,5}-?\d{0,7}-?\d{0,1}')),
          // Restrict input to match CNIC pattern
          LengthLimitingTextInputFormatter(15),
          // Limit to 15 characters (13 digits + 2 hyphens)
          TextInputFormatter.withFunction((oldValue, newValue) {
            String text = newValue.text;

            // Adding hyphen after the first 5 digits
            if (text.length > 5 && text[5] != '-') {
              text = '${text.substring(0, 5)}-${text.substring(5)}';
            }

            // Adding hyphen after the next 7 digits (i.e., 13th character)
            if (text.length > 13 && text[13] != '-') {
              text = '${text.substring(0, 13)}-${text.substring(13)}';
            }

            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }),
        ],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Owner CNIC',
          labelStyle: const TextStyle(color: Colors.black54),
          hintText: '00000-_______-_',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.credit_card, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter CNIC';
          }
          if (value.length != 15) {
            return 'CNIC must be 13 digits in the format 34603-2290070-7';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneNumberField(TextEditingController controller,
      FocusNode focusNode, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11), // Limit to 11 characters
        ],
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          hintText: '03_________',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.phone, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $label';
          } else if (value.length != 11) {
            return '$label must be 11 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCityField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: userDesignation != 'SM' && userDesignation != 'NSM' &&
          userDesignation != 'RSM' && userDesignation != 'ASM' &&
          userDesignation != 'SPO' && userDesignation != 'SOS'
          ? TextFormField(
        controller: cityController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'City',
          labelStyle: const TextStyle(color: Colors.black54),
          hintText: 'Enter City',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.location_city, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      )
          : TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: cityController,
          decoration: InputDecoration(
            labelText: 'City',
            labelStyle: const TextStyle(color: Colors.black54),
            hintText: 'Enter City',
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.location_city, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please select a valid city';
          }
          return null;
        },
        suggestionsCallback: (pattern) {
          return citiesDropdownItems.where((city) =>
              city.toLowerCase().contains(pattern.toLowerCase())).toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          cityController.text = suggestion;
        },
      ),
    );
  }

  Widget _buildGpsStatusWidget() {
    return Row(
      children: [
        Switch(
          value: isGpsEnabled,
          onChanged: isSwitchDisabled
              ? null // Disable interaction when switch is disabled
              : (bool value) async {
            if (value) {
              await saveCurrentLocation(context);
            } else {
              setState(() {
                isGpsEnabled = false;
              });
            }
          },
          activeColor: Colors.black,
        ),
        const Text(
          'GPS Enabled',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: isButtonPressed2 || showLoading
            ? null
            : () async {
          setState(() {
            isButtonPressed2 = true;
          });
          await _validateAndSave();
          setState(() {
            isButtonPressed2 = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: showLoading
            ? SizedBox(
          width: 24.0,
          height: 24.0,
          child: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white, size: 24.0),
          ),
        )
            : const Text('Save'),
      ),
    );
  }


}