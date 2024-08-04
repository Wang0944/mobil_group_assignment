import 'package:floor/floor.dart';


@Entity(tableName: 'flights')
class flights{
  static int ID = 1;

  @primaryKey
  final int id;
  final String departingFrom;
  final String arrivingTo;

  final String departTime;

  final String arriveTime;

  flights(this.id, this.departingFrom, this.arrivingTo, this.departTime, this.arriveTime){

    if(id > ID) {
      ID = id + 1;
    }


  }
}