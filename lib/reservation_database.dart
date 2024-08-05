import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

part 'reservation_database.g.dart'; // the generated code will be there

@Entity(tableName: 'reservations')
class Reservation {
  @primaryKey
  final int? id;
  final String name;
  final String customerName;
  final String flightDetails;
  final String departureCity;
  final String destinationCity;
  final DateTime departureTime;
  final DateTime arrivalTime;

  Reservation({
    this.id,
    required this.name,
    required this.customerName,
    required this.flightDetails,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });
}

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM reservations')
  Future<List<Reservation>> findAllReservations();

  @insert
  Future<void> insertReservation(Reservation reservation);

  @update
  Future<void> updateReservation(Reservation reservation);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Reservation])
abstract class AppDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
}

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
