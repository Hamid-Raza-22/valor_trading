class ReturnFormDetailsModel {
  dynamic? id;
  dynamic? returnFormId;
  String? productName;
 dynamic? bookerId;
 //dynamic? returnAmount;

  dynamic? reason;
  dynamic? quantity;
  ReturnFormDetailsModel({
    this.id,
    this.returnFormId,
    this.productName,
    this.bookerId,
    this.reason,
    this.quantity,
   // this.returnAmount

  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return ReturnFormDetailsModel(
      id: json['id'],
      returnFormId: json['returnFormId'],
      productName: json['productName'],
      bookerId: json['bookerId'],
      reason: json['reason'],
      quantity: json['quantity'],
     // returnAmount: json['returnAmount']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'returnFormId':returnFormId,
      'productName': productName,
      'bookerId':bookerId,
      'reason': reason,
      'quantity': quantity,
     //'returnAmount':returnAmount
    };
  }
}