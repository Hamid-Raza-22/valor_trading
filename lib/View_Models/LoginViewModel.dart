
import 'package:get/get.dart';



import '../Models/LoginModel.dart';
import '../Repositories/LoginRepository.dart';


class LoginViewModel extends GetxController{

  var allLogin = <LoginModel>[].obs;
  // var shopNames = <String>[].obs;
  var bookerNamesByRSMDesignation = <String>[].obs;
 var bookerNamesBySMDesignation = <String>[].obs;
 var bookerNamesByNSMDesignation = <String>[].obs;

  LoginRepository loginRepository = LoginRepository ();

  @override
  void onInit() {
    super.onInit();
    fetchAllLogin();
    // fetchShopNames();
    fetchBookerNamesByRSMDesignation();
    fetchBookerNamesBySMDesignation();
    fetchBookerNamesByNSMDesignation();
  }
  // fetchShopNames() async {
  //   var names = await loginRepository.getShopNames();
  //   shopNames.value = names;
  // }
  fetchBookerNamesByRSMDesignation() async {
    var rsmnames = await loginRepository.getBookerNamesByRSMDesignation();
    bookerNamesByRSMDesignation.value = rsmnames;

  }
  fetchBookerNamesBySMDesignation() async {

     var smnames = await loginRepository.getBookerNamesBySMDesignation();
    bookerNamesBySMDesignation.value = smnames;

  }
  fetchBookerNamesByNSMDesignation() async {

     var nsmnames = await loginRepository.getBookerNamesByNSMDesignation();
    bookerNamesByNSMDesignation.value = nsmnames;
  }
  fetchAllLogin() async {
    var login = await loginRepository.getLogin();
    allLogin.value= login;
  }


  addLogin(LoginModel loginModel){
    loginRepository.add(loginModel);
  }

  // updateShop(LoginModel loginModel){
  //   loginRepository.update(loginModel);
  //   // fetchAllShop();
  //
  // }

  deleteShop(int id){
    loginRepository .delete(id);
    fetchAllLogin();

  }

}






