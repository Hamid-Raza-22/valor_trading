
import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';

import '../../API/ApiServices.dart';
import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/OrderModels/OrderMasterModel.dart';

class OrderMasterRepository{

  DBHelper dbHelperOrderMaster = DBHelper();

  Future<List<OrderMasterModel>> getOederMaster() async{
    var dbClient = await dbHelperOrderMaster.db;
    List<Map> maps = await dbClient!.query('orderMaster',columns: ['orderId','date','shopName','ownerName','phoneNo','brand','userId','userName','total','creditLimit','requiredDelivery','shopCity','posted']);
    List<OrderMasterModel> ordermaster = [];
    for(int i = 0; i<maps.length; i++)
    {
      ordermaster.add(OrderMasterModel.fromMap(maps[i]));
    }

    return ordermaster;
  }

  Future<void> postMasterTable() async {
    var db = await dbHelper.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final List<Map<String, dynamic>> records = await db!.query('orderMaster');

      for (var record in records) {
        if (kDebugMode) {
          print(record.toString());
        }
      }

      final products = await db.rawQuery('SELECT * FROM orderMaster WHERE posted = 0');
      if (products.isNotEmpty) {
        for (var i in products) {
          if (kDebugMode) {
            print("Posting order master for ${i['orderId']}");
          }

          OrderMasterModel v = OrderMasterModel(
            orderId: i['orderId'].toString(),
            shopName: i['shopName'].toString(),
            ownerName: i['ownerName'].toString(),
            phoneNo: i['phoneNo'].toString(),
            brand: i['brand'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            userName: i['userName'].toString(),
            shopCity: i['shopCity'].toString(),
            total: i['total'].toString(),
            creditLimit: i['creditLimit'].toString(),
            requiredDelivery: i['requiredDelivery'].toString(),
          );

          try {
            final results = await Future.wait([
             // api.masterPost(v.toMap(), orderMasterApi),
               api.masterPost(v.toMap(), 'http://103.149.32.30:4000/api/order-masters'),
            ]);

            if (results[0] == true) {
              if (kDebugMode) {
                print('Successfully posted order master for ID: ${i['orderId']}');
              }
              await db.rawQuery("UPDATE orderMaster SET posted = 1 WHERE orderId = '${i['orderId']}'");
            } else {
              if (kDebugMode) {
                print('Failed to post order master for ID: ${i['orderId']}');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error posting order master for ID: ${i['orderId']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing order master data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }  //
  // Future<String> getLastOrderId() async {
  //   var dbClient = await dbHelperOrderMaster.db;
  //   List<Map> maps = await dbClient.query(
  //     'orderMaster',
  //     columns: ['orderId'],
  //     orderBy: 'Id DESC',
  //     limit: 1,
  //   );
  //
  //   if (maps.isEmpty) {
  //     // Handle the case when no records are found
  //     return "";
  //   }
  //
  //   // Convert the orderId to a string and return
  //   return maps[0]['orderId'].toString();
  // }


  Future<int> add(OrderMasterModel ordermaster) async{
    var dbClient = await dbHelperOrderMaster.db;
    return await dbClient!.insert('orderMaster', ordermaster.toMap());
  }

  Future<int> update(OrderMasterModel ordermaster) async{
    var dbClient = await dbHelperOrderMaster.db;
    return await dbClient!.update('orderMaster', ordermaster.toMap(),
        where: 'orderId = ?', whereArgs: [ordermaster.orderId]);
  }


  Future<int> delete(int orderId) async{
    var dbClient = await dbHelperOrderMaster.db;
    return await dbClient!.delete('orderMaster',
        where: 'orderId = ?', whereArgs: [orderId]);
  }


  Future<List<GetOrderMasterModel>> getShopNameOrderMasterData(String user_id) async {
    var dbClient = await dbHelperOrderMaster.db;
    List<Map> maps = await dbClient!.query(
      'orderMasterData',
      columns: ['order_no', 'shop_name', 'user_Id'],
      where: 'user_Id = ?',
      whereArgs: [userId],
    );
    List<GetOrderMasterModel> getordermaster = [];
    for (int i = 0; i < maps.length; i++) {
      getordermaster.add(GetOrderMasterModel.fromMap(maps[i]));
    }
    return getordermaster;
  }
}
