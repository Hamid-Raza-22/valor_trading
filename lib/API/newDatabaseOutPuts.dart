import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';

import 'package:metaxperts_valor_trading_dynamic_apis/get_apis/Get_apis.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/ip_addresses/IP_addresses.dart';
import '../API/Globals.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import '../Databases/DBHelper.dart';
import 'ApiServices.dart' show ApiServices;
class newDatabaseOutputs {

  Future<void> checkFirstRun() async {
    SharedPreferences SP = await SharedPreferences.getInstance();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstrun = SP.getBool('firstrun') ?? true;
    if (firstrun == true) {
      await SP.setBool('firstrun', false);
      await initializeData();
      await showTables();
      DateTime now = DateTime.now();
      String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
      await prefs.setString('lastInitializationDateTime', formattedDateTime);
      if (kDebugMode) {
        print(formattedDateTime);
      }
    }
    else {
      if (kDebugMode) {
        print("UPDATING.......................................");
      }
      // await updateOrderBookingStatusData();
      await updateRecoveryFormGetData();
      await showRecoveryFormGetData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? formattedDateTime = prefs.getString('lastInitializationDateTime');
      DateTime now = DateTime.now();
      formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
      await prefs.setString('lastInitializationDateTime', formattedDateTime);
      // print(formattedDateTime);
    }
  }



  Future<void> initializeData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    String? brand = prefs.getString('userBrand');

    var orderBookingStatusdata = await db.getallOrderBookingStatusDB();
    var owerdata = await db.getAllownerData();
    var productdata = await db.getAllProductsData();
    var orderMasterdata = await db.getAllOrderMasterData();
    var orderDetailsdata = await db.getAllOrderDetailsData();
    var pCdata = await db.getAllProductCategoryData();
    var recoveryFormGetData = await db.getAllRecoveryFormGetData();
    var pakCities= await db.getPakCitiesDB();
    var netBalancedata = await db.getNetBalanceDB();
    var accountsdata = await db.getAccoutsDB();

