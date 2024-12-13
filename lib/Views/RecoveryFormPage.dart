import 'dart:io' show InternetAddress, SocketException;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../API/Globals.dart';

import '../Models/RecoveryFormModel.dart';
import '../View_Models/RecoveryFormViewModel.dart';
import '../Views/RecoveryForm_2ndPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/DatabaseOutputs.dart';
import '../API/newDatabaseOutPuts.dart';
import '../Databases/DBHelper.dart';
import '../main.dart';

class RecoveryFromPage extends StatefulWidget {
  const RecoveryFromPage({super.key});

  @override
  _RecoveryFromPageState createState() => _RecoveryFromPageState();
}

class _RecoveryFromPageState extends State<RecoveryFromPage> {
  String recoveryFormCurrentMonth = DateFormat('MMM').format(DateTime.now());
  bool isButtonPressed = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final recoveryformViewModel = Get.put(RecoveryFormViewModel());

  // Controllers for text input fields
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _currentBalanceController = TextEditingController();
  final TextEditingController _cashRecoveryController = TextEditingController();
  final TextEditingController _netBalanceController = TextEditingController();

  List<Map<String, dynamic>> accountsData = []; // List for accounts data
  String? selectedShopName;
  String selectedShopBrand = '';
  String selectedShopCityR = '';
  List<String> dropdownItems = []; // List for dropdown items
  List<String> dropdownItems1 = []; // Additional dropdown items
  String? selectedDropdownValue;
  List<Map<String, dynamic>> shopOwners = []; // List for shop owners
  DBHelper dbHelper = DBHelper(); // Database helper

  double recoveryFormCurrentBalance = 0.0;
  String recoveryFormCurrentUserId = '';
  int recoveryFormSerialCounter = RecoveryhighestSerial ?? 0;

  @override
  void initState() {
    super.initState();
    data();
    _loadRecoveryFormCounter();
    _dateController.text = getCurrentDate();
    _cashRecoveryController.text = ''; // Initial value is zero
    _netBalanceController.text = '0'; // Initial value is zero
    onCreatee();
    fetchAccountsData();
    fetchShopData1();
    if (kDebugMode) {
      print(RecoveryhighestSerial);
    }
  }

  // Function to retrieve initial data from the database
  void data() {
    DBHelper dbHelper = DBHelper();
    if (kDebugMode) {
      print('data0');
    }
    dbHelper.getRecoveryHighestSerialNo();
  }

  // Function to validate cash recovery input
  String? validateCashRecovery(String value) {
    if (value.isEmpty) {
      showToast('Please enter some text');
      return 'Please enter some text';
    } else if (!RegExp(r'^[0-9.]+$').hasMatch(value)) {
      showToast('Please enter valid numbers');
      return 'Please enter valid numbers';
    }

    double cashRecovery = double.parse(value);
    double currentBalance = double.parse(_currentBalanceController.text);

    if (cashRecovery > currentBalance) {
      showToast('Cash recovery cannot be greater than current balance');
      _cashRecoveryController.clear();
      _netBalanceController.clear();
      return 'Cash recovery cannot be greater than current balance';
    }

    if (cashRecovery == 0) {
      showToast('Cash recovery cannot be zero');
      _cashRecoveryController.clear();
      _netBalanceController.clear();
      return 'Cash recovery cannot be zero';
    }

    return null;
  }

  // Function to show a toast message
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Function to fetch accounts data from the database
  Future<void> fetchAccountsData() async {
    DBHelper dbHelper = DBHelper();
    List<Map<String, dynamic>>? accounts = await dbHelper.getAccoutsDB();

    setState(() {
      accountsData = accounts
          ?.where((account) =>
      account['order_date'] != null &&
          account['credit'] != null &&
          account['booker_name'] != null &&
          account['shop_name'] == selectedShopName)
          .toList() ??
          [];

      accountsData = accountsData.reversed.toList();
      accountsData = accountsData.length > 3 ? accountsData.sublist(0, 3) : accountsData;
    });
  }

  // Function to perform additional database operations on create
  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showRecoveryForm();
  }


