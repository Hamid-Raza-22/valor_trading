class OrderDetailsModel {
  dynamic? id;
  dynamic? orderMasterId;
  String? productName;
  dynamic? amount;
  dynamic? price;
  dynamic? quantity;
  dynamic? userId;
  dynamic detailsDate;


  OrderDetailsModel({
    this.id,
    this.orderMasterId,
    this.productName,
    this.amount,
    this.price,
    this.quantity,
    this.userId,
    this.detailsDate

  });

  factory OrderDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return OrderDetailsModel(
      id: json['id'],
      orderMasterId: json['order_master_id'],
      productName: json['productName'],
      amount: json['amount'],
      price: json['price'],
      quantity: json['quantity'],
      userId: json['userId'],
      detailsDate: json['details_date']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_master_id':orderMasterId,
      'productName': productName,
      'amount': amount,
      'price': price,
      'quantity': quantity,
      'userId': userId,
      'details_date': detailsDate};
  }
}

class GetOrderDetailsModel {
  dynamic? order_no;
  String? product_name;
  dynamic detailsDate;



  GetOrderDetailsModel({
    this.order_no,
    this.product_name,
    this.detailsDate

  });

  factory GetOrderDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return GetOrderDetailsModel(
      order_no: json['order_no'],
      product_name: json['product_name'],
        detailsDate: json['details_date']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_no': order_no,
      'product_name': product_name,
      'details_date': detailsDate

    };
  }
}