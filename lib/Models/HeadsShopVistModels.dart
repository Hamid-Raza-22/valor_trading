import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

class HeadsShopVisitModel {
  dynamic? id;
  String? date;
  String? userId;
  String? shopName;
  String? bookerName;
  String? feedback;
  dynamic? address;
  dynamic city;
  dynamic bookerId;

  HeadsShopVisitModel({

    this.id,
    this.date,
    this.shopName,
    this.userId,
    this.bookerName,
    this.feedback,
    this.address,
    this.city,
    this.bookerId
  });

  factory HeadsShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    return HeadsShopVisitModel(
      id: json['id'],
      date: json['date'],
      shopName: json['shopName'],
      userId: json['userId'],
      bookerName: json['bookerName'],
      bookerId: json['bookerId'],

      city: json['city'],

      feedback: json['feedback'],

      address: json['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {

      'id': id,
      'date': date,
      'userId': userId,
      'shopName': shopName,
      'bookerName': bookerName,
      'bookerId': bookerId,

      'city': city,

      'feedback': feedback,

      'address': address
    };
  }
}