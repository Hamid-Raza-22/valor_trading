import 'dart:convert' show base64Decode;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/animation.dart' show AlwaysStoppedAnimation, Color;
import 'package:flutter/foundation.dart' show Key, Uint8List, kDebugMode;
import 'package:flutter/material.dart' show Align, Alignment, AppBar, Axis, BorderRadius, BorderSide, BoxDecoration, BoxFit, BuildContext, Card, Center, Checkbox, CircularProgressIndicator, Colors, Column, Container, CrossAxisAlignment, DataCell, DataColumn, DataRow, DataTable, EdgeInsets, ElevatedButton, Expanded, FocusNode, FocusScope, Form, FormState, GestureDetector, GlobalKey, Icon, Icons, Image, InputBorder, InputDecoration, Key, ListTile, MainAxisAlignment, MaterialPageRoute, MediaQuery, Navigator, OutlineInputBorder, Padding, RepaintBoundary, RoundedRectangleBorder, RouteSettings, Row, Scaffold, ScaffoldMessenger, SingleChildScrollView, SizedBox, SnackBar, Stack, State, StatefulWidget, Text, TextEditingController, TextField, TextFormField, TextInputType, TextStyle, ValueListenableBuilder, ValueNotifier, Widget, imageCache;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, Position;
// import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/async.dart';
import '../API/Globals.dart';
import '../View_Models/StockCheckItems.dart';
import '../Views/HomePage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/DatabaseOutputs.dart';
import '../Databases/DBHelper.dart';
import '../Models/ShopVisitModels.dart';
import '../Models/StockCheckItems.dart';
import '../View_Models/OrderViewModels/ProductsViewModel.dart';
import '../View_Models/OwnerViewModel.dart';
import '../View_Models/ShopVisitViewModel.dart';
import '../main.dart';
import 'FinalOrderBookingPage.dart';



class ShopImageController extends GetxController {
  // Observable to store the shop image file
  final Rx<File?> _shopimageFile = Rx<File?>(null);

  // Getter to retrieve the current shop image file
  File? get shopImageFile => _shopimageFile.value;

  // Method to update the shop image file
  void updateShopImageFile(File? file) {
    _shopimageFile.value = file;
  }

  // Method to load an image file from a base64 string
  Future<void> loadImageFile(String base64Image) async {
    // Decode the base64 string into bytes
    Uint8List bytesImage = base64Decode(base64Image);

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.jpg').writeAsBytes(bytesImage);

    // Update the _shopimageFile value using the controller
    updateShopImageFile(file); // Directly call the method

    update(); // Notify listeners to update the UI

    if (kDebugMode) {
      print('Shop Image File: ${_shopimageFile.value}');
      print('Shop Image File: $_shopimageFile');
    }
  }

  // Method to clear the shop image file
  void clearShopImageFile() {
    _shopimageFile.value = null;
  }
}

class ShopVisit extends StatefulWidget {
  // Constructor for ShopVisit widget
  const ShopVisit({
    Key? key,
  }) : super(key: key);

  @override
  ShopVisitState createState() => ShopVisitState();
}

class ShopVisitState extends State<ShopVisit> {
  final shopImageFileProvider = StateProvider<File?>((ref) => null);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Text controllers for the form fields
  TextEditingController ShopNameController = TextEditingController();
  final TextEditingController _brandDropDownController = TextEditingController();
  TextEditingController BookerNameController = TextEditingController();
  TextEditingController BrandNameController = TextEditingController();
  TextEditingController ShopAddressController = TextEditingController();
  TextEditingController ShopOwnerController = TextEditingController();
  final ownerViewModel = Get.put(OwnerViewModel());

  final ShopImageController _shopImageController = Get.put(ShopImageController());
  final Rx<File?> shopimageFile = Rx<File?>(null); // Use Rx to manage File state
  final TextEditingController _searchController = TextEditingController();
  List<DataRow> filteredRows = [];

  final stockcheckitemsViewModel = Get.put(StockCheckItemsViewModel());
  final productsitemsViewModel = Get.put(ProductsViewModel());

