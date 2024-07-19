
import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';

import '../../API/ApiServices.dart';
import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/ReturnFormDetails.dart';

class ReturnFormDetailsRepository {

  DBHelper dbHelperReturnFormDetails = DBHelper();

  Future<List<ReturnFormDetailsModel>> getReturnFormDetails() async {
    var dbClient = await dbHelperReturnFormDetails.db;
    List<Map> maps = await dbClient!.query('return_form_details', columns: ['id','returnformId', 'productName', 'quantity','bookerId', 'reason']);
    List<ReturnFormDetailsModel> returnformdetails = [];
    for (int i = 0; i < maps.length; i++) {

      returnformdetails.add(ReturnFormDetailsModel.fromMap(maps[i]));
    }
    return returnformdetails;
  }
  Future<void> postReturnFormDetails() async {
    var db = await dbHelperReturnFormDetails.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM return_form_details');

      if (products.isNotEmpty) {  // Check if the table is not empty
        for (var i in products) {
          if (kDebugMode) {
            print("Posting return form details for ${i['id']}");
          }

          ReturnFormDetailsModel v = ReturnFormDetailsModel(
            id: i['id'].toString(),
            returnformId: i['returnFormId'].toString(),
            productName: i['productName'].toString(),
            reason: i['reason'].toString(),
            quantity: i['quantity'].toString(),
            bookerId: i['bookerId'].toString(),
          );

          try {
            final results = await Future.wait([
              api.masterPost(v.toMap(), returnFormDetailsApi),
              // api.masterPost(v.toMap(), '$Alt_IP_Address/returnformdetail/post'),
            ]);

            if (results[0] == true) {
              if (kDebugMode) {
                print('Successfully posted return form details for ID: ${i['id']}');
              }
              await db.rawDelete('DELETE FROM return_form_details WHERE id = ?', [i['id']]);
            } else {
              if (kDebugMode) {
                print('Failed to post return form details for ID: ${i['id']}');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error posting return form details for ID: ${i['id']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing return form details data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }
  Future<int> add(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.insert('return_form_details', returnformdetailsModel.toMap());
  }

  Future<int> update(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.update('return_form_details',returnformdetailsModel.toMap(),
        where: 'id = ?', whereArgs: [returnformdetailsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.delete('return_form_details',
        where: 'id = ?', whereArgs: [id]);
  }
}