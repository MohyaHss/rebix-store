import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_model.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final idType = " INTEGER PRIMARY KEY AUTOINCREMENT ";
    final imageType = " TEXT ";
    final textType = " TEXT NOT NULL ";
    final dbPath =
        await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: (db , version){
      db.execute( ''' CREATE TABLE $productTable ( ${ProductFields.id} $idType , ${ProductFields.image} $imageType , ${ProductFields.productName} $textType, ${ProductFields.sellerName} $textType , ${ProductFields.price} $textType )'''
      );
    }
    );
  }


  Future<int?> insert(ProductModel productModel) async {
    final db = await instance.database;
    int id = await db.insert(productTable, productModel.toMap() , conflictAlgorithm: ConflictAlgorithm.replace,);
    return productModel.copy(id : id).id;
  }


  Future<ProductModel?> select(int id) async {
    final db = await instance.database;
    final maps = await db.query(productTable,
        columns: ProductFields.values,
        where: '${ProductFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return ProductModel.fromMap(maps.first);
    } else
      return null;
  }

  Future<List<ProductModel>?> selectAllProducts() async {
    final db = await instance.database;
    final result = await db.query(productTable);
    if(result.isNotEmpty){
       List<ProductModel> endResult = result.map((map) => ProductModel.fromMap(map)).toList();
       return endResult;
    }else {
      return null;
    }
  }

  Future<int> update(ProductModel product) async {
    final db = await instance.database;
    return db.update(productTable, product.toMap(),
        where: '${ProductFields.id} = ?', whereArgs: [product.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(productTable,
        where: '${ProductFields.id} = ?', whereArgs:[id] );
  }

  Future closeDB() async {
    final db = await instance.database;
    db.close();
  }
}