  int? shopVisitId;
  int? stockcheckitemsId;
  String selectedShopOwner = '';
  String? selectedShopAddress = '';
  String? selectedOwnerContact= '';
  String selectedShopOrderNo = '';

  List<Map<String, dynamic>> shopOwners = [];
  final Products productsController = Get.put(Products());
  DBHelper dbHelper = DBHelper();
  List<String> dropdownItems5 = [];
  List<String> dropdownItems = [];
  List<String> brandDropdownItems = [];
  String selectedItem ='';
  String? selectedDropdownValue;
  String selectedBrand = '';
  List<String> selectedProductNames = [];
  // Add an instance of ProductsViewModel
  ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
   int ShopVisitsSerialCounter = highestSerial ?? 0;
  late ValueNotifier<String> shopNameNotifier;

  double currentBalance = 0.0;
  String currentUserId = '';
  String shopVisitCurruntMonth = DateFormat('MMM').format(DateTime.now());
  get shopData => null;
  int serialNo = 1;
  final shopVisitViewModel = Get.put(ShopVisitViewModel());
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;
  final TextEditingController feedbackController = TextEditingController();
  final FocusNode feedbackFocusNode = FocusNode();
  bool isButtonPressed3 = false;
  dynamic latitude = '';
  dynamic longitude ='';
  bool isButtonPressed = false;
  bool isButtonPressed2 = false;
  bool showLoading = false;
  List<DataRow> rows = [];
  final FocusNode _shopNameFocusNode = FocusNode();

  // Function to filter data based on query
  void filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredRows = [];
      });
    } else {
      List<DataRow> tempList = [];
      String lowerCaseQuery = query.toLowerCase();
      for (DataRow row in productsController.rows) {
        for (DataCell cell in row.cells) {
          if (cell.child is Text && (cell.child as Text).data!.toLowerCase().contains(lowerCaseQuery)) {
            tempList.add(row);
            break;
          }
        }
      }
      setState(() {
        filteredRows = tempList;
      });
    }
  }

  // Function to navigate to the new order booking page with the selected brand name
  void navigateToNewOrderBookingPage(String selectedBrandName) async {
    // Set the selected shop name without navigation
    setState(() {
      selectedItem = selectedBrandName;
    });
  }


  @override
  void initState() {
    super.initState();

    // Check user ID and fetch shop names
    _checkUserIdAndFetchShopNames();
    // Retrieve initial data
    data();

    // Clear the brand name controller
    BrandNameController.clear();

    // Initialize shop name notifier with selected item
    shopNameNotifier = ValueNotifier<String>(selectedItem);
    productsController.rows;

    // Fetch brand items from the database
    _fetchBrandItemsFromDatabase();
    // Initialize other setup
    onCreatee();
    _loadCounter();

    // Save current location
    saveCurrentLocation();

    // Add listener to shop name notifier to update the shop image
    shopNameNotifier.addListener(() {
      updateShopImage();
      if (kDebugMode) {
        print('shopNameNotifier value changed to: ${shopNameNotifier.value}');
      }
    });

    // Add another listener to handle product changes
    shopNameNotifier.addListener(() {
      _onProductChange();
      if (kDebugMode) {
        print('State changed ');
      }
    });

    // Add listener to focus node to clear shop name when focused
    _shopNameFocusNode.addListener(() {
      if (_shopNameFocusNode.hasFocus) {
        _shopImageController.clearShopImageFile();
        ShopNameController.clear();
      }
    });

    if (kDebugMode) {
      print(userId);
      print(highestSerial);
    }
  }

// Function to retrieve initial data from the database
  void data() {
    DBHelper dbHelper = DBHelper();
    if (kDebugMode) {
      print('data0');
    }
    dbHelper.getHighestSerialNo();
  }

// Function to remove saved values from SharedPreferences
  Future<void> removeSavedValues(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('itemDesc$index');
    await prefs.remove('qty$index');

    if (kDebugMode) {
      print('Removed itemDesc$index and qty$index from SharedPreferences');
    }
  }

