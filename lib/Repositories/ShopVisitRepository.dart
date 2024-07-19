
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';
import 'package:path_provider/path_provider.dart';

import '../API/ApiServices.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/ShopVisitModels.dart';

class ShopVisitRepository {

  DBHelper dbHelpershopvisit = DBHelper();

  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelpershopvisit.db;
    List<Map> maps = await dbClient!.query('shopVisit', columns: ['id','date', 'shopName','userId', 'city' , 'bookerName' , 'brand' ,'walkthrough', 'planogram' , 'signage', 'productReviewed','feedback','longitude','latitude','address', 'body']);
    List<ShopVisitModel> shopvisit = [];

    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }
    return shopvisit;
  }
  Future<void> postShopVisitData() async {
    var db = await dbHelpershopvisit.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('''
      SELECT *, 
      CASE WHEN walkthrough = 1 THEN 'True' ELSE 'False' END AS walkthrough,
      CASE WHEN planogram = 1 THEN 'True' ELSE 'False' END AS planogram,
      CASE WHEN signage = 1 THEN 'True' ELSE 'False' END AS signage,
      CASE WHEN productReviewed = 1 THEN 'True' ELSE 'False' END AS productReviewed
      FROM shopVisit
    ''');

      await db.rawQuery('VACUUM');

      if (products.isNotEmpty) {  // Check if the table is not empty
        for (Map<dynamic, dynamic> i in products) {
          if (kDebugMode) {
            print("FIRST $i");
          }

          ShopVisitModel v = ShopVisitModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            shopName: i['shopName'].toString(),
            bookerName: i['bookerName'].toString(),
            brand: i['brand'].toString(),
            city: i['city'].toString(),
            walkthrough: i['walkthrough'].toString(),
            planogram: i['planogram'].toString(),
            signage: i['signage'].toString(),
            productReviewed: i['productReviewed'].toString(),
            feedback: i['feedback'].toString(),
            latitude: i['latitude'].toString(),
            longitude: i['longitude'].toString(),
            address: i['address'].toString(),
            body: i['body'] != null && i['body'].toString().isNotEmpty
                ? Uint8List.fromList(base64Decode(i['body'].toString()))
                : Uint8List(0),
          );

          if (kDebugMode) {
            print("Image Path from Database: ${i['body']}");
          }
          if (kDebugMode) {
            print("lat:${i['latitude']}");
          }

          Uint8List imageBytes;
          final directory = await getApplicationDocumentsDirectory();
          final filePath = File('${directory.path}/captured_image.jpg');
          if (filePath.existsSync()) {
            List<int> imageBytesList = await filePath.readAsBytes();
            imageBytes = Uint8List.fromList(imageBytesList);
          } else {
            if (kDebugMode) {
              print("File does not exist at the specified path: ${filePath.path}");
            }
            continue; // Skip to the next iteration if the file doesn't exist
          }

          if (kDebugMode) {
            print("Making API request for shop visit ID: ${v.id}");
          }

          try {
            final results = await Future.wait([
              api.masterPostWithImage(v.toMap(), shopVisitApi, imageBytes),
              // api.masterPostWithImage(v.toMap(), '$Alt_IP_Address/report/post/', imageBytes),
            ]);

            if (results[0] == true) {
              await db.rawDelete( "DELETE FROM shopVisit WHERE id = '${i['id']}'");
              if (kDebugMode) {
                print("Successfully posted data for shop visit ID: ${v.id}");
              }
            } else {
              if (kDebugMode) {
                print("Failed to post data for shop visit ID: ${v.id}");
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error making API requests for shop visit ID: ${v.id} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing shop visit data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }
  Future<String> getLastid() async {
    var dbClient = await dbHelpershopvisit.db;
    List<Map> maps = await dbClient!.query(
      'shopVisit',
      columns: ['id'],
      orderBy: 'Id DESC',
      limit: 1,
    );
    if (maps.isEmpty) {
      // Handle the case when no records are found
      return "";
    }

    // Convert the orderId to a string and return
    return maps[0]['id'].toString();
  }

    Future<int> add(ShopVisitModel shopvisitModel) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.insert('shopVisit', shopvisitModel.toMap());
    }



    Future<int> update(ShopVisitModel shopvisitModel) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.update('shopVisit', shopvisitModel.toMap(),
          where: 'id=?', whereArgs: [shopvisitModel.id]);
    }

    Future<int> delete(int id) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.delete('shopVisit',
          where: 'id=?', whereArgs: [id]);
    }

  }