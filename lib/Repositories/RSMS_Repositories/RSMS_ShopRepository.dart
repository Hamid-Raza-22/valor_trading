import '../../Databases/DBHelper.dart';
import '../../Models/ShopModel.dart';

class RSMS_ShopRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<ShopModel>> getShop() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('shop', columns: [
      'id',
      'shopName',
      'city',
      'date',
      'shopAddress',
      'ownerName',
      'ownerCNIC',
      'phoneNo',
      'alternativePhoneNo',
      'latitude',
      'longitude',
      'userId',
      'address',
      'posted'
    ]);
    List<ShopModel> shop = [];

    for (int i = 0; i < maps.length; i++) {
      shop.add(ShopModel.fromMap(maps[i]));
    }
    return shop;
  }
}
