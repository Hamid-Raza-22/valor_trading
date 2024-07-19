


import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';
import '../API/ApiServices.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/AttendanceModel.dart';


class AttendanceRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceModel>> getAttendance() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('attendance', columns: ['id', 'date' , 'timeIn' , 'userId' , 'latIn' , 'lngIn','bookerName','city','designation' ]);
    List<AttendanceModel> attendance = [];

    for (int i = 0; i < maps.length; i++) {
      attendance.add(AttendanceModel.fromMap(maps[i]));
    }
    return attendance;
  }

  Future<void> postAttendanceTable() async {
    var db = await dbHelper.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM attendance');

      if (products.isNotEmpty) {
        for (var i in products) {
          if (kDebugMode) {
            print("Posting attendance for ${i['id']}");
          }

          AttendanceModel v = AttendanceModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            timeIn: i['timeIn'].toString(),
            latIn: i['latIn'].toString(),
            lngIn: i['lngIn'].toString(),
            bookerName: i['bookerName'].toString(),
            city: i['city'].toString(),
            designation: i['designation'].toString(),
          );

          try {
            final results = await Future.wait([
              api.masterPost(v.toMap(), attendanceApi),
              // api.masterPost(v.toMap(), '$Alt_IP_Address/attendance/post/'),
            ]);

            if (results[0] == true) {
              if (kDebugMode) {
                print('Successfully posted attendance for ID: ${i['id']}');
              }
              await db.rawDelete("DELETE FROM attendance WHERE id = ?", [i['id']]);
            } else {
              if (kDebugMode) {
                print('Failed to post attendance for ID: ${i['id']}');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error posting attendance for ID: ${i['id']} - $e");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processing attendance data: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }  // Future<List<AttendanceModel>> getShopName() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query('shop', columns: ['id', 'shopName']);
  //   List<AttendanceModel> shop = [];
  //
  //   for (int i = 0; i < maps.length; i++) {
  //     shop.add(AttendanceModel.fromMap(maps[i]));
  //   }
  //   return shop;
  // }

  //
  // Future<String> getLastid() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query(
  //     'shop',
  //     columns: ['id'],
  //     orderBy: 'Id DESC',
  //     limit: 1,
  //   );
  //   if (maps.isEmpty) {
  //     // Handle the case when no records are found
  //     return "";
  //   }
  //
  //   // Convert the orderId to a string and return
  //   return maps[0]['id'].toString();
  // }


  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('attendanceOut', columns: ['id', 'date' , 'timeOut' ,'totalTime', 'userId' , 'latOut', 'lngOut','totalDistance', 'posted']);
    List<AttendanceOutModel> attendanceout = [];

    for (int i = 0; i < maps.length; i++) {
      attendanceout.add(AttendanceOutModel.fromMap(maps[i]));
    }
    return attendanceout;
  }

  Future<void> postAttendanceOutTable() async {
    var db = await dbHelper.db;
    final ApiServices api = ApiServices();

    try {
      PostingStatus.isPosting.value = true; // Set posting status to true

      final products = await db!.rawQuery('SELECT * FROM attendanceOut');

      if (products.isNotEmpty || products != null) {
        for (var i in products) {
          if (kDebugMode) {
            print("FIRST ${i.toString()}");
          }

          AttendanceOutModel v = AttendanceOutModel(
              id: i['id'].toString(),
              date: i['date'].toString(),
              userId: i['userId'].toString(),
              timeOut: i['timeOut'].toString(),
              totalTime: i['totalTime'].toString(),
              latOut: i['latOut'].toString(),
              lngOut: i['lngOut'].toString(),
              totalDistance: i['totalDistance']?.toString() ?? '0.0'
          );
          var result1 = await api.masterPost(v.toMap(), attendanceOutApi);
          // var result1 = await api.masterPost(v.toMap(), 'https://webhook.site/3f874f5d-2d23-493b-a3a0-855f77ded7fb');
          // var result = await api.masterPost(v.toMap(), '$Alt_IP_Address/attendanceout/post/',);

          if (result1 == true) {
            if (kDebugMode) {
              print('successfully post');
            }
            await db.rawDelete("DELETE FROM attendanceOut WHERE id = '${i['id']}'");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      PostingStatus.isPosting.value = false; // Set posting status to false
    }
  }
  Future<int> addOut(AttendanceOutModel attendanceoutModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('attendanceOut' , attendanceoutModel.toMap());
  }

  Future<int> add(AttendanceModel attendanceModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('attendance' , attendanceModel.toMap());
  }

  Future<int> update(AttendanceModel attendanceModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.update('attendance', attendanceModel.toMap(),
        where: 'id= ?', whereArgs: [attendanceModel.id] );
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('attendance',
        where: 'id=?', whereArgs: [id] );
  }


}



