
import 'package:get/get.dart';

import '../Models/OwnerModel.dart';
import '../Repositories/OrderRepository/OwnerRepository.dart';


class OwnerViewModel extends GetxController{

  var allOwner = <OwnerModel>[].obs;
  var shopNames = <String>[].obs;
  var shopNamesbycites = <String>[].obs;

  OwnerRepository ownerRepository = OwnerRepository();

  @override
  void onInit() {
    super.onInit();
    fetchAllOwner();
    fetchShopNames();
    fetchShopNamesbycities();
  }
  fetchShopNames() async {
    var names = await ownerRepository.getShopNames();
    shopNames.value = names;
  }
  fetchShopNamesbycities() async {
    var names = await ownerRepository.getShopNamesForCity();
    shopNamesbycites.value = names;
  }
  fetchAllOwner() async {
    var owner = await ownerRepository.getOwner();
    allOwner.value= owner;
  }


  addOwner(OwnerModel ownerModel){
    ownerRepository.add(ownerModel);
  }

  updateShop(OwnerModel ownerModel){
    ownerRepository.update(ownerModel);
    // fetchAllShop();

  }

  deleteShop(int id){
    ownerRepository.delete(id);
    fetchAllOwner();

  }

}






