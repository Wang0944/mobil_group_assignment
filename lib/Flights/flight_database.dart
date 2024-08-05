import 'package:floor/floor.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'flights.dart';
import 'flight_DAO.dart';
part 'flight_database.g.dart';


@Database(version: 1, entities: [flights])
abstract class flight_database extends FloorDatabase{
  flight_DAO get flightDAO;
}