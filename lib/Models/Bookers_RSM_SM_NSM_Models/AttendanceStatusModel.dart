class AttendanceStatusModel {
  final dynamic date;
  final dynamic timeIn;
  final dynamic timeOut;
  final dynamic totalTime;
  final dynamic totalDistance;

  AttendanceStatusModel({
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.totalTime,
    required this.totalDistance,
  });

  factory AttendanceStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return AttendanceStatusModel(
      date: json['attendance_date'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      totalTime: json['total_time'],
      totalDistance: json['total_distance'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'attendance_date':date,
      'time_in': timeIn,
      'time_out': timeOut,
      'total_time': totalTime,
      'total_distance': totalDistance,
    };
  }
}

