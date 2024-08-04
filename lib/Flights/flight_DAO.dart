import 'package:floor/floor.dart';
import 'flights.dart';

@dao
abstract class flight_DAO{

  @insert
  Future<void> insertFlight(flights trip);

  @delete
  Future<void> deleteFlight(flights trip);

  @update
  Future<void> updateFlight(flights trip);

  @Query('SELECT * from flights')
  Future< List< flights > > getFlights();

}