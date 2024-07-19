
import 'dart:convert';
import 'dart:typed_data';

class OwnerModel {
  dynamic id;
  String? shop_name;
  String? city;
  String? created_date;
  String? shop_address;
  String? owner_name;

  String? phone_no;

  dynamic user_id;
  Uint8List? images;

  OwnerModel({
    this.id,
    this.shop_name,
    this.city,
    this.created_date,
    this.shop_address,
    this.owner_name,

    this.phone_no,
    this.images,

    this.user_id
  });

  factory OwnerModel.fromMap(Map<dynamic, dynamic> json) {
    //var location = (json['location'] ?? '').split(',');
    return OwnerModel(
      id: json['id'],
      shop_name: json['shop_name'],
      city: json['city'],
      created_date: json['created_date'],
      shop_address: json['shop_address'],
      owner_name: json['owner_name'],
      phone_no: json['phone_no'],
      user_id: json['user_id'],
      images: json['images'] != null && json['images'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['images'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shop_name,
      'city': city,
      'created_date': created_date,
      'shop_address': shop_address,
      'owner_name': owner_name,
      'phone_no': phone_no,
      'user_id': user_id,
      'images':  images != null ? base64Encode(images!) : null
    };
  }
}
