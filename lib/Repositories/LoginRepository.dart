import '../../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/LoginModel.dart';

class LoginRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<LoginModel>> getLogin() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('login', columns: ['user_id', 'password' , 'city' ,'user_name', 'designation' , 'brand' ,  'images' ,'RSM','RSM_ID','SM','SM_ID','NSM','NSM_ID']);
    List<LoginModel> login = [];

    for (int i = 0; i < maps.length; i++) {
      login.add(LoginModel.fromMap(maps[i]));
    }
    return login;
  }

  Future<int> add(LoginModel loginModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('login' , loginModel.toMap());
  }
  //
  // Future<int> update(LoginModel loginModel) async{
  //   var dbClient = await dbHelper.db;
  //   return await dbClient!.update('login', loginModel.toMap(),
  //       where: 'id=?', whereArgs: [loginModel.id] );
  // }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('login',
        where: 'user_id=?', whereArgs: [id] );
  }
  // Future<List<OwnerModel>> getShopNames() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query('login', columns: ['shop_name']);
  //
  //   // Extracting shop names from the list of maps
  //   List<OwnerModel> shopNames = maps.map((map) => map['shop_name'].toString()).cast<OwnerModel>().toList();
  //
  //   return shopNames;
  // }
  Future<List<LoginModel>> getShopName() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('login', columns: ['shop_name']);
    List<LoginModel> login = [];

    for (int i = 0; i < maps.length; i++) {
      login.add(LoginModel.fromMap(maps[i]));
    }
    return login;
  }
  Future<List<String>> getShopNames() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('login', columns: ['shop_name']);

    // Extracting shop names from the list of maps
    List<String> shopNames = maps.map((map) => map['shop_name'].toString()).toList();

    return shopNames;
  }
  Future<List<String>> getBookerNamesByRSMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      'login',
      where: 'RSM_ID = ?',
      whereArgs: [userId],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }Future<List<String>> getBookerNamesBySMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      'login',
      where: 'SM_ID = ?',
      whereArgs: [userId],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }
  Future<List<String>> getBookerNamesByNSMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      'login',
      where: 'NSM_ID = ?',
      whereArgs: [userId],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }

}


