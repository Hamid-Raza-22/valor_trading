import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';
import '../Databases/DBHelper.dart';

import '../Models/ShopModel.dart';
import 'package:path_provider/path_provider.dart';

import '../API/ApiServices.dart';
import '../API/Globals.dart';


class ShopRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<ShopModel>> getShop() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: ['id', 'shopName' , 'city' ,'date', 'shopAddress' , 'ownerName' , 'ownerCNIC' , 'phoneNo' , 'alternativePhoneNo', 'latitude', 'longitude','userId','address','posted']);
    List<ShopModel> shop = [];

    for (int i = 0; i < maps.length; i++) {
      shop.add(ShopModel.fromMap(maps[i]));
    }
    return shop;
  }

  Future<void> postShopTable() async {
    var dbClient = await dbHelper.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final List<Map<String, dynamic>> records = await dbClient!.query('shop');

      for (var record in records) {
        if (kDebugMode) {
          print(record.toString());
        }
      }

      final products = await dbClient.rawQuery('SELECT * FROM shop');
      if (products.isNotEmpty) {
        for (var i in products) {
          if (kDebugMode) {
            print("FIRST ${i.toString()}");
          }

          ShopModel v = ShopModel(
            id: "${i['id']}",
            shopName: i['shopName'].toString(),
            city: i['city'].toString(),
            date: i['date'].toString(),
            shopAddress: i['shopAddress'].toString(),
            ownerName: i['ownerName'].toString(),
            ownerCNIC: i['ownerCNIC'].toString(),
            phoneNo: i['phoneNo'].toString(),
            alternativePhoneNo: i['alternativePhoneNo'].toString(),
            latitude: i['latitude'].toString(),
            longitude: i['longitude'].toString(),
            userId: i['userId'].toString(),
            address: i['address'].toString(),
            // body: i['body'] != null && i['body'].toString().isNotEmpty
            //     ? Uint8List.fromList(base64Decode(i['body'].toString()))
            //     : Uint8List(0),
          );

          // if (kDebugMode) {
          //   print("Image Path from Database: ${i['body']}");
          // }
          if (kDebugMode) {
            print("lat:${i['latitude']}");
          }

          // Uint8List imageBytes;
          // final directory = await getApplicationDocumentsDirectory();
          // final filePath = File('${directory.path}/captured_image.jpg');
          // if (filePath.existsSync()) {
          //   List<int> imageBytesList = await filePath.readAsBytes();
          //   imageBytes = Uint8List.fromList(imageBytesList);
          // } else {
          //   if (kDebugMode) {
          //     print("File does not exist at the specified path: ${filePath.path}");
          //   }
          //   continue; // Skip to the next iteration if the file doesn't exist
          // }

          if (kDebugMode) {
            print("Making API request for shop ID: ${v.id}");
          }

          bool result1 = await api.masterPost(
            v.toMap(),
            addShopApi,
           // imageBytes,
          );
          // await api.masterPostWithImage(v.toMap(), '$Alt_IP_Address/addshops/post/', imageBytes,);

          if (result1 == true) {
            await dbClient.rawDelete('DELETE FROM shop WHERE id = ?', [i['id']]);
            if (kDebugMode) {
              print("Successfully posted data for shop ID: ${v.id}");
            }
          } else {
            if (kDebugMode) {
              print("Failed to post data for shop ID: ${v.id}");
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
  Future<int> add(ShopModel shopModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('shop' , shopModel.toMap());
  }

  Future<int> update(ShopModel shopModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.update('shop', shopModel.toMap(),
        where: 'id=?', whereArgs: [shopModel.id] );
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('shop',
        where: 'id=?', whereArgs: [id] );
  }
  Future<List<ShopModel>> getShopNames() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: ['shopName']);

    // Extracting shop names from the list of maps
    List<ShopModel> shopNames = maps.map((map) => map['shopName'].toString()).cast<ShopModel>().toList();

    return shopNames;
  }
  Future<List<ShopModel>> getShopName() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: ['shopName']);
    List<ShopModel> shop = [];

    for (int i = 0; i < maps.length; i++) {
      shop.add(ShopModel.fromMap(maps[i]));
    }
    return shop;
  }
  Future<String> getLastid() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query(
      'shop',
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

}



