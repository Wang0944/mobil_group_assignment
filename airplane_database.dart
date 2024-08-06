import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
part 'airplane_database.g.dart';

// Entity
@Entity(tableName: 'airplanes')
class Airplane {
  @primaryKey
  final int id;
  String type;
  int passengers;
  double maxSpeed;
  double distance;
  static int ID = 1;

  Airplane(this.id, this.type, this.passengers, this.maxSpeed, this.distance) {
    if(id >= ID) {
      ID = id+1;
    }
  }

}

// DAO
@dao
abstract class AirplaneDao {
  @Query('SELECT * FROM airplanes')
  Future<List<Airplane>> findAllAirplanes();

  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<void> deleteAirplane(Airplane airplane);

  //Query:
  @Query('Select * from airplanes')
  Future<List<Airplane>> getAllAirplanes();
}

// Database
@Database(version: 1, entities: [Airplane])
abstract class AppDatabase extends FloorDatabase {
  AirplaneDao get getAirplaneDao;
}