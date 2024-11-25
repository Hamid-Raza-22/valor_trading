import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/async.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../API/Globals.dart';
import '../../Models/HeadsShopVistModels.dart';
import '../../Models/ShopVisitModels.dart';
import '../../View_Models/LoginViewModel.dart';
import '../../View_Models/OwnerViewModel.dart';
import '../../View_Models/ShopVisitViewModel.dart';

import 'RSM_HomePage.dart';

class ShopVisitPage extends StatefulWidget {
  const ShopVisitPage({
    Key? key,
  }) : super(key: key);

  @override
  ShopVisitPageState createState() => ShopVisitPageState();
}

class ShopVisitPageState extends State<ShopVisitPage> {
  TextEditingController regionController = TextEditingController();
  TextEditingController bookerController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  bool isGpsEnabled = false;
  bool isLoadingLocation = false; // Loading state variable

  dynamic globalLatitude = '';
  dynamic globalLongitude = '';
  bool isLocationFetched = false;
  bool isLocationChecked = false; // Checkbox state
  final ownerViewModel = Get.put(OwnerViewModel());
  final loginViewModel = Get.put(LoginViewModel());
  final shopVisitViewModel = Get.put(ShopVisitViewModel());
  List<String> dropdownItems = [];
  List<String> bookersDropdownItems = [];
  List<String> citiesDropdownItems = [];
  final TextEditingController rsmNameController = TextEditingController(text: userNames);
  final String currentDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _checkUserIdAndFetchShopNames();
    fetchBookerNamesByRSMDesignation();
    fetchCitiesNames();
  }

  Future<void> fetchCitiesNames() async {
    List<dynamic> businessNames = await dbHelper.getCitiesNames();
    setState(() {
      citiesDropdownItems = businessNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }

  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDesignation = prefs.getString('userDesignation');

    var boxName = (userDesignation == 'RSM') ? 'shopNames' : 'shopNamesByCities';
    var box = await Hive.openBox(boxName);

    cachedShopNames = box.get(boxName) as List<String>?;
    await box.close();

    if (cachedShopNames != null && cachedShopNames!.isNotEmpty) {
      setState(() {
        dropdownItems = cachedShopNames!.map((dynamic item) => item.toString()).toSet().toList();
      });
    } else {
      if (userDesignation == 'RSM') {
        await fetchShopNamesAll();
      }
    }
  }

  bool isSwitchDisabled = false; // Add this state variable

  Future<void> saveCurrentLocation(BuildContext context) async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      isLoadingLocation = true; // Start loading
      isSwitchDisabled = true;  // Disable the switch while loading
    });

    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
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
        MaterialPageRoute(builder: (context) => const RSMHomepage()),
      );
    }

    if (!mounted) return; // Check again before calling setState()
    setState(() {
      isLoadingLocation = false; // Stop loading
      isSwitchDisabled = false;  // Re-enable the switch after loading
    });
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
          activeColor: Colors.green,
        ),
        const Text(
          'GPS Enabled',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }


  Future<void> fetchShopNamesAll() async {
    ownerViewModel.fetchShopNames();
    List<String> shopNames = ownerViewModel.shopNames.map((dynamic item) => item.toString()).toSet().toList();

    var box = await Hive.openBox('shopNames');
    await box.put('shopNames', shopNames);
    List<String> allShopNames = box.get('shopNames', defaultValue: <String>[]);
    if (kDebugMode) {
      print('All shop names: $allShopNames');
    }
    await box.close();

    setState(() {
      dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }
  Future<void> fetchBookerNamesByRSMDesignation() async {
    loginViewModel.fetchBookerNamesByRSMDesignation();
    List<String> bookerNames = loginViewModel.bookerNamesByRSMDesignation.map((dynamic item) => item.toString()).toSet().toList();

    var box = await Hive.openBox('bookerNames');
    await box.put('bookerNames', bookerNames);
    List<String> allBookerNames = box.get('bookerNames', defaultValue: <String>[]);
    if (kDebugMode) {
      print('All shop names: $allBookerNames');
    }
    await box.close();

    setState(() {
      bookersDropdownItems = bookerNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }

  bool _isSubmitButtonEnabled() {
    return isLocationFetched &&
        regionController.text.isNotEmpty &&
        bookerController.text.isNotEmpty &&
        shopController.text.isNotEmpty &&
        feedbackController.text.isNotEmpty;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }



  Future<void> onDropdownTapRegion() async {
    await fetchCitiesNames();
  }
  Future<void> onDropdownTapBooker() async {
   await fetchBookerNamesByRSMDesignation();
  }
  Future<void> onDropdownTapShop() async {
    await _checkUserIdAndFetchShopNames();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Visit Form'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedTextField('RSM Name', rsmNameController, Icons.person, readOnly: true),
            const SizedBox(height: 16),
            buildAnimatedDateField(currentDate),
            const SizedBox(height: 16),
            _buildAnimatedDropdown("Select City", citiesDropdownItems, Icons.location_on, regionController,onDropdownTapRegion),
            const SizedBox(height: 16),
            _buildAnimatedDropdown("Select Booker ID", bookersDropdownItems, Icons.book, bookerController, onDropdownTapBooker),
            const SizedBox(height: 16),
            _buildAnimatedDropdown("Select Shop", dropdownItems, Icons.store, shopController,onDropdownTapShop),
            const SizedBox(height: 16),
            _buildAnimatedFeedbackBox(),
            const SizedBox(height: 10),
            _buildGpsStatusWidget(),
            const SizedBox(height: 24),
            _buildAnimatedSubmitButton(context),
          ],
        ),
      ),
    );
  }



  Widget _buildAnimatedTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  buildAnimatedDateField(String currentDate) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: TextEditingController(text: currentDate),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
            labelText: 'Date',
            border: InputBorder.none,
          ),
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown(String label, List<String> items, IconData icon, TextEditingController controller, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.green),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
          items: items,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.green),
              labelText: label,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
          onChanged: (value) {
            controller.text = value ?? '';
            setState(() {}); // Update the state to recheck the button enable status
          },
        ),
      ),
    ),
    );
  }

  Widget _buildAnimatedFeedbackBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback or Note',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your feedback here...',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              onChanged: (value) => setState(() {}), // Recheck button enable status
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  feedbackController.clear();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitButtonEnabled()
            ? () async {
          await _handleLogin();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form Submitted Successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
            : null
        //     () {
        //   _showToast('Please fill all fields and make sure location is enabled.');
        // }
        , // Disable button if not enabled
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          elevation: 8,
        ),
        child: const Text('Submit'),
      ),
    );
  }

  Future<void> _handleLogin() async {
    var id = await customAlphabet('1234567890', 10);
    await shopVisitViewModel.addHeadsShopVisit(HeadsShopVisitModel(
      id: int.parse(id),
      shopName: shopController.text,
      userId: userId,
      bookerName: rsmNameController.text,
      bookerId: bookerController.text,
      city: regionController.text,
      date: currentDate,
      feedback: feedbackController.text,
      address: shopAddress,
    ));
    await shopVisitViewModel.postHeadsShopVisit();
  }
}
