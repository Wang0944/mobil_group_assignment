import 'package:floor/floor.dart';


@Entity(tableName: 'flights') //must be capital E.
class flights{
  static int ID = 1;

  @primaryKey
  final int id;
  final String departure;
  final String destination;

  final String departureTime;

  final String arriveTime;

  flights(this.id, this.departure, this.destination, this.departureTime, this.arriveTime,){

    if(id > ID) {
      ID = id + 1;
    }


  }
}