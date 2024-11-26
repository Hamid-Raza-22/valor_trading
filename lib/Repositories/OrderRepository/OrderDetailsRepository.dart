
import 'package:flutter/foundation.dart';
import 'package:metaxperts_valor_trading_dynamic_apis/post_apis/Post_apis.dart';
import 'package:mutex/mutex.dart';
import 'package:synchronized/extension.dart';

import '../../API/ApiServices.dart';
import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/OrderModels/OrderDetailsModel.dart';

class OrderDetailsRepository {

  DBHelper dbHelperOrderDetails = DBHelper();


  Future<List<OrderDetailsModel>> getOrderDetails() async {
    var dbClient = await dbHelperOrderDetails.db;
    List<Map> maps = await dbClient!.query('order_details', columns: ['id','order_master_id', 'productName', 'quantity', 'price', 'amount','userId','posted']);
    List<OrderDetailsModel> orderdetails = [];
    for (int i = 0; i < maps.length; i++) {

      orderdetails.add(OrderDetailsModel.fromMap(maps[i]));
    }
    return orderdetails;
  }
  Future<bool> postOrderDetails() async {
    final Mutex mutex = Mutex();
    return mutex.synchronized(() async {
      var db = await dbHelper.db;
      final ApiServices api = ApiServices();

      try {
        final List<Map<String, dynamic>> records = await db!.query('order_details');

        for (var record in records) {
          if (kDebugMode) {
            print(record.toString());
          }
        }

        final products = await db.rawQuery('SELECT * FROM order_details WHERE posted = 0');
        if (products.isNotEmpty) {
          for (var i in products) {
            if (kDebugMode) {
              print("Posting order details for ${i['id']}");
            }

            OrderDetailsModel v = OrderDetailsModel(
              id: i['id'].toString(),
              orderMasterId: i['order_master_id'].toString(),
              productName: i['productName'].toString(),
              price: i['price'].toString(),
              quantity: i['quantity'].toString(),
              amount: i['amount'].toString(),
              userId: i['userId'].toString(),
            );

            try {
              bool result = await api.masterPost(
                v.toMap(),
                  'http://103.149.32.30:4000/api/order-details'
               // orderDetailsApi,
              );

              if (result==true) {
                if (kDebugMode) {
                  print('Successfully posted order details for ID: ${i['id']}');
                }
                await db.rawUpdate(
                    'UPDATE order_details SET posted = 1 WHERE id = ?', [i['id']]
                );
              } else {
                if (kDebugMode) {
                  print('Failed to post order details for ID: ${i['id']}');
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print("Error posting order details for ID: ${i['id']} - $e");
              }
            }
          }
          return true;
        } else {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error processing order details data: $e");
        }
        return false;
      }
    });
  }


  // Future<bool> postOrderDetails() async {
  //   if (PostingStatus.isPosting.value) {
  //     // If posting is already in progress, do not start another process
  //     return false;
  //   }
  //
  //   var db = await dbHelper.db;
  //   final ApiServices api = ApiServices();
  //
  //   try {
  //     PostingStatus.isPosting.value = true; // Set posting status to true
  //
  //     final List<Map<String, dynamic>> records = await db!.query('order_details');
  //
  //     for (var record in records) {
  //       if (kDebugMode) {
  //         print(record.toString());
  //       }
  //     }
  //
  //     final products = await db.rawQuery('SELECT * FROM order_details WHERE posted = 0');
  //     if (products.isNotEmpty) {
  //       List<int> successfullyPostedIds = [];
  //
  //       for (var i in products) {
  //         if (kDebugMode) {
  //           print("Posting order details for ${i['id']}");
  //         }
  //
  //         OrderDetailsModel v = OrderDetailsModel(
  //           id: i['id'].toString(),
  //           orderMasterId: i['order_master_id'].toString(),
  //           productName: i['productName'].toString(),
  //           price: i['price'].toString(),
  //           quantity: i['quantity'].toString(),
  //           amount: i['amount'].toString(),
  //           userId: i['userId'].toString(),
  //         );
  //
  //         try {
  //           bool results = await api.masterPost(
  //             v.toMap(),
  //             orderDetailsApi,
  //           );
  //
  //           if (results == true) {
  //             if (kDebugMode) {
  //               print('Successfully posted order details for ID: ${i['id']}');
  //             }
  //             successfullyPostedIds.add(i['id'] as int);
  //           } else {
  //             if (kDebugMode) {
  //               print('Failed to post order details for ID: ${i['id']}');
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print("Error posting order details for ID: ${i['id']} - $e");
  //           }
  //         }
  //       }
  //
  //       if (successfullyPostedIds.isNotEmpty) {
  //         String ids = successfullyPostedIds.join(',');
  //         await db.rawUpdate(
  //           'UPDATE order_details SET posted = 1 WHERE id IN ($ids)',
  //         );
  //       }
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error processing order details data: $e");
  //     }
  //     return false;
  //   } finally {
  //     PostingStatus.isPosting.value = false; // Set posting status to false
  //   }
  // }
  // Future<bool> postOrderDetails() async {
  //   var db = await dbHelper.db;
  //   final ApiServices api = ApiServices();
  //
  //   try {
  //     PostingStatus.isPosting.value = true; // Set posting status to true
  //
  //     final List<Map<String, dynamic>> records = await db!.query('order_details');
  //
  //     for (var record in records) {
  //       if (kDebugMode) {
  //         print(record.toString());
  //       }
  //     }
  //
  //     final products = await db.rawQuery('SELECT * FROM order_details WHERE posted = 0');
  //     if (products.isNotEmpty) {
  //       List<int> successfullyPostedIds = [];
  //
  //       for (var i in products) {
  //         if (kDebugMode) {
  //           print("Posting order details for ${i['id']}");
  //         }
  //
  //         OrderDetailsModel v = OrderDetailsModel(
  //           id: i['id'].toString(),
  //           orderMasterId: i['order_master_id'].toString(),
  //           productName: i['productName'].toString(),
  //           price: i['price'].toString(),
  //           quantity: i['quantity'].toString(),
  //           amount: i['amount'].toString(),
  //           userId: i['userId'].toString(),
  //         );
  //
  //         try {
  //           bool results = await api.masterPost(
  //             v.toMap(),
  //             orderDetailsApi,
  //           );
  //
  //           if (results == true) {
  //             if (kDebugMode) {
  //               print('Successfully posted order details for ID: ${i['id']}');
  //             }
  //             successfullyPostedIds.add(i['id'] as int);
  //           } else {
  //             if (kDebugMode) {
  //               print('Failed to post order details for ID: ${i['id']}');
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print("Error posting order details for ID: ${i['id']} - $e");
  //           }
  //         }
  //       }
  //
  //       if (successfullyPostedIds.isNotEmpty) {
  //         String ids = successfullyPostedIds.join(',');
  //         await db.rawUpdate(
  //           'UPDATE order_details SET posted = 1 WHERE id IN ($ids)',
  //         );
  //       }
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error processing order details data: $e");
  //     }
  //     return false;
  //   } finally {
  //     PostingStatus.isPosting.value = false; // Set posting status to false
  //   }
  // }
   // Return true if posting is successful



  Future<int> add(OrderDetailsModel orderdetailsModel) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.insert('order_details', orderdetailsModel.toMap());
  }

  Future<int> update(OrderDetailsModel orderdetailsModel) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.update('order_details', orderdetailsModel.toMap(),
        where: 'id = ?', whereArgs: [orderdetailsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.delete('order_details',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<GetOrderDetailsModel>> getOrderDetailsProductNamesByOrder(String order_no) async {
    var dbClient = await dbHelperOrderDetails.db;
    List<Map> maps = await dbClient!.query(
      'orderDetailsData',
      columns: ['order_no', 'product_name'],
      where: 'order_no = ?',
      whereArgs: [selectedorderno],
    );
    List<GetOrderDetailsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(GetOrderDetailsModel.fromMap(maps[i]));
    }
    return products;
  }
}