    if (accountsdata == null || accountsdata.isEmpty ) {
      bool inserted = false;

      try{
        var response3 = await api.getApi("$accountApi$id");
      inserted = await db.insertAccountsData(response3);
      // var response2 = await api.getApi("$Alt_IP_Address/account/get/");
      //
      // var results2 = await db.insertAccoutsData(response2);   //return True or False
      //return True or False
      if (inserted== true) {
        if (kDebugMode) {
          print("Accounts Data inserted successfully.");
        }
      } else {
        if (kDebugMode) {
          print("Error inserting data.");
        }
      }
    }catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi(
              "$altAccountApi$id");
          inserted = await db.insertAccountsData(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("Account Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert Account data.");
          }
        }
      }
    }
    if (netBalancedata == null || netBalancedata.isEmpty ) {
      bool inserted = false;
      try{
      var response3 = await api.getApi("$balance$id");
      inserted = await db.insertNetBalanceData(response3);
      // var response2 = await api.getApi("$Alt_IP_Address/balance/get/");
      //
      // var results2 = await db.insertNetBalanceData(response2);   //return True or False
      //return True or False
      if ( inserted== true) {
        if (kDebugMode) {
          print(" Net Balance Data inserted successfully 1st.");
        }
      } else {
        if (kDebugMode) {
          print("Error inserting data.");
        }
      }
    }catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }

        try {
          var response = await api.getApi(
              "$altBalance$id");
          inserted = await db.insertNetBalanceData(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("Balance Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert Balance data.");
          }
        }
      }

    }
    if (recoveryFormGetData == null || recoveryFormGetData.isEmpty) {
      bool inserted = false;

      try {
        var response = await api.getApi(
            "$recoveryForm$id");

        inserted = await db.insertRecoveryFormGetData(
            response); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print(
                "RecoveryFormGetData Data inserted successfully using first API.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi(
              "$altRecoveryForm$id");
          inserted = await db.insertRecoveryFormGetData(response); // returns True or False

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
            print(
                "Error with second API as well. Unable to fetch or insert RecoveryFormGet data.");
          }
        }
      }
    }
    // function for the product category
    if (pCdata == null || pCdata.isEmpty) {
      bool inserted = false;

      try {
        var response1 = await api.getApi(
            brandsApi);
        inserted= await db.insertProductCategoryData(
            response1); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print("Brands inserted successfully using first API.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        // if (kDebugMode) {
        //   print("Error with first API. Trying second API.");
        // }
        try {
          var response = await api.getApi(
              "$altBrandsApi$id");
          inserted = await db.insertProductCategoryData(response); // returns True or False

          if (inserted ==true) {
            if (kDebugMode) {
              print("Brand Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert Brand data.");
          }
        }}
    } else {
      if (kDebugMode) {
        print("Data is available.");
      }
    }
    if (pakCities == null || pakCities.isEmpty) {
      bool inserted = false;

      try {
        // https://apex.oracle.com/pls/apex/metaa/owner/get/
        //http://103.149.32.30:8080/ords/metaxperts/owner/get/
        var response = await api.getApi(
            city);
        inserted= await db.insertPakCitiesData(response); //return True or False
        if (inserted== true) {
          if (kDebugMode) {
            print("PAK Cities Data inserted successfully using first API..");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data.");
          }
        }
      } catch (e) {
        // if (kDebugMode) {
        //   print("Error with first API. Trying second API.");
        // }
        try {
          var response = await api.getApi(
              altCity);
          inserted = await db.insertPakCitiesData(response); // returns True or False

          if (inserted==true) {
            if (kDebugMode) {
              print("City Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert City data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Data is available.");
      }
    }

    // function for the order details table
    if (orderDetailsdata == null || orderDetailsdata.isEmpty) {
      bool inserted = false;

      try {
        var response1 = await api.getApi(
            "$orderDetails$id");
        inserted = await db.insertOrderDetailsData(
            response1); //return True or False
        if (inserted==true) {
          if (kDebugMode) {
            print("OrderDetails Data inserted successfully .");
          }
        } else {
          throw Exception('Insertion failed');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with 1st API.");
        }
        try {
          var response = await api.getApi(
              "$Alt_IP_Address/detailsget/get/$id");
          inserted = await db.insertOrderDetailsData(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("OrderDetails Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert OrderDetails data.");
          }
        }}
    }
    //funcion for the order master data
    if (orderMasterdata == null || orderMasterdata.isEmpty) {
      bool inserted = false;

      try {
        var response1 = await api.getApi(
            "$orderMaster$id");
        inserted = await db.insertOrderMasterData(
            response1); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print("OrderMaster Data inserted successfully using first API.");
          }
        } else {
          throw Exception('Insertion failed ');
        }
      }
      catch (e) {
        if (kDebugMode) {
          print("Error with API.");
        }
        try {
          var response = await api.getApi(
              "$altOrderMaster$id");
          inserted = await db.insertLogin(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("OrderMaster Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert OrderMaster data.");
          }
        }
    }}


// function for the products data table
    if (productdata == null || productdata.isEmpty) {
      bool inserted = false;

      try {
        var response1 = await api.getApi(
            productsApi);
        inserted = await db.insertProductsData(
            response1); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print("Products Data inserted successfully using first API.");
          }
        } else {
          throw Exception('Insertion failed with first API');
        }
      } catch (e) {
        // if (kDebugMode) {
        //   print("Error with first API. Trying second API.");
        // }
        try {
          var response = await api.getApi(
              "$altProductsApi$brand");
          inserted = await  db.insertProductsData(response); // returns True or False

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
            print(
                "Error with second API as well. Unable to fetch or insert Products data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Data is available.");
      }
    }
    //for the owner data
    if (owerdata == null || owerdata.isEmpty) {
      bool inserted = false;

      try {

        var response = await api.getApi1(
            shopDetails);
        inserted = await db.insertownerData(response); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print("Owner Data inserted successfully using first API..");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data.");
          }
        }
      } catch (e) {
        // if (kDebugMode) {
        //   print("Error with first API. Trying second API.");
        // }
        try {
          var response = await api.getApi(
              altShopDetails);
          inserted = await db.insertownerData(response); // returns True or False

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
            print(
                "Error with second API as well. Unable to fetch or insert Owner data.");
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("Data is available.");
      }
    }
//for the order booking Status table
    if (orderBookingStatusdata == null || orderBookingStatusdata.isEmpty) {
      bool inserted = false;

      try {
        var response = await api.getApi(
            "$orderBookingStatus$id");
        inserted = await db.insertOrderBookingStatusData1(
            response); //return True or False
        if (inserted) {
          if (kDebugMode) {
            print(
                "OrderBookingStatus Data inserted successfully using first API.");
          }
        } else {
          if (kDebugMode) {
            print("Error inserting data.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }
        try {
          var response = await api.getApi(
              "$altOrderBookingStatus$id");
          inserted = await db.insertOrderBookingStatusData1(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("OrderBookingStatus Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert OrderBookingStatus data.");
          }
        }
      }
    }
  }
//   Future<void> initializeData() async {
//
//     await initializeAccountsData();
//     await initializeNetBalanceData();
//     await initializeRecoveryFormGetData();
//     await initializeProductCategoryData();
//     await initializePakCitiesData();
//     await initializeOrderDetailsData();
//     await initializeOrderMasterData();
//     await initializeProductsData();
//     await initializeOwnerData();
//     await initializeOrderBookingStatusData();
//   }

  Future<void> initializeAccountsData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var accountsdata = await db.getAccoutsDB();
    if (accountsdata == null || accountsdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/accounts/get/$id");
        bool inserted = await db.insertAccountsData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/accounts/get/$id");
          bool inserted = await db.insertAccountsData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Account data.");
          }
        }
      }
    }
  }

  Future<void> initializeNetBalanceData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var netBalancedata = await db.getNetBalanceDB();
    if (netBalancedata == null || netBalancedata.isEmpty) {
      try {
        var response = await api.getApi("$balance$id");
        bool inserted = await db.insertNetBalanceData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/allbalance/get/$id");
          bool inserted = await db.insertNetBalanceData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Net Balance data.");
          }
        }
      }
    }
  }

  Future<void> initializeRecoveryFormGetData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var recoveryFormGetData = await db.getAllRecoveryFormGetData();
    if (recoveryFormGetData == null || recoveryFormGetData.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/recovery1/get/$id");
        bool inserted = await db.insertRecoveryFormGetData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/recovery1/get/$id");
          bool inserted = await db.insertRecoveryFormGetData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert RecoveryFormGet data.");
          }
        }
      }
    }
  }

  Future<void> initializeProductCategoryData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var pCdata = await db.getAllProductCategoryData();
    if (pCdata == null || pCdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/brand1/get/$id");
        bool inserted = await db.insertProductCategoryData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/brand1/get/$id");
          bool inserted = await db.insertProductCategoryData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Product Category data.");
          }
        }
      }
    }
  }

  Future<void> initializePakCitiesData() async {
    final api = ApiServices();
    final db = DBHelper();

    var pakCities = await db.getPakCitiesDB();
    if (pakCities == null || pakCities.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/city/get/");
        bool inserted = await db.insertPakCitiesData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/city/get/");
          bool inserted = await db.insertPakCitiesData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Pak Cities data.");
          }
        }
      }
    }
  }

  Future<void> initializeOrderDetailsData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var orderDetailsdata = await db.getAllOrderDetailsData();
    if (orderDetailsdata == null || orderDetailsdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/detailsget/get/$id");
        bool inserted = await db.insertOrderDetailsData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/detailsget/get/$id");
          bool inserted = await db.insertOrderDetailsData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Order Details data.");
          }
        }
      }
    }
  }

  Future<void> initializeOrderMasterData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var orderMasterdata = await db.getAllOrderMasterData();
    if (orderMasterdata == null || orderMasterdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/masterget1/get/$id");
        bool inserted = await db.insertOrderMasterData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/masterget1/get/$id");
          bool inserted = await db.insertOrderMasterData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Order Master data.");
          }
        }
      }
    }
  }

  Future<void> initializeProductsData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? brand = prefs.getString('userBrand');

    var productdata = await db.getAllProductsData();
    if (productdata == null || productdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/product1/get/$brand");
        bool inserted = await db.insertProductsData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/product1/get/$brand");
          bool inserted = await db.insertProductsData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Products data.");
          }
        }
      }
    }
  }

  Future<void> initializeOwnerData() async {
    final api = ApiServices();
    final db = DBHelper();

    var owerdata = await db.getAllownerData();
    if (owerdata == null || owerdata.isEmpty) {
      try {
        var response = await api.getApi1("http://103.149.32.30:8080/ords/metaxperts/shopp1/get/");
        bool inserted = await db.insertownerData(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi1("$Alt_IP_Address/shopp1/get/");
          bool inserted = await db.insertownerData(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Owner data.");
          }
        }
      }
    }
  }

  Future<void> initializeOrderBookingStatusData() async {
    final api = ApiServices();
    final db = DBHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');

    var oBSdata = await db.getallOrderBookingStatusDB();
    if (oBSdata == null || oBSdata.isEmpty) {
      try {
        var response = await api.getApi("http://103.149.32.30:8080/ords/metaxperts/orderstatus1/get/$id");
        bool inserted = await db.insertOrderBookingStatusData1(response);
        if (!inserted) throw Exception('Error inserting data with first API');
      } catch (e) {
        try {
          var response = await api.getApi("$Alt_IP_Address/orderstatus1/get/$id");
          bool inserted = await db.insertOrderBookingStatusData1(response);
          if (!inserted) throw Exception('Error inserting data with second API');
        } catch (e) {
          if (kDebugMode) {
            print("Error with both APIs. Unable to fetch or insert Order Booking Status data.");
          }
        }
      }
    }
  }

  Future<void> initializeLoginData() async {
    final api = ApiServices();
    final db = DBHelper();
    var logindata = await db.getAllLogins();


    if (logindata == null || logindata.isEmpty) {
      bool inserted = false;

      try {
        var response = await api.getApi(
            loginApi);
        inserted = await db.insertLogin(response); // returns True or False

        if (inserted == true) {
          if (kDebugMode) {
            print("Login Data inserted successfully using first API.");
          }
        } else {
          throw Exception("Error inserting data using first API.");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error with first API. Trying second API.");
        }

        try {
          var response = await api.getApi(
              altLoginApi);
          inserted = await db.insertLogin(response); // returns True or False

          if (inserted) {
            if (kDebugMode) {
              print("Login Data inserted successfully using second API.");
            }
          } else {
            if (kDebugMode) {
              print("Error inserting data using second API.");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error with second API as well. Unable to fetch or insert login data.");
          }
        }
      }
    }await showLoginGetData();
  }
  // function for the update recovery from the data table
  Future<void> updateRecoveryFormGetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? RF;
      try {
        RF = await api.getupdateData(
            "$refRecoveryForm$id/$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        RF = await api.getupdateData(
            "$altRecoveryForm$id/$formattedDateTime");
      }
      if (RF != null && RF.isNotEmpty) {
        bool result = await db.updateRecoveryFormGetData(RF);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for RecoveryFormGet table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Product RecoveryFormGet table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in RecoveryFormGet Category table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }
    showRecoveryFormGetData();
  }
  Future<void> showRecoveryFormGetData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Recovery Form Get table**************");
    }
    final db = DBHelper();
    var data = await db.getAllRecoveryFormGetData();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Recovery Form in table is $co");
    }
  }
 Future<void> showLoginGetData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Login table**************");
    }
    final db = DBHelper();
    var data = await db.getAllLogins();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Login table is $co");
    }
  }

  // function for the product category data table
  Future<void> updateProductCategoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? ProductCat;
      try {
        ProductCat = await api.getupdateData(
            "$refBrandsApi$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        ProductCat = await api.getupdateData(
            "$altRefBrandsApi/$formattedDateTime");
      }
      if (ProductCat != null && ProductCat.isNotEmpty) {
        bool result = await db.updateProductCategoryData(ProductCat);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for Product Category table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Product Category table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in Product Category table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    } //showProductCategoryData();
  }
  Future<void> showProductCategoryData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Product Category table**************");
    }
    final db = DBHelper();
    var data = await db.getAllProductCategoryData();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Product Category in table is $co");
    }
  }

  // functions for the order details data table
  Future<void> updateOrderDetailsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? details;
      try {
        details = await api.getupdateData(
            "$refOrderDetails$id/$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        details = await api.getupdateData(
            "$Alt_IP_Address/newdetailsgettime/get/$id/$formattedDateTime");
      }
      if (details != null && details.isNotEmpty) {
        bool result = await db.updateOrderDetailsDataTable(details);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for Order details table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Order details table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in Order details table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }
   // showOrderDetailsData();
  }
  Future<void> showOrderDetailsData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Order Details table**************");
    }
    final db = DBHelper();
    var data = await db.getAllOrderDetailsData();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Order Details in table is $co");
    }
  }


