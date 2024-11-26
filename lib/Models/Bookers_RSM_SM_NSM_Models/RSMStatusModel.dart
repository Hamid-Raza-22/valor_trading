class RSMStatusModel {

  final dynamic bookerId;
  final dynamic name;
  final dynamic designation;
  final dynamic attendanceStatus;
  final dynamic city;

  RSMStatusModel({
    required this.bookerId,
    required this.name,
    required this.designation,
    required this.attendanceStatus,
    required this.city,
  });

  factory RSMStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return RSMStatusModel(
      bookerId: json['user_id'],
      name: json['user_name'],
      designation: json['designation'],
      attendanceStatus: json['status'],
      city: json['city'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'user_id':bookerId,
      'user_name': name,
      'designation': designation,
      'status': attendanceStatus,
      'city': city,
    };
  }
}
