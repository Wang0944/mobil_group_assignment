import 'package:floor/floor.dart';

@entity
class flights{
  static int ID = 1;

  @primaryKey
  final int id;
  final String departing;
  final String arriving;
  final DateTime departTime;
  final DateTime arriveTime;

  flights(this.id, this.departing, this.arriving, this.departTime, this.arriveTime){

    if(id > ID) {
      ID = id + 1;
    }


  }
}