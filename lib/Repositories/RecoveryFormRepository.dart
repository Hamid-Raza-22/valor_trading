

import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';

import '../API/ApiServices.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/RecoveryFormModel.dart';

class RecoveryFormRepository{

  DBHelper dbHelperRecoveryForm = DBHelper();

  Future<List<RecoveryFormModel>> getRecoveryForm() async{
    var dbClient = await dbHelperRecoveryForm.db;
    List<Map> maps = await dbClient!.query('recoveryForm',columns: ['recoveryId','date','shopName','netBalance',' userId', 'bookerName', 'city', 'brand' ]);
    List<RecoveryFormModel> recoveryform = [];
    for(int i = 0; i<maps.length; i++)
    {
      recoveryform.add(RecoveryFormModel.fromMap(maps[i]));
    }
    return recoveryform;
  }
  Future<void> postRecoveryFormTable() async {
    var db = await dbHelperRecoveryForm.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM recoveryForm');

      if (products.isNotEmpty) {  // Check if the table is not empty
        for (var i in products) {
          if (kDebugMode) {
            print("FIRST ${i.toString()}");
          }

          RecoveryFormModel v = RecoveryFormModel(
            recoveryId: i['recoveryId'].toString(),
            shopName: i['shopName'].toString(),
            date: i['date'].toString(),
            cashRecovery: i['cashRecovery'].toString(),
            netBalance: i['netBalance'].toString(),
            userId: i['userId'].toString(),
            bookerName: i['bookerName'].toString(),
            city: i['city'].toString(),
            brand: i['brand'].toString(),
          );

          try {
            final results = await Future.wait([
              api.masterPost(v.toMap(), recoveryFormApi),
              // api.masterPost(v.toMap(), 'https://apex.oracle.com/pls/apex/metaxpertss/recoveryform/post/'),
            ]);

            if (results[0] == true) {
              await db.rawQuery('DELETE FROM recoveryForm WHERE recoveryId = ?', [i['recoveryId']]);
              if (kDebugMode) {
                print("Successfully posted and deleted data for recovery form ID: ${i['recoveryId']}");
              }
            } else {
              if (kDebugMode) {
                print("Failed to post data for recovery form ID: ${i['recoveryId']}");
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error making API requests for recovery form ID: ${i['recoveryId']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing recovery form data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }
  //
  // Future<String> getLastId() async {
  //   var dbClient = await dbHelperReturnForm.db;
  //   List<Map> maps = await dbClient.query(
  //     'returnForm',
  //     columns: ['returnId'],
  //     orderBy: 'returnId DESC',
  //     limit: 1,
  //   );
  //
  //   if (maps.isEmpty) {
  //     // Handle the case when no records are found
  //     return "";
  //   }
  //
  //   // Convert the orderId to a string and return
  //   return maps[0]['returnId'].toString();
  // }


  Future<int> add(RecoveryFormModel  recoveryform) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.insert('recoveryForm',  recoveryform.toMap());
  }

  Future<int> update(RecoveryFormModel  recoveryform) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.update('recoveryForm', recoveryform.toMap(),
        where: 'recoveryForm = ?', whereArgs: [ recoveryform.recoveryId]);
  }


  Future<int> delete(int recoveryId) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.delete('recoveryForm',
        where: 'recoveryId = ?', whereArgs: [recoveryId]);
  }




}

