import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';

import 'package:path_provider/path_provider.dart';

import '../API/ApiServices.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/LocationModel.dart';

class LocationRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<LocationModel>> getLocation() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('location', columns: [
      'id',
      'date',
      'fileName',
      'userId',
      'userName',
      'totalDistance',
      'body',
      'posted'
    ]);
    List<LocationModel> location = [];

    for (int i = 0; i < maps.length; i++) {
      location.add(LocationModel.fromMap(maps[i]));
    }
    return location;
  }

  Future<void> postLocationData() async {
    var db = await dbHelper.db;
    final ApiServices api = ApiServices();

    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final filePath = File('${downloadDirectory?.path}/track$date.gpx');

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM location');
      await db.rawQuery('VACUUM');

      if (products.isNotEmpty) {
        for (Map<dynamic, dynamic> i in products) {
          if (kDebugMode) {
            print("FIRST $i");
          }

          LocationModel v = LocationModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            userName: i['userName'].toString(),
            fileName: i['fileName'].toString(),
            totalDistance: i['totalDistance'].toString(),
            body: i['body'] != null && i['body'].toString().isNotEmpty
                ? Uint8List.fromList(base64Decode(i['body'].toString()))
                : Uint8List(0),
          );

          if (kDebugMode) {
            print("Image Path from Database: ${i['body']}");
          }

          Uint8List gpxBytes;
          if (filePath.existsSync()) {
            List<int> imageBytesList = await filePath.readAsBytes();
            gpxBytes = Uint8List.fromList(imageBytesList);
            if (gpxBytes.isEmpty) {
              if (kDebugMode) {
                print("File is empty at the specified path: ${filePath.path}");
              }
            }
          } else {
            if (kDebugMode) {
              print("File does not exist at the specified path: ${filePath.path}");
            }
            gpxBytes = Uint8List(0); // Use an empty Uint8List if the file does not exist
          }

          if (kDebugMode) {
            print("Making API request for location data ID: ${v.id}");
          }

          try {
            final results = await Future.wait([
              api.masterPostWithGPX(
                v.toMap(),
                locationApi,
                gpxBytes,
              ),
              // api.masterPostWithGPX(v.toMap(), 'https://apex.oracle.com/pls/apex/metaxpertss/location/post/', gpxBytes)
            ]);

            if (results[0] == true) {
              await db.rawDelete("DELETE FROM location WHERE id = '${i['id']}'");
              if (kDebugMode) {
                print("Successfully posted data for location ID: ${v.id}");
              }
            } else {
              if (kDebugMode) {
                print("Failed to post data for location ID: ${v.id}");
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error posting location data for ID: ${i['id']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing location data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }
  // Future<void> postlocationdata() async {
  //   var db = await dbHelper.db;
  //   final ApiServices api = ApiServices();
  //
  //   final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  //   final downloadDirectory = await getDownloadsDirectory();
  //   final filePath = File('${downloadDirectory?.path}/track$date.gpx');
  //
  //
  //
  //   try {
  //     final products = await db!.rawQuery('SELECT * FROM location WHERE posted = 0');
  //     await db.rawQuery('VACUUM');
  //
  //     if (products.isNotEmpty) {
  //       // Check if the table is not empty
  //       await db.transaction((txn) async {
  //         for (Map<dynamic, dynamic> i in products) {
  //           if (kDebugMode) {
  //             print("FIRST $i");
  //           }
  //
  //           LocationModel v = LocationModel(
  //             id: i['id'].toString(),
  //             date: i['date'].toString(),
  //             userId: i['userId'].toString(),
  //             userName: i['userName'].toString(),
  //             fileName: i['fileName'].toString(),
  //               totalDistance:i['totalDistance']?.toString()??'0.0',
  //             body: i['body'] != null && i['body'].toString().isNotEmpty
  //                 ? Uint8List.fromList(base64Decode(i['body'].toString()))
  //                 : Uint8List(0),
  //           );
  //
  //           // Print image path before trying to create the file
  //           if (kDebugMode) {
  //             print("Image Path from Database: ${i['body']}");
  //           }
  //
  //           Uint8List gpxBytes;
  //           if (filePath.existsSync()) {
  //             // File exists, proceed with reading the file
  //             List<int> imageBytesList = await filePath.readAsBytes();
  //             gpxBytes = Uint8List.fromList(imageBytesList);
  //           } else {
  //             if (kDebugMode) {
  //               print("File does not exist at the specified path: ${filePath.path}");
  //             }
  //             continue; // Skip to the next iteration if the file doesn't exist
  //           }
  //
  //           // Print information before making the API request
  //           if (kDebugMode) {
  //             print("Making API request for shop visit ID: ${v.id}");
  //           }
  //
  //           var result1 = await api.masterPostWithGPX(v.toMap(), 'http://103.149.32.30:8080/ords/metaxperts/location/post/', gpxBytes);
  //           var result = await api.masterPostWithGPX(v.toMap(), 'https://apex.oracle.com/pls/apex/metaxpertss/location/post/', gpxBytes);
  //
  //           if (result == true && result1 == true) {
  //             await txn.rawUpdate(
  //                 "UPDATE location SET posted = 1 WHERE id = ?", [i['id']]);
  //             if (kDebugMode) {
  //               print("Successfully posted data for shop visit ID: ${v.id}");
  //             }
  //           } else {
  //             if (kDebugMode) {
  //               print("Failed to post data for shop visit ID: ${v.id}");
  //             }
  //           }
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error processing shop visit data: $e");
  //     }
  //   }
  // }


  Future<int> add(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('location', locationModel.toMap());
  }

  Future<int> update(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient!.update('location', locationModel.toMap(),
        where: 'id= ?', whereArgs: [locationModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('location', where: 'id=?', whereArgs:[id]);
    }
}