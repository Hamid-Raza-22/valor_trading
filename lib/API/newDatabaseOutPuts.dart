import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';

import 'package:metaxperts_valor_trading_dynamic_apis/get_apis/Get_apis.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/ip_addresses/IP_addresses.dart';
import '../API/Globals.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import '../Databases/DBHelper.dart';
import 'ApiServices.dart' show ApiServices;
class newDatabaseOutputs {
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
              "https://apex.oracle.com/pls/apex/metaxpertss/login1/get/");
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
    }await db.getAllLogins();

    // await showLoginGetData();
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
            "$refProductsApi$formattedDateTime");

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
    await updateProductsData();
    await updateProductCategoryData();
    await updateOrderBookingStatusData();
    await updateRecoveryFormGetData();
    await updateAccountsData();
    // await updateloginData();
    await updateCitiesData();
    await updateBalanceData();
  }
  Future<void> refreshHeadsData() async{

    await updateOwnerData();
    // await updateloginData();
    await updateCitiesData();

  }
}
