class BookerStatusModel {

  final dynamic bookerId;
  final dynamic name;
  final dynamic designation;
  final dynamic attendanceStatus;
  final dynamic city;

  BookerStatusModel({
    required this.bookerId,
    required this.name,
    required this.designation,
    required this.attendanceStatus,
    required this.city,
  });

  factory BookerStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return BookerStatusModel(
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