// functions for the order master data table
  Future<void> updateOrderMasterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? master;
      try {
        master = await api.getupdateData(
            "$refOrderMaster$id/$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from  1st API: $e");
        }
        master = await api.getupdateData(
            "$Alt_IP_Address/newmastergettime/get/$id/$formattedDateTime");
      }
      if (master != null && master.isNotEmpty) {
        bool result = await db.updateOrderMasterDataTable(master);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for Order Master table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Order Master table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in Order Master table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }
   // showOrderMasterData();
  }
  Future<void> showOrderMasterData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Order Master table**************");
    }
    final db = DBHelper();
    var data = await db.getAllOrderMasterData();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Order Master in table is $co");
    }
  }
  // functions for the order master data table
  Future<void> updateBalanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    String? shopname = prefs.getString('selectedShopName');

    if (kDebugMode) {
      print("Initial shopname: $shopname");
    }

    // Sanitize the shopname
    if (shopname != null) {
      shopname = shopname.trim(); // Remove leading and trailing spaces
      shopname = Uri.encodeComponent(shopname); // Encode the shopname for URL

      if (kDebugMode) {
        print("Sanitized shopname: $shopname");
      }
    }

    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? balance;
      try {
        balance = await api.getupdateData(
            "$refBalance$shopname/$id"
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        balance = await api.getupdateData(
            "$Alt_IP_Address/totalbalance/get/$shopname/$id"
        );
      }
      if (balance != null && balance.isNotEmpty) {
        bool result = await db.updateBalanceData(balance);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for Balance table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Shop Balance table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in Shop Balance table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }
    showBalanceData();
  }
  Future<void> showBalanceData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Shop Balance table**************");
    }
    final db = DBHelper();
    var data = await db.getNetBalanceDB();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Shop Balance in table is $co");
    }
  }

  // functions for the products data table
  Future<void> updateProductsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      print("formattedDateTimeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$formattedDateTime");
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? productsdata;
      try {
        productsdata = await api.getupdateData(
            "$refProductsApi/$formattedDateTime");

      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        productsdata = await api.getupdateData(
            "$Alt_IP_Address/newproductget/get/$userBrand/$formattedDateTime");
      }
      if (productsdata != null && productsdata.isNotEmpty) {
        bool result = await db.updateProductsDataTable(productsdata);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for products table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating products table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in products table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }//showProductsData();
  }
  Future<void> showProductsData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Product table**************");
    }
    final db = DBHelper();
    try {
    var data = await db.getAllProductsData();
    int totalCount = data?.length ?? 0;

    if (kDebugMode) {
      print("TOTAL number of Products data in the table is $totalCount");
    }
  } catch (e) {
  if (kDebugMode) {
  print("Error fetching Products data: ${e.toString()}");
  }
  }
}

  // functions for the owner data table
  Future<void> updateOwnerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? ownerdata;
      try {
        ownerdata = await api.getupdateData(
            "$refShopDetails$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        ownerdata = await api.getupdateData(
            "$Alt_IP_Address/newshop1/get/$formattedDateTime");
      }
      if (ownerdata != null && ownerdata.isNotEmpty) {
        bool result = await db.updateownerDataTable(ownerdata);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for owner table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating owner table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in owner table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }showOwnerData();
  }
  Future<void> showOwnerData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Owner data Table**************");
    }
    final db = DBHelper();
    try {
      var data = await db.getAllownerData();
      int totalCount = data?.length ?? 0;

      if (kDebugMode) {
        print("TOTAL number of owner data in the table is $totalCount");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching owner data: ${e.toString()}");
      }
    }
  }
  // functions for the Cities data table
  Future<void> updateCitiesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? citydata;
      try {
        citydata = await api.getupdateData(
            "$refCity$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        citydata = await api.getupdateData(
            "$Alt_IP_Address/newcities/get/$formattedDateTime");
      }
      if (citydata != null && citydata.isNotEmpty) {
        bool result = await db.updateCitiesDataTable(citydata);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for Cities table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating Cities table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in Cities table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }showCityData();
  }
  Future<void> showCityData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Cites data Table**************");
    }
    final db = DBHelper();
    try {
      var data = await db.getPakCitiesDB();
      int totalCount = data?.length ?? 0;

      if (kDebugMode) {
        print("TOTAL number of Cities data in the table is $totalCount");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching Cities data: ${e.toString()}");
      }
    }
  }

  // Future<void> showOwnerData() async {
  //   if (kDebugMode) {
  //     print("************Tables SHOWING**************");
  //   }
  //   if (kDebugMode) {
  //     print("************Owner data Table**************");
  //   }
  //   final db = DBHelper();
  //   var data = await db.getAllownerData();
  //   int co = 0;
  //   for (var i in data!) {
  //     co++;
  //     if (kDebugMode) {
  //       print("$co | ${i.toString()} \n");
  //     }
  //   }
  //   if (kDebugMode) {
  //     print("TOTAL of no of owner data in table is $co");
  //   }
  // }
