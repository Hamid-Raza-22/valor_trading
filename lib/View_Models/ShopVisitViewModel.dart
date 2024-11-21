import 'package:get/get.dart';
import '../Models/HeadsShopVistModels.dart';
import '../Models/ShopVisitModels.dart';
import '../Repositories/ShopVisitRepository.dart';

class ShopVisitViewModel extends GetxController{

  var allShopVisit = <ShopVisitModel>[].obs;
  ShopVisitRepository shopvisitRepository = ShopVisitRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllShopVisit();
  }

  fetchAllShopVisit() async{
    var shopvisit = await shopvisitRepository.getShopVisit();
    allShopVisit.value = shopvisit;
  }

  addShopVisit(ShopVisitModel shopvisitModel){
    shopvisitRepository.add(shopvisitModel);
    fetchAllShopVisit();
  }
  addHeadsShopVisit(HeadsShopVisitModel headsshopvisitModel){
    shopvisitRepository.addHeasdsShopVisits(headsshopvisitModel);
    fetchAllShopVisit();
  }

  Future<String> fetchLastShopVisitId() async{
    String shopvisit = await shopvisitRepository.getLastid();
    return shopvisit;
  }

  updateShopVisit(ShopVisitModel shopvisitModel){
    shopvisitRepository.update(shopvisitModel);
    fetchAllShopVisit();
  }

  deleteShopVisit(int id){
    shopvisitRepository.delete(id);
    fetchAllShopVisit();
  }
  postShopVisit(){
    shopvisitRepository.postShopVisitData();

  }
 postHeadsShopVisit(){
    shopvisitRepository.postHeadsShopVisitData();

  }

}