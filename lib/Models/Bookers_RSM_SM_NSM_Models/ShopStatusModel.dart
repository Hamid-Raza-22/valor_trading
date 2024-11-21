class ShopStatusModel {
  final dynamic name;
  final dynamic address;
  //final dynamic attendanceStatus;
  final dynamic city;

  ShopStatusModel({
    required this.name,
    required this.address,
    //required this.attendanceStatus,
    required this.city,
  });

  factory ShopStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return ShopStatusModel(
      name: json['shop_name'],
      address: json['shop_address'],
      //attendanceStatus: json['status'],
      city: json['city'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'shop_name': name,
      'shop_address': address,
      //'status': attendanceStatus,
      'city': city,
    };
  }
}