// Function to fetch shop data
  void fetchShopData1() async {
    // Retrieve shop names from the database
    List<String> shopNames = await dbHelper.getOrderMasterShopNames();
    // Retrieve shop owners from the database
    shopOwners = (await dbHelper.getOrderBookingStatusDB())!;
    setState(() {
      // Remove duplicates and set the dropdown items
      dropdownItems1 = shopNames.toSet().toList();
    });
  }

// Function to show a loading indicator
  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Please Wait..."),
            ],
          ),
        );
      },
    );
  }

// Function to get the current date in a specific format
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

// Function to update the net balance based on current balance and cash recovery
  void updateNetBalance() {
    double totalAmount = double.tryParse(_currentBalanceController.text) ?? 0;
    double cashRecovery = double.tryParse(_cashRecoveryController.text) ?? 0;
    double netBalance = totalAmount - cashRecovery;
    _netBalanceController.text = netBalance.toString();
  }

// Function to load the recovery form counter from SharedPreferences
  Future<void> _loadRecoveryFormCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    if (recoveryFormCurrentMonth != currentMonth) {
      recoveryFormSerialCounter = 1;
      recoveryFormCurrentMonth = currentMonth;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recoveryFormSerialCounter = (prefs.getInt('recoveryFormSerialCounter') ?? RecoveryhighestSerial ?? 1);
      recoveryFormCurrentMonth = prefs.getString('recoveryFormCurrentMonth') ?? recoveryFormCurrentMonth;
      recoveryFormCurrentUserId = prefs.getString('recoveryFormCurrentUserId') ?? '';
    });
    if (kDebugMode) {
      print('SR:$recoveryFormSerialCounter');
    }
  }

// Function to save the recovery form counter to SharedPreferences
  Future<void> _saveRecoveryFormCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recoveryFormSerialCounter', recoveryFormSerialCounter);
    await prefs.setString('recoveryFormCurrentMonth', recoveryFormCurrentMonth);
    await prefs.setString('recoveryFormCurrentUserId', recoveryFormCurrentUserId);
  }