// Function to check user ID and fetch shop names
  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDesignation = prefs.getString('userDesignation');

    var boxName = (userDesignation == 'RSM' || userDesignation == 'NSM' || userDesignation == 'SM' || userDesignation == 'ASM' || userDesignation == 'SPO' || userDesignation == 'SOS')
        ? 'shopNames'
        : 'shopNamesByCities';
    var box = await Hive.openBox(boxName);

    cachedShopNames = box.get(boxName) as List<String>?;
    await box.close();

    if (cachedShopNames != null && cachedShopNames!.isNotEmpty) {
      setState(() {
        dropdownItems = cachedShopNames!.map((dynamic item) => item.toString()).toSet().toList();
      });
    } else {
      if (userDesignation == 'RSM' || userDesignation == 'NSM' || userDesignation == 'SM' || userDesignation == 'ASM' || userDesignation == 'SPO' || userDesignation == 'SOS') {
        await fetchShopNamesAll();
      } else {
        await fetchShopNames();
      }
    }
  }

// Function to fetch shop names by cities from the database
  Future<void> fetchShopNames() async {
    ownerViewModel.fetchShopNamesbycities();
    List<String> shopNames = ownerViewModel.shopNamesbycites.map((dynamic item) => item.toString()).toSet().toList();

    var box = await Hive.openBox('shopNamesByCities');
    await box.put('shopNamesByCities', shopNames);
    List<String> shopNamesByCities = box.get('shopNamesByCities', defaultValue: <String>[]);
    if (kDebugMode) {
      print('Shop names by cities: $shopNamesByCities');
    }
    await box.close();

    setState(() {
      dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }

// Function to fetch all shop names from the database
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


// Function to save the current location
  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        // Get the current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude  = position.latitude;
        longitude = position.longitude;

        if (kDebugMode) {
          print('Latitude: $latitude, Longitude: $longitude');
        }

        // Using geocoding to convert latitude and longitude to an address
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        Placemark currentPlace = placemarks[0];

        // Construct the address from the placemark
        String address1 = "${currentPlace.thoroughfare} ${currentPlace.subLocality}, ${currentPlace.locality}${currentPlace.postalCode}, ${currentPlace.country}";
        shopAddress = address1;

        if (kDebugMode) {
          print('Address is: $address1');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Location permission is not granted');
      }
    }
  }

// Function to load the serial counter and other state variables from SharedPreferences
  void _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    if (shopVisitCurruntMonth != currentMonth) {
      // Reset serial counter when the month changes
      ShopVisitsSerialCounter = 1;
      shopVisitCurruntMonth = currentMonth;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ShopVisitsSerialCounter = (prefs.getInt('serialCounter') ?? highestSerial ?? 1);
      shopVisitCurruntMonth = prefs.getString('currentMonth') ?? shopVisitCurruntMonth;
      currentUserId = prefs.getString('currentUserId') ?? ''; // Add this line
    });

    if (kDebugMode) {
      print('SR: $ShopVisitsSerialCounter');
    }
  }

// Function to save the serial counter and other state variables to SharedPreferences
  void _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serialCounter', ShopVisitsSerialCounter);
    await prefs.setString('currentMonth', shopVisitCurruntMonth);
    await prefs.setString('currentUserId', currentUserId); // Add this line
  }

// Function to generate a new order ID
  String generateNewOrderId(String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentUserId != userId) {
      // Reset serial counter when the userId changes
      ShopVisitsSerialCounter = highestSerial ?? 1;
      currentUserId = userId;
    }

    if (shopVisitCurruntMonth != currentMonth) {
      // Reset serial counter when the month changes
      ShopVisitsSerialCounter = 1;
      shopVisitCurruntMonth = currentMonth;
    }

    // Generate the new order ID
    String orderId = "$userId-$currentMonth-${ShopVisitsSerialCounter.toString().padLeft(3, '0')}";
    ShopVisitsSerialCounter++;
    _saveCounter(); // Save the updated counter value, current month, and userId
    return orderId;
  }

// Function to perform database operations on create
  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showShopVisit();
    await db.showStockCheckItems();
  }

// Method to fetch brand items from the database
  void _fetchBrandItemsFromDatabase() async {
    DBHelper dbHelper = DBHelper();
    List<String> brandItems = await dbHelper.getBrandItems();

    // Remove duplicates from the shopNames list
    List<String> uniqueBrandNames = brandItems.toSet().toList();

    // Set the retrieved brand items in the state
    setState(() {
      brandDropdownItems = uniqueBrandNames;
    });
  }

