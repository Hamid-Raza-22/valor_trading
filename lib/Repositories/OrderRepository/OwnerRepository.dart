import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';

import '../../API/Globals.dart';
import '../../Databases/DBHelper.dart';
import '../../Models/OwnerModel.dart';




class OwnerRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<OwnerModel>> getOwner() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('ownerData', columns: ['id', 'shop_name' , 'city' ,'created_date', 'shop_address' , 'owner_name' ,  'phone_no' ,'user_id','images']);
    List<OwnerModel> owner = [];

    for (int i = 0; i < maps.length; i++) {
      owner.add(OwnerModel.fromMap(maps[i]));
    }
    return owner;
  }

  Future<int> add(OwnerModel ownerModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('ownerData' , ownerModel.toMap());
  }

  Future<int> update(OwnerModel ownerModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.update('ownerData', ownerModel.toMap(),
        where: 'id=?', whereArgs: [ownerModel.id] );
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('ownerData',
        where: 'id=?', whereArgs: [id] );
  }
  // Future<List<OwnerModel>> getShopNames() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query('ownerData', columns: ['shop_name']);
  //
  //   // Extracting shop names from the list of maps
  //   List<OwnerModel> shopNames = maps.map((map) => map['shop_name'].toString()).cast<OwnerModel>().toList();
  //
  //   return shopNames;
  // }
  Future<List<OwnerModel>> getShopName() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('ownerData', columns: ['shop_name']);
    List<OwnerModel> owner = [];

    for (int i = 0; i < maps.length; i++) {
      owner.add(OwnerModel.fromMap(maps[i]));
    }
    return owner;
  }
  Future<List<String>> getShopNames() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('ownerData', columns: ['shop_name']);

    // Extracting shop names from the list of maps
    List<String> shopNames = maps.map((map) => map['shop_name'].toString()).toList();

    return shopNames;
  }
  Future<List<String>> getShopNamesForCity() async {
    var dbClient = await dbHelper.db;

      final List<Map<String, dynamic>> shopNames = await dbClient!.query(
        'ownerData',
        where: 'city = ?',
        whereArgs: [userCitys],
      );
      return shopNames.map((map) => map['shop_name'] as String).toList();

  }
}



