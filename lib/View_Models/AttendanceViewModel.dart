import 'package:get/get.dart';
import '../Models/AttendanceModel.dart';
import '../Repositories/AttendanceRepository.dart';

class AttendanceViewModel extends GetxController{

  var allAttendance = <AttendanceModel>[].obs;
  AttendanceRepository attendanceRepository = AttendanceRepository();

  var allAttendanceOut = <AttendanceOutModel>[].obs;
  AttendanceRepository attendanceOutRepository = AttendanceRepository();


  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
    fetchAllAttendanceOut();
  }

  fetchAllAttendance() async {
    var attendance = await attendanceRepository.getAttendance();
    allAttendance.value= attendance;

  }

  fetchAllAttendanceOut() async {
    var attendanceout = await attendanceRepository.getAttendanceOut();
    allAttendanceOut.value= attendanceout;

  }

  addAttendanceOut(AttendanceOutModel attendanceoutModel){
    attendanceRepository.addOut(attendanceoutModel);
    fetchAllAttendanceOut();

  }

  putAttendance(AttendanceModel attendanceModel){
    attendanceRepository.update(attendanceModel);
    fetchAllAttendance();

  }

  addAttendance(AttendanceModel attendanceModel){
    attendanceRepository.add(attendanceModel);
    fetchAllAttendance();
    //var dummy=fetchAllShop();
    // print (dummy);

  }

  deleteAttendance(int id){
    attendanceRepository.delete(id);
    fetchAllAttendance();

  }

  postAttendance(){
    attendanceRepository.postAttendanceTable();
  }

  postAttendanceOut(){
    attendanceRepository.postAttendanceOutTable();
  }
}

