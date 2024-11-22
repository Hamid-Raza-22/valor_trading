
import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';

import '../../API/ApiServices.dart';
import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/StockCheckItems.dart';

class StockCheckItemsRepository {

  DBHelper dbHelperStockCheckItems = DBHelper();

  Future<List<StockCheckItemsModel>> getStockCheckItems() async {
    var dbClient = await dbHelperStockCheckItems.db;
    List<Map> maps = await dbClient!.query('Stock_Check_Items', columns: ['id','shopvisitId', 'itemDesc', 'qty' ]);
    List<StockCheckItemsModel> stockcheckitems = [];
    for (int i = 0; i < maps.length; i++) {

      stockcheckitems.add(StockCheckItemsModel.fromMap(maps[i]));
    }
    return stockcheckitems;
  }
  Future<void> postStockCheckItems() async {
    var db = await dbHelperStockCheckItems.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM Stock_Check_Items');

      if (products.isNotEmpty) {
        for (var i in products) {
          if (kDebugMode) {
            print(i.toString());
          }

          StockCheckItemsModel v = StockCheckItemsModel(
            id: "${i['id']}${i['shopvisitId']}".toString(),
            shopvisitId: i['shopvisitId'].toString(),
            itemDesc: i['itemDesc'].toString(),
            qty: i['qty'].toString(),
          );

          try {
            final results = await Future.wait([
              api.masterPost(v.toMap(), stockCheckItemsApi),
              // api.masterPost(v.toMap(), 'https://apex.oracle.com/pls/apex/metaxpertss/shopvisit/post/'),
            ]);

            if (results[0] == true) {
              await db.rawQuery('DELETE FROM Stock_Check_Items WHERE id = ?', [i['id']]);
              if (kDebugMode) {
                print("Successfully posted and deleted data for stock check item ID: ${i['id']}");
              }
            } else {
              if (kDebugMode) {
                print("Failed to post data for stock check item ID: ${i['id']}");
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error making API requests for stock check item ID: ${i['id']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing stock check items data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }


  // Future<void> addStockCheckItems(StockCheckItemsModel stockCheckItemsList) async {
  //   final db = await dbHelperStockCheckItems.db;
  //   for (var stockCheckItems in stockCheckItemsList) {
  //     await db?.insert('Stock_Check_Items',stockCheckItems.toMap());
  //   }
  // }

  Future<int> add(StockCheckItemsModel stockcheckitemsModel) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.insert('Stock_Check_Items', stockcheckitemsModel.toMap());
  }

  Future<int> update(StockCheckItemsModel stockcheckitemsModel) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.update('Stock_Check_Items', stockcheckitemsModel.toMap(),
        where: 'id = ?', whereArgs: [stockcheckitemsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperStockCheckItems.db;
    return await dbClient!.delete('Stock_Check_Items',
        where: 'id = ?', whereArgs: [id]);
  }
}