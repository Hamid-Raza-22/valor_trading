
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';
import 'package:sqflite/sqflite.dart';

import '../../API/ApiServices.dart';
import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/ReturnFormDetails.dart';

class ReturnFormDetailsRepository {
  final Queue<Map<String, dynamic>> _queue = Queue();
  bool _isProcessing = false;
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
    if (_isProcessing) {
      return; // Prevent function re-entry if it's already running
    }

    var db = await dbHelperReturnFormDetails.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM return_form_details');

      if (products.isNotEmpty) {  // Check if the table is not empty
        // Add products to the queue
        for (var product in products) {
          _queue.add(product);
        }
        _processQueue(api, db);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing return form details data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }

  Future<void> _processQueue(ApiServices api, Database? db) async {
    if (_isProcessing) return; // Ensure only one instance is processing

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      var product = _queue.removeFirst();

      if (kDebugMode) {
        print("Posting return form details for ${product['id']}");
      }

      ReturnFormDetailsModel v = ReturnFormDetailsModel(
        id: product['id'].toString(),
        returnFormId: product['returnFormId'].toString(),
        productName: product['productName'].toString(),
        reason: product['reason'].toString(),
        quantity: product['quantity'].toString(),
        bookerId: product['bookerId'].toString(),
      );

      try {
        final result = await api.masterPost(v.toMap(), returnFormDetailsApi);

        if (result == true) {
          if (kDebugMode) {
            print('Successfully posted return form details for ID: ${product['id']}');
          }
          await db!.rawDelete('DELETE FROM return_form_details WHERE id = ?', [product['id']]);
        } else {
          if (kDebugMode) {
            print('Failed to post return form details for ID: ${product['id']}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error posting return form details for ID: ${product['id']} - $e");
        }
      }
    }

    _isProcessing = false; // Reset the flag when done
  }


  // Future<void> postReturnFormDetails() async {
  //   var db = await dbHelperReturnFormDetails.db;
  //   final ApiServices api = ApiServices();
  //
  //   try {
  //     PostingStatus.isPosting.value = true; // Set posting status to true
  //
  //     final products = await db!.rawQuery('SELECT * FROM return_form_details');
  //
  //     if (products.isNotEmpty) {  // Check if the table is not empty
  //       for (var i in products) {
  //         if (kDebugMode) {
  //           print("Posting return form details for ${i['id']}");
  //         }
  //
  //         ReturnFormDetailsModel v = ReturnFormDetailsModel(
  //           id: i['id'].toString(),
  //           returnformId: i['returnFormId'].toString(),
  //           productName: i['productName'].toString(),
  //           reason: i['reason'].toString(),
  //           quantity: i['quantity'].toString(),
  //           bookerId: i['bookerId'].toString(),
  //         );
  //
  //         try {
  //           final results = await Future.wait([
  //             api.masterPost(v.toMap(), returnFormDetailsApi),
  //             // api.masterPost(v.toMap(), 'https://apex.oracle.com/pls/apex/metaxpertss/returnformdetail/post'),
  //           ]);
  //
  //           if (results[0] == true) {
  //             if (kDebugMode) {
  //               print('Successfully posted return form details for ID: ${i['id']}');
  //             }
  //             await db.rawDelete('DELETE FROM return_form_details WHERE id = ?', [i['id']]);
  //           } else {
  //             if (kDebugMode) {
  //               print('Failed to post return form details for ID: ${i['id']}');
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print("Error posting return form details for ID: ${i['id']} - $e");
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error processing return form details data: $e");
  //     }
  //   } finally {
  //     PostingStatus.isPosting.value = false; // Set posting status to false
  //   }
  // }
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