// Function to save an image
  Future<void> saveImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/captured_image.jpg';

      // Compress the image
      Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
        _imageFile!.path,
        minWidth: 400,
        minHeight: 600,
        quality: 40,
      );

      if (compressedImageBytes != null) {
        // Save the compressed image
        await File(filePath).writeAsBytes(compressedImageBytes);
        if (kDebugMode) {
          print('Compressed image saved successfully at $filePath');
        }
      } else {
        if (kDebugMode) {
          print('Image compression failed.');
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image compression failed.'),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing and saving image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error compressing and saving image: $e'),
      ));
    }
  }



// Widget to build the stack for displaying the shop image
  Widget buildShopImageStack() {
    return ValueListenableBuilder<String>(
      valueListenable: shopNameNotifier,
      builder: (context, shopName, child) {
        return Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            if (_shopImageController.shopImageFile != null)
              Center(
                child: Image.file(
                  _shopImageController.shopImageFile!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (_shopImageController.shopImageFile == null)
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey,
                  child: const Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ));
      },
    );
  }

// Function to update the shop image based on the selected shop name
  Future<void> updateShopImage() async {
    // Fetch shop owners from the database
    shopOwners = (await dbHelper.getOwnersDB())!;

    for (var owner in shopOwners) {
      if (owner['shop_name'] == shopNameNotifier.value) {
        selectedShopOwner = owner['owner_name'];
        selectedOwnerContact = owner['phone_no'];
        selectedShopCity = owner['city'];
        selectedShopAddress = owner['shop_address'];
        ShopAddressController.text = selectedShopAddress ?? 'No Address';
        ShopOwnerController.text = selectedShopOwner ?? 'No Owner Name';
        String base64Image = owner['images'];

        // Load the shop image file from base64
        await _shopImageController.loadImageFile(base64Image);
        if (kDebugMode) {
          print("selectedShopCity: $selectedShopCity");
        }

        // Update the products based on the selected shop
        await _onProductChange();
        // Rebuild the shop image stack
        buildShopImageStack();
      }
    }
  }