// Function to generate a new recovery form order ID
  String generateNewRecoveryFormOrderId(String receipt, String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (recoveryFormCurrentUserId != userId) {
      recoveryFormSerialCounter = RecoveryhighestSerial ?? 1;
      recoveryFormCurrentUserId = userId;
    }

    if (recoveryFormCurrentMonth != currentMonth) {
      recoveryFormSerialCounter = 1;
      recoveryFormCurrentMonth = currentMonth;
    }

    String orderId =
        "$receipt-$userId-$currentMonth-${recoveryFormSerialCounter.toString().padLeft(3, '0')}";
    recoveryFormSerialCounter++;
    _saveRecoveryFormCounter();
    return orderId;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white10,
          title: const Text(
            'Recovery Form',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Date:',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            getCurrentDate(),
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Shop Name',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 10),
                        DropdownSearch<String>(
                          items: dropdownItems1, // List of items
                          popupProps: PopupProps.menu(
                            showSearchBox: true, // Enables search functionality
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search Shop',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                            menuProps: MenuProps(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: '--Select Shop--',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                          ),
                          selectedItem: selectedDropdownValue,
                          onChanged: (String? suggestion) async {
                            if (suggestion != null) {
                              setState(() {
                                selectedDropdownValue = suggestion;
                                selectedShopName = suggestion;
                              });

                              // Fetch account data and update other details
                              await fetchAccountsData();

                              for (var owner in shopOwners) {
                                if (owner['shop_name'] == selectedShopName) {
                                  setState(() {
                                    selectedShopBrand = owner['brand'];
                                    selectedShopCityR = owner['city'];
                                  });
                                }
                              }

                              // Save the selected shop name in SharedPreferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('selectedShopName', selectedShopName!);

                              // Update the balance
                              newDatabaseOutputs outputs = newDatabaseOutputs();
                              await outputs.updateBalanceData();

                              setState(() {
                                String balance = prefs.getString('balance') ?? 'no data';
                                recoveryFormCurrentBalance = double.parse(balance);
                                _currentBalanceController.text = recoveryFormCurrentBalance.toString();
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Current Balance'),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 30,
                                        width: 150,
                                        child: TextFormField(
                                          controller: _currentBalanceController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          textAlign: TextAlign.left,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            double currentBalance = double.parse(value);
                                            if (currentBalance < 1) {
                                              return 'Current balance should be at least 1';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              '----- Previous Payment History -----',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Shop')),
                                  DataColumn(label: Text('Amount')),
                                ],

                                // Modify the DataRow creation inside the DataTable
                                rows: accountsData.map(
                                      (account) => DataRow(
                                    cells: [
                                      DataCell(Text(account['order_date'] ?? '')),
                                      DataCell(Text(account['shop_name'] ?? '')),
                                      DataCell(Text(account['credit']?.toString() ?? '')),
                                    ],
                                  ),
                                ).toList(),


                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Cash Recovery      '),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 30,

                                        width: 175,
                                        child: TextFormField(
                                          controller: _cashRecoveryController,
                                          onChanged: (value) {
                                            updateNetBalance();
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          textAlign: TextAlign.left,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter some text';
                                            } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                              return 'Please enter digits only';
                                            }

                                            // Convert values to double for comparison
                                            double cashRecovery = double.parse(value);
                                            String balanceText = _currentBalanceController.text;
                                            double currentBalance = double.tryParse(balanceText) ?? 0.0;
                                           // double currentBalance = double.parse(_currentBalanceController.text);

                                            // Check if cash recovery is greater than current balance
                                            if (cashRecovery > currentBalance) {
                                              selectedDropdownValue='';
                                              _currentBalanceController.clear();
                                              _cashRecoveryController.clear();
                                              _netBalanceController.clear();

                                              return 'Cash recovery cannot be greater than current balance';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number, // Restrict keyboard to numeric
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Net Balance          '),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 30,
                                        width: 175,
                                        child: TextFormField(
                                          controller: _netBalanceController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          textAlign: TextAlign.left,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () async {
                              showLoadingIndicator(context);
                             final  bool isConnected = await isInternetAvailable();
                              Navigator.of(context, rootNavigator: true).pop();
                              if (!isConnected) {
                                showToast('Please check your internet connection.');
                                return; // Exit the function early if internet connection is not available
                              }


                              if (_cashRecoveryController.text.isNotEmpty && _netBalanceController.text.isNotEmpty) {
                                if (selectedDropdownValue != null && selectedDropdownValue!.isNotEmpty) {
                                  double cashRecovery = double.tryParse(_cashRecoveryController.text) ?? 0.0;
                                  if (cashRecovery > 0 && cashRecovery <= recoveryFormCurrentBalance) {
                                        String newOrderId2 = generateNewRecoveryFormOrderId(Receipt, userId.toString());
                                      await  recoveryformViewModel.addRecoveryForm(
                                          RecoveryFormModel(
                                            recoveryId: newOrderId2,
                                            shopName: selectedDropdownValue,
                                            cashRecovery: _cashRecoveryController.text,
                                            netBalance: _netBalanceController.text,
                                            date: getCurrentDate(),
                                            userId: userId,
                                            bookerName: userNames,
                                            city: selectedShopCityR,
                                            brand: selectedShopBrand
                                          ),
                                        );
                                        bool isConnected = await isInternetAvailable();
                                        if (isConnected== true) {
                                          await recoveryformViewModel.postRecoveryForm();
                                        }



                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecoveryForm_2ndPage(
                                          formData: {
                                            'recoveryId': newOrderId2,
                                            'shopName': selectedDropdownValue,
                                            'cashRecovery': _cashRecoveryController.text,
                                            'netBalance': _netBalanceController.text,
                                            'date': getCurrentDate(),
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    if (cashRecovery <= 0) {
                                      showToast('Cash recovery must be greater than 0.');
                                    } else {
                                      showToast('Cash recovery cannot be greater than the current balance.');
                                    }
                                  }
                                } else {
                                  showToast('Please select a shop before moving to the next page.');
                                }
                              } else {
                                showToast('Please fill in all fields before moving to the next page.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF212529),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
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
}