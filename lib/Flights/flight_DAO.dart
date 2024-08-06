import 'package:floor/floor.dart';
import 'flights.dart';

@dao
abstract class flight_DAO{

  @insert
  Future<void> insertFlight(flights flight);

  @delete
  Future<void> deleteFlight(flights flight);

  @update
  Future<void> updateFlight(flights flight);

  @Query('SELECT * from flights')
  Future< List< flights > > getFlights();

}