// Function to handle product changes
  Future<void> _onProductChange() async {
    setState(() {}); // Update UI when products change
  }

  @override
  void dispose() {
    // Clear the shop image file
    _shopImageController.clearShopImageFile();
    // Clear and dispose the brand name controller
    BrandNameController.clear();
    BrandNameController.dispose();
    // Clear and dispose the shop name controller
    ShopNameController.dispose();
    // Dispose the FocusNode
    _shopNameFocusNode.dispose();
    // Dispose feedback controllers and focus nodes
    feedbackController.dispose();
    feedbackFocusNode.dispose();
    // Clear the brand drop-down controller
    _brandDropDownController.text = "";
    super.dispose();
  }

  @override

    Widget build(BuildContext context) {

      ShopNameController.text= selectedItem;
      BookerNameController.text= userNames;
       BrandNameController.text= selectedBrand;

      return ProviderScope(

          child: Scaffold(
            appBar: AppBar(
              title: const Text('Shop Visit'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        ' Date: ${_getFormattedDate()}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Brand',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(

                            height: 30,
                            child: DropdownSearch<String>(

                              items: brandDropdownItems,
                              selectedItem: selectedBrand,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  hintText: '-------Select Brand------',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                                ),
                              ),
                              popupProps: PopupProps.dialog(
                                showSearchBox: true,
                              ),
                              onChanged: (String? newValue) async {
                                if (newValue != null && brandDropdownItems.contains(newValue)) {
                                  setState(() {
                                    selectedBrand = newValue;
                                    _brandDropDownController.text = selectedBrand;
                                    globalselectedbrand =_brandDropDownController.text;
                                  });

                                  print('userBrand $globalselectedbrand');
                                  await productsitemsViewModel.fetchAllProductsModel();
                                 await productsController.fetchProducts();
                                  for (int i = 0; i < productsController.rows.length; i++) {
                                    removeSavedValues(i);
                                  }
                                  productsController.controllers.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 10),
              const Text(
                'Shop Name',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              GestureDetector(
                onTap: () async {
                  // await _checkUserIdAndFetchShopNames();
                //  _shopImageController.clearShopImageFile();
                  ShopNameController.clear();
                },
                child: SizedBox(
                  height: 30,
                  child: DropdownSearch<String>(
                    items: dropdownItems,
                    selectedItem: selectedItem,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: '-------Select Shop------',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                    ),
                    onChanged: (String? newValue) async {
                      if (newValue != null && dropdownItems.contains(newValue)) {
                        setState(() {
                          imageCache.clear();
                          selectedItem = newValue;
                          shopNameNotifier.value = selectedItem; // Update the shop name
                        });
                        updateShopImage();
                        productsController.rows;
                        productsController.fetchProducts();
                        for (int i = 0; i < productsController.rows.length; i++) {
                          removeSavedValues(i);
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),


              const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Shop Address',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: TextFormField(enabled: false, readOnly: true,
                        controller: ShopAddressController,

                        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Shop Owner',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: TextFormField(enabled: false, readOnly: true,
                        controller: ShopOwnerController,

                        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // // Add the Stack widget to overlay the warning icon on top of the image
                    // const Text(
                    //   'Shop Image',
                    //   style: TextStyle(fontSize: 16, color: Colors.black),
                    // ),
                    // const SizedBox(height: 10),
                    // buildShopImageStack(),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Booker Name',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: TextFormField(enabled: false,
                        controller: BookerNameController,

                        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),






              // const Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text(
                    //     'Brand',
                    //     style: TextStyle(fontSize: 16, color: Colors.black),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 30,
                    //   child: TextFormField(enabled: false, readOnly: true,
                    //     controller: BrandNameController,
                    //
                    //     decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(5.0),
                    //       ),
                    //     ),
                    //
                    //     validator: (value) {
                    //       if (value!.isEmpty) {
                    //         return 'Please enter some text';
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ),
                    // const Align(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     'Checklist',
                    //     style: TextStyle(fontSize: 16, color: Colors.black),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '1-Stock Check',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [

                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  height: 400, // Set the desired height
                                  width: MediaQuery.of(context).size.width * 0.9, // Set the desired width
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      side: const BorderSide(
                                        color: Colors.black, // Change the color as needed
                                        width: 1.0, // Change the width as needed
                                      ),
                                    ),
                                    child: SingleChildScrollView( // Add a vertical ScrollView
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextField(
                                              controller: _searchController,
                                              onChanged: (query) {
                                                filterData(query);
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Search',
                                                hintText: 'Type to search...',
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                            ),
                                          ),
                                          // Wrap the DataTable with Obx
                                    RepaintBoundary(
                                      child: ValueListenableBuilder<List<DataRow>>(
                                        valueListenable: productsController.rowsNotifier,
                                        builder: (context, rows, child) {
                                          return DataTable(
                                            columns: const [
                                              DataColumn(label: Text('Product')),
                                              DataColumn(label: Text('Quantity')),
                                            ],
                                            rows: filteredRows.isNotEmpty ? filteredRows : rows,
                                          );
                                        },
                                      ),
                                    )
                                    ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )


                      ],
                    ),

                    const SizedBox(height: 20),

                    Column(
                      children: [
                        buildRow('1-Performed Store Walkthrough', checkboxValue1, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue1 = value;
                              FocusScope.of(context).unfocus();
                              //checkbox= checkboxValue1;
                            });
                          }
                        }),
                        buildRow('2-Update Store Planogram', checkboxValue2, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue2 = value;
                              FocusScope.of(context).unfocus();
                              // checkbox2= checkboxValue2;
                            });
                          }
                        }),
                        buildRow('3-Shelf tags and price signage check', checkboxValue3, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue3 = value;
                              FocusScope.of(context).unfocus();
                              //    checkbox3= checkboxValue3;
                            });
                          }
                        }),
                        buildRow('4-Expiry date on product reviewed', checkboxValue4, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue4 = value;
                              FocusScope.of(context).unfocus();
                              // checkbox4= checkboxValue4;
                            });
                          }
                        }),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final image = await _imagePicker.getImage(
                                source: ImageSource.camera,
                                imageQuality: 40, // Adjust the quality (0 to 100)
                              );

                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);

                                  shopData?['imagePath'] = _imageFile!.path;

                                  // // Convert the image file to bytes and store it in _imageBytes
                                  // List<int> imageBytesList = _imageFile!.readAsBytesSync();
                                  // _imageBytes = Uint8List.fromList(imageBytesList);
                                });

                                // Save only the image
                                await saveImage();

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('No image selected.'),
                                ));
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print('Error capturing image: $e');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF212529),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text('+ Add Photo'),
                        ),
                        const SizedBox(height: 10),
                        // Add the Stack widget to overlay the warning icon on top of the image
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_imageFile != null)
                              Image.file(
                                _imageFile!,
                                height: 300,
                                width: 400,
                                fit: BoxFit.cover,
                              ),
                            if (_imageFile == null)
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 48,
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Feedback/ Special Note'),
                        const SizedBox(height: 20.0),
                         // Feedback or Note Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: feedbackController,
                            focusNode: feedbackFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Feedback or Note',
                              border: InputBorder.none,
                              hintStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 3,
                            onChanged: (text) {
                              setState(() {
                                // Just updating the state when text changes
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: isButtonPressed
                              ? null
                              : () async {
                            // Close the mobile keyboard
                            FocusScope.of(context).unfocus();

                            // Introduce a short delay to ensure the keyboard is closed
                            await Future.delayed(const Duration(milliseconds: 100));

                            setState(() {
                              isButtonPressed = false;
                            });
                            print("Brand:${_brandDropDownController.text}");
                            print("ShopName:${ShopNameController.text}");
                            print("Brand:${ShopAddressController.text}");
                            print("Brand:${ShopOwnerController.text}");
                            print("Brand:${BookerNameController.text}");
                            print("Brand:${_imageFile!.path}");
                            print('Number of rows: ${productsController.rows.length}');
                           // print('Row $i cells count: ${row.cells.length}');



                            if (!checkboxValue1 ||
                                !checkboxValue2 ||
                                !checkboxValue3 ||
                                !checkboxValue4) {
                              Fluttertoast.showToast(
                                msg: 'Please complete all tasks before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );

                              setState(() {
                                checkboxValue1 = false;
                                checkboxValue2 = false;
                                checkboxValue3 = false;
                                checkboxValue4 = false;
                                isButtonPressed = false;
                              });
                              return;
                            }

                            if (_imageFile == null || ShopNameController.text.isEmpty|| selectedBrand == null || selectedItem == null ||BrandNameController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please fulfill all requirements before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed = false;
                              });
                              return;
                            }

                            String imagePath = _imageFile!.path;
                            var id = await customAlphabet('1234567890', 10);
                            List<int> imageBytesList = await File(imagePath).readAsBytes();
                            Uint8List? imageBytes = Uint8List.fromList(imageBytesList);
                            String NewOrderId = generateNewOrderId(userId.toString());
                            OrderMasterid = NewOrderId;
                            if (kDebugMode) {
                              print(OrderMasterid);
                            }

                            shopVisitViewModel.addShopVisit(ShopVisitModel(
                              id: int.parse(id),
                              shopName: ShopNameController.text,
                              userId: userId,
                              bookerName: BookerNameController.text,
                              brand: BrandNameController.text,
                              city: selectedShopCity,
                              date: _getFormattedDate(),
                              feedback: feedbackController.text,
                              walkthrough: checkboxValue1,
                              planogram: checkboxValue2,
                              signage: checkboxValue3,
                              productReviewed: checkboxValue4,
                              address: shopAddress,
                              body: imageBytes,
                              longitude: longitude,
                              latitude: latitude,
                            ));

                            String visitId = await shopVisitViewModel.fetchLastShopVisitId();
                            shopVisitId = int.parse(visitId);

                            List<StockCheckItemsModel> stockCheckItemsList = [];
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            for (int i = 0; i < productsController.rows.length; i++) {
                              DataRow row = productsController.rows[i];

                              if (row.cells.isEmpty || productsController.controllers.length <= i) {
                                print('Skipping row $i due to empty cells or mismatched controller.');
                                continue;
                              }

                              String itemDesc = row.cells[0].child.toString();
                              String qty = productsController.controllers[i].text;

                              if (qty.isNotEmpty && int.parse(qty) != 0) {
                                stockCheckItemsList.add(
                                  StockCheckItemsModel(
                                    shopvisitId: shopVisitId,
                                    itemDesc: itemDesc,
                                    qty: qty,
                                  ),
                                );

                                await prefs.setString('itemDesc$i', itemDesc);
                                await prefs.setString('qty$i', qty);

                                if (kDebugMode) {
                                  print('itemDesc$i: $itemDesc');
                                  print('qty$i: $qty');
                                }
                              }
                            }

                            for (var stockCheckItems in stockCheckItemsList) {
                              await stockcheckitemsViewModel.addStockCheckItems(stockCheckItems);
                            }

                            bool isConnected = await isInternetAvailable();

                            if (isConnected == true) {
                              await shopVisitViewModel.postShopVisit();
                              await stockcheckitemsViewModel.postStockCheckItems();
                            }

                            Map<String, String> dataToPass = {
                              'shopName': ShopNameController.text,
                              'ownerName': selectedShopOwner.toString(),
                              'userName': BookerNameController.text,
                              'ownerContact': selectedOwnerContact.toString(),
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FinalOrderBookingPage(),
                                settings: RouteSettings(arguments: dataToPass),
                              ),
                            );

                            setState(() {
                              isButtonPressed = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF212529),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text('+ Order Booking Form'),
                        ),


                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: isButtonPressed2 || showLoading
                              ? null
                              : () async {
                            // Close the mobile keyboard
                            FocusScope.of(context).unfocus();

                            // Introduce a short delay to ensure the keyboard is closed
                            await Future.delayed(const Duration(milliseconds: 100));

                            setState(() {
                              isButtonPressed2 = true;
                            });
                            if (feedbackController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please provide feedback before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed2 = false;
                              });
                              feedbackFocusNode.requestFocus();
                              return;
                            }

                            if (!checkboxValue1 ||
                                !checkboxValue2 ||
                                !checkboxValue3 ||
                                !checkboxValue4) {
                              Fluttertoast.showToast(
                                msg: 'Please complete all tasks before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );

                              setState(() {
                                checkboxValue1 = false;
                                checkboxValue2 = false;
                                checkboxValue3 = false;
                                checkboxValue4 = false;
                              });

                              setState(() {
                                isButtonPressed2 = false;
                              });
                              return;
                            }

                            if (_imageFile == null || ShopNameController.text.isEmpty|| BrandNameController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please fulfill all requirements before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed2 = false;
                              });
                              return;
                            }

                            // Show loading indicator
                            setState(() {
                              showLoading = true;
                            });

                            String imagePath = _imageFile!.path;
                            var id = await customAlphabet('1234567890', 12);
                            List<int> imageBytesList = await File(imagePath).readAsBytes();
                            Uint8List? imageBytes = Uint8List.fromList(imageBytesList);

                            shopVisitViewModel.addShopVisit(ShopVisitModel(
                              id: int.parse(id),
                              shopName: ShopNameController.text,
                              userId: userId,
                              bookerName: BookerNameController.text,
                              brand: BrandNameController.text,
                              city: selectedShopCity,
                              date: _getFormattedDate(),
                              feedback: feedbackController.text,
                              walkthrough: checkboxValue1,
                              planogram: checkboxValue2,
                              signage: checkboxValue3,
                              productReviewed: checkboxValue4,
                              address: shopAddress,
                              body: imageBytes,
                              latitude: latitude,
                              longitude: longitude,
                            ));

                            String visitId = await shopVisitViewModel.fetchLastShopVisitId();
                            shopVisitId = int.parse(visitId);

                            List<StockCheckItemsModel> stockCheckItemsList = [];
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            for (int i = 0; i < productsController.rows.length; i++) {
                              DataRow row = productsController.rows[i];

                              if (row.cells.isEmpty || productsController.controllers.length <= i) {
                                if (kDebugMode) {
                                  print('Skipping row $i due to empty cells or mismatched controller.');
                                }
                                continue;
                              }

                              String itemDesc = row.cells[0].child.toString();
                              String qty = productsController.controllers[i].text;

                              if (qty.isNotEmpty && int.parse(qty) != 0) {
                                stockCheckItemsList.add(
                                  StockCheckItemsModel(
                                    shopvisitId: shopVisitId,
                                    itemDesc: itemDesc,
                                    qty: qty,
                                  ),
                                );

                                await prefs.setString('itemDesc$i', itemDesc);
                                await prefs.setString('qty$i', qty);

                                if (kDebugMode) {
                                  print('itemDesc$i: $itemDesc');
                                  print('qty$i: $qty');
                                }
                              }
                            }


                            // Call the method to add stock check items to the database
                            for (var stockCheckItems in stockCheckItemsList) {
                              await stockcheckitemsViewModel.addStockCheckItems(stockCheckItems);
                            }

                            bool isConnected = await isInternetAvailable();

                            if (isConnected == true) {
                              await shopVisitViewModel.postShopVisit();
                              await stockcheckitemsViewModel.postStockCheckItems();
                            }

                            // Introduce a 5-second delay
                            await Future.delayed(const Duration(seconds: 5));

                            // Additional validation that everything must be filled
                            if (ShopNameController.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Please fill all fields before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }

                            // Hide loading indicator
                            setState(() {
                              showLoading = false;
                              isButtonPressed2 = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: showLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                          )
                              : const Text('No Order'),
                        ),


                        const SizedBox(height: 50),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
          )
    );
  }


  Widget buildRow(String text, bool value, void Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              checkColor: Colors.white,
              activeColor: Color(0xFF212529),
            ),
            if (!value)
              const Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
          ],
        ),
      ],
    );
  }



  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

  void onBrandSelected(String selectedBrand) {
    setState(() {
      _brandDropDownController.text = selectedBrand;
    });
  }
  //
  // Future<void> fetchProductsNamesByBrand() async {
  //   String selectedBrand = globalselectedbrand;
  //   DBHelper dbHelper = DBHelper();
  //   List<dynamic> productNames = await dbHelper.getProductsNamesByBrand(selectedBrand);
  //
  //   setState(() {
  //     // Explicitly cast each element to String
  //     dropdownItems5 = productNames.map((dynamic item) => item.toString()).toSet().toList();
  //   });
  // }
}