// function for order booking status

  Future<void> updateOrderBookingStatusData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? orderBookingStatusData;
      try {
        orderBookingStatusData = await api.getupdateData(
            "$refOrderBookingStatus$id/$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        orderBookingStatusData = await api.getupdateData(
            "$Alt_IP_Address/newstatusgettime/get/$id/$formattedDateTime");
      }
      if (orderBookingStatusData != null && orderBookingStatusData.isNotEmpty) {
        for (var newData in orderBookingStatusData) {
          await db.updateOrderBookingStatusData1(
              [newData], newData['order_no']);
          if (kDebugMode) {
            print("Data Updated Successfully");
          }
        }
      }
      else {
        if (kDebugMode) {
          print("no data is find for the update");
        }
      }
    }
    else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }
    showstatus();
  }
  Future<void> showstatus() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************order booking status**************");
    }
    final db = DBHelper();

    var data = await db.getallOrderBookingStatusDB();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of order in table is $co");
    }
  }

// function for the login table
  Future<void> updateloginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? login;
      try {
        login = await api.getupdateData(
            "$refLoginApi$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        login = await api.getupdateData(
            "$Alt_IP_Address/logindata/get/$formattedDateTime");
      }
      if (login != null && login.isNotEmpty) {
        bool result = await db.updateloginTable(login);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for login table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating login table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in login table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }showlogintable();
  }
  Future<void> showlogintable() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************login table**************");
    }
    final db = DBHelper();
    var data = await db.getAllLogins();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of login in table is $co");
    }
  }

  // function for the accounts data table
  Future<void> updateAccountsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    String? id = prefs.getString('userId');
    if (formattedDateTime != null) {
      final db = DBHelper();
      final api = ApiServices();
      List<dynamic>? accounts;
      try {
        accounts = await api.getupdateData(
            "$refAccountApi$id/$formattedDateTime");
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching data from API: $e");
        }
        accounts = await api.getupdateData(
            "$Alt_IP_Address/newaccounttime/get/$id/$formattedDateTime");
      }
      if (accounts != null && accounts.isNotEmpty) {
        bool result = await db.updateAccountsData(accounts);
        if (result) {
          if (kDebugMode) {
            print("Data Updated Successfully for accounts table");
          }
        } else {
          if (kDebugMode) {
            print("Error updating accounts table");
          }
        }
      } else {
        if (kDebugMode) {
          print("No data found for update in accounts table");
        }
      }
    } else {
      if (kDebugMode) {
        print('No formatted date and time found in SharedPreferences');
      }
    }//showAccountsData();
  }
  Future<void> showAccountsData() async {
    if (kDebugMode) {
      print("************Tables SHOWING**************");
    }
    if (kDebugMode) {
      print("************Accounts table**************");
    }
    final db = DBHelper();
    var data = await db.getAllAccountsData();
    int co = 0;
    for (var i in data!) {
      co++;
      if (kDebugMode) {
        print("$co | ${i.toString()} \n");
      }
    }
    if (kDebugMode) {
      print("TOTAL of no of Accounts in table is $co");
    }
  }

  Future<void> showTables() async{
    await showOwnerData();
    await showAccountsData();
    await showRecoveryFormGetData();
    await showProductCategoryData();
     await showOrderDetailsData();
     await showOrderMasterData();
     await showProductsData();
     await showstatus();
  }

  Future<void> refreshData() async{

    await updateOwnerData();
    await updateOrderMasterData();
    await updateOrderDetailsData();
    updateProductsData();
    await updateProductCategoryData();
    await updateOrderBookingStatusData();
    await updateRecoveryFormGetData();
    await updateAccountsData();
    // await updateloginData();
    await updateCitiesData();
    await updateBalanceData();
  }

}
