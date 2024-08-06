import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'airplane_database.dart';
import 'app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

import 'main.dart';


class AirplanePage extends StatefulWidget {

  const AirplanePage({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _AirplanePageState? state = context.findAncestorStateOfType<_AirplanePageState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _AirplanePageState createState() => _AirplanePageState();
}

class _AirplanePageState extends State<AirplanePage> {
  var locale = Locale("en", "CA");

  void changeLanguage(Locale newLanguage) {
    setState(() {
      locale = newLanguage;
    });
  }
  late AppDatabase database;
  List<Airplane> airplanes = [];
  Airplane? selectedAirplane;
  final typeController  = TextEditingController();
  final passengersController = TextEditingController();
  final maxSpeedController = TextEditingController();
  final distanceController = TextEditingController();
  late AirplaneDao myDAO;
  bool showAddForm = false;
  late EncryptedSharedPreferences savedData;

  void initState () {
    super.initState();


    $FloorAppDatabase.databaseBuilder('myDatabaseFile.db').build().then((database) {
      myDAO = database.getAirplaneDao;

      myDAO.getAllAirplanes().then( (listOfAirplanes) {
        setState(() {
          airplanes.addAll(listOfAirplanes);
        });
      }
      );
    });

    savedData = EncryptedSharedPreferences(); //constructor is not asynchronous
    savedData.getString("Type").then( (unencryptedString)  {
      if(unencryptedString != null){
        typeController.text = unencryptedString;
      }
    });


  }




  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildDetailsPage(BuildContext context) {
      if (selectedAirplane != null) {
        typeController.text = selectedAirplane!.type;
        passengersController.text = selectedAirplane!.passengers.toString();
        maxSpeedController.text = selectedAirplane!.maxSpeed.toString();
        distanceController.text = selectedAirplane!.distance.toString();

        return Column (
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('type')),

            ),
            TextField(
              controller: passengersController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('passengers')),
            ),
            TextField(
              controller: maxSpeedController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('max_speed')),
            ),

            TextField(
              controller: distanceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('distance')),
            ),
            Row(children: [
              ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('update')!), onPressed: () {
                if (typeController.text.isNotEmpty && passengersController.text.isNotEmpty
                    && maxSpeedController.text.isNotEmpty && distanceController.text.isNotEmpty) {

                  var input = Airplane(Airplane.ID++, typeController.text,
                      int.parse(passengersController.text), double.parse(maxSpeedController.text),
                      double.parse(distanceController.text));

                  setState(() {
                    selectedAirplane?.type = input.type;
                    selectedAirplane?.passengers = input.passengers;
                    selectedAirplane?.maxSpeed = input.maxSpeed;
                    selectedAirplane?.distance = input.distance;

                    myDAO.updateAirplane(input);
                    typeController.text = "";
                    passengersController.text = "";
                    maxSpeedController.text = "";
                    distanceController.text = "";
                  });
                  showSnackbar(context, AppLocalizations.of(context)!.translate('airplane_updated')!);
                } else {
                  showSnackbar(context, AppLocalizations.of(context)!.translate('all_fields_required')!);
                }

              }),
              ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('delete')!), onPressed: () {
                {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          title: Text(AppLocalizations.of(context)!.translate('delete_airplane')!),
                          content: Text(AppLocalizations.of(context)!.translate('delete_plane_confirmation')!),
                          actions: <Widget>[
                            ElevatedButton(onPressed: () {
                              setState(() {
                                myDAO.deleteAirplane(selectedAirplane!);
                                airplanes.remove(selectedAirplane);
                                selectedAirplane = null;
                                typeController.text = "";
                                passengersController.text = "";
                                maxSpeedController.text = "";
                                distanceController.text = "";
                              });
                              Navigator.pop(context);
                              showSnackbar(context, AppLocalizations.of(context)!.translate('airplane_deleted')!);
                            }, child: Text(AppLocalizations.of(context)!.translate('yes')!)),
                            ElevatedButton(onPressed: () {
                              Navigator.pop(context);
                            }, child: Text(AppLocalizations.of(context)!.translate('no')!)),
                          ],
                        ),
                  );
                }

              }),
              ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('go_back')!), onPressed: () {
                setState(() {
                  selectedAirplane = null;
                });
              })
            ],),
            Column(children: [
              Text("${AppLocalizations.of(context)!.translate('airplane_id')!}: ${selectedAirplane!.id}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_type')!}: ${selectedAirplane!.type}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_passengers')!}: ${selectedAirplane!.passengers}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_maxSpeed')!}: ${selectedAirplane!.maxSpeed}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_distance')!}: ${selectedAirplane!.distance}"),
            ],),
          ]
        );

      } else {
        return Column(children: [Text(AppLocalizations.of(context)!.translate('nothing_selected')!)]);
    }

  }

  Widget buildListView(BuildContext context) {
    if (showAddForm == true) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child:
                (airplanes.isNotEmpty)?
                ListView.builder(
                    itemCount: airplanes.length,
                    itemBuilder: (context, rowNumber) {
                      return
                        GestureDetector(
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [

                            Text("${rowNumber + 1}",
                                textAlign: TextAlign.center),
                            Padding(padding: EdgeInsets.fromLTRB(100, 0, 0, 0)),
                            Text(airplanes[rowNumber].type,
                            )
                          ]
                          ),
                          onTap:() {
                            setState(() {
                              selectedAirplane = airplanes[rowNumber];
                              showAddForm = false;// no longer null
                            });
                          },

                        );
                    }
                )
                    : Column(children: [Text(AppLocalizations.of(context)!.translate('no_items')!)],)
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('type')!),
                ),
                TextField(
                  controller: passengersController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('passengers')!),
                ),
                TextField(
                  controller: maxSpeedController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('max_speed')!),
                ),

                TextField(
                  controller: distanceController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('distance')!),
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.translate('submit')!),
                  onPressed: () async {
                    if (typeController.text.isNotEmpty && passengersController.text.isNotEmpty
                        && maxSpeedController.text.isNotEmpty && distanceController.text.isNotEmpty) {

                      var input = Airplane(Airplane.ID++, typeController.text,
                          int.parse(passengersController.text), double.parse(maxSpeedController.text),
                          double.parse(distanceController.text));

                      await savedData.setString("Type",typeController.value.text);
                      setState(() {
                        airplanes.add(input);
                        myDAO.insertAirplane(input);
                        typeController.text = "";
                        passengersController.text = "";
                        maxSpeedController.text = "";
                        distanceController.text = "";
                      });

                      showSnackbar(context, AppLocalizations.of(context)!.translate('airplane_added')!);

                    } else {
                      showSnackbar(context, AppLocalizations.of(context)!.translate('all_fields_required')!);
                    }
                  },
                ),
              ]
          ));
    } else {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child:
                (airplanes.isNotEmpty)?
                ListView.builder(
                    itemCount: airplanes.length,
                    itemBuilder: (context, rowNumber) {
                      return
                        GestureDetector(
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [

                            Text("${rowNumber + 1}",
                                textAlign: TextAlign.center),
                            Padding(padding: EdgeInsets.fromLTRB(100, 0, 0, 0)),
                            Text(airplanes[rowNumber].type,
                            )
                          ]
                          ),
                          onTap:() {
                            setState(() {
                              selectedAirplane = airplanes[rowNumber];
                              showAddForm = false;// no longer null
                            });
                          },

                        );
                    }
                )
                    : Column(children: [Text(AppLocalizations.of(context)!.translate('no_items')!)],)  )

              ]
          ));
    }

  }


  Widget responsiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) { //landscape mode

      return Row(children: [
        Expanded(flex: 1, child: buildListView(context)),
        Expanded(flex: 1, child: buildDetailsPage(context))
      ]);
    } else if (selectedAirplane != null) {
      return buildDetailsPage(context);
    } else {
      return buildListView(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('airplane_page')!),
          actions: [
            OutlinedButton(onPressed: () {
              setState(() {
                if (selectedAirplane != null) {
                  typeController.text = "";
                  passengersController.text = "";
                  maxSpeedController.text = "";
                  distanceController.text = "";
                }
                showAddForm = true;
                selectedAirplane = null;
              });

            }, child:Text(AppLocalizations.of(context)!.translate('add')!)),
            SizedBox(width:10),
            OutlinedButton(onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.translate('instructions')!),
                    content: Text(AppLocalizations.of(context)!.translate('instructions_planeContent')!),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );

            }, child:Text(AppLocalizations.of(context)!.translate('instructions')!)),
            TextButton(
              child: const Text('中文'),
              onPressed: () {
                MyApp.setLocale(context, Locale("zh","ZH"));
              },
            ),
            TextButton(
              child: const Text('English'),
              onPressed: () {
                MyApp.setLocale(context, Locale("en","CA"));
              },
            ),
          ],
        ),
        body: responsiveLayout(context)
        );
  }



}