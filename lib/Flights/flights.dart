import 'package:floor/floor.dart';

@entity
class flights{
  static int ID = 1;

  @primaryKey
  final int id;
  final String departingFrom;
  final String arrivingTo;
  final DateTime departTime;
  final DateTime arriveTime;

  flights(this.id, this.departingFrom, this.arrivingTo, this.departTime, this.arriveTime){

    if(id > ID) {
      ID = id + 1;
    }


  }
}