class StockCheckItem {
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  String? selectedDropdownValue;
}

class Products extends GetxController {
  final productsViewModel = ProductsViewModel();
  List<DataRow> rows = <DataRow>[].obs;  // Observable list of DataRow
  List<TextEditingController> controllers = [];  // List of controllers for text fields
  ValueNotifier<List<DataRow>> rowsNotifier = ValueNotifier<List<DataRow>>([]);  // Notifier for rows

  // Method to update rowsNotifier with new rows
  void updateRows(List<DataRow> newRows) {
    rowsNotifier.value = newRows;
  }

  // Method to fetch products based on selected brand
  Future<void> fetchProducts() async {
    await productsViewModel.fetchProductsByBrands(globalselectedbrand);
    var products = productsViewModel.allProducts;

    // Clear existing rows and controllers before adding new ones
    rows.clear();
    controllers.clear();

    for (var product in products) {
      var controller = TextEditingController(text: '0'); // Set default value to '0'
      controllers.add(controller);

      FocusNode focusNode = FocusNode();

      // Listener for focus changes
      focusNode.addListener(() {
        if (!focusNode.hasFocus && controller.text.isEmpty) {
          controller.text = '0'; // Restore '0' when losing focus and text is empty
        }
      });

      // Adding a text listener to handle clear on focus
      controller.addListener(() {
        if (focusNode.hasFocus && controller.text == '0') {
          controller.clear();
        }
      });

      rows.add(DataRow(cells: [
        DataCell(Text(product.product_name ?? '')),  // Display product name
        DataCell(TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          onTap: () {
            if (controller.text == '0') {
              controller.clear();
            }
          },
          onChanged: (value) {
            if (value == '0') {
              controller.clear();
            }
          },
        )),
      ]));
    }

    // Update rowsNotifier with the new rows
    updateRows(List<DataRow>.from(rows));
  }
}

