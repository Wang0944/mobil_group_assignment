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

/// A page that displays a list of airplanes and allows the user to view details,
/// add, update, or delete airplane entries.
class AirplanePage extends StatefulWidget {
  /// Creates an instance of [AirplanePage].
  const AirplanePage({super.key});

  /// Sets the locale of the application.
  ///
  /// This method updates the locale used by the [AirplanePage] and its descendants.
  ///
  /// [context] The build context to find the state.
  /// [newLocale] The new locale to set.
  static void setLocale(BuildContext context, Locale newLocale) async {
    _AirplanePageState? state = context.findAncestorStateOfType<_AirplanePageState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _AirplanePageState createState() => _AirplanePageState();
}

class _AirplanePageState extends State<AirplanePage> {
  /// The current locale of the application.
  var locale = Locale("en", "CA");

  /// Changes the locale of the application.
  ///
  /// [newLanguage] The new locale to set.
  void changeLanguage(Locale newLanguage) {
    setState(() {
      locale = newLanguage;
    });
  }

  late AppDatabase database; // The database instance.
  List<Airplane> airplanes = []; // List of airplanes.
  Airplane? selectedAirplane; // The currently selected airplane.
  final typeController = TextEditingController(); // Controller for the airplane type input.
  final passengersController = TextEditingController(); // Controller for the number of passengers input.
  final maxSpeedController = TextEditingController(); // Controller for the maximum speed input.
  final distanceController = TextEditingController(); // Controller for the distance input.
  late AirplaneDao myDAO; // Data Access Object for airplanes.
  bool showAddForm = false; // Flag to determine if the add form should be shown.
  late EncryptedSharedPreferences savedData; // Encrypted shared preferences instance.

  @override
  void initState() {
    super.initState();

    // Initialize the database and retrieve all airplanes.
    $FloorAppDatabase.databaseBuilder('myDatabaseFile.db').build().then((database) {
      myDAO = database.getAirplaneDao;
      myDAO.getAllAirplanes().then((listOfAirplanes) {
        setState(() {
          airplanes.addAll(listOfAirplanes);
        });
      });
    });

    // Initialize EncryptedSharedPreferences.
    savedData = EncryptedSharedPreferences(); // Constructor is not asynchronous.
    savedData.getString("Type").then((type) {
      if (type != null) {
        typeController.text = type; // Set the typeController text from saved preferences.
      }
    });
  }

  /// Shows a snackbar with the given message.
  ///
  /// [context] The build context.
  /// [message] The message to display in the snackbar.
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Builds the details page for the selected airplane.
  ///
  /// [context] The build context.
  /// Returns a [Widget] displaying the details of the selected airplane, or a message if no airplane is selected.
  Widget buildDetailsPage(BuildContext context) {
    if (selectedAirplane != null) {
      // Populate the text fields with the selected airplane's data.
      typeController.text = selectedAirplane!.type;
      passengersController.text = selectedAirplane!.passengers.toString();
      maxSpeedController.text = selectedAirplane!.maxSpeed.toString();
      distanceController.text = selectedAirplane!.distance.toString();

      return Column(
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
          Row(
            children: [
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.translate('update')!),
                onPressed: () {
                  if (typeController.text.isNotEmpty &&
                      passengersController.text.isNotEmpty &&
                      maxSpeedController.text.isNotEmpty &&
                      distanceController.text.isNotEmpty) {

                    // Create a new Airplane object with updated data.
                    var input = Airplane(Airplane.ID++, typeController.text,
                        int.parse(passengersController.text), double.parse(maxSpeedController.text),
                        double.parse(distanceController.text));

                    setState(() {
                      selectedAirplane?.type = input.type;
                      selectedAirplane?.passengers = input.passengers;
                      selectedAirplane?.maxSpeed = input.maxSpeed;
                      selectedAirplane?.distance = input.distance;

                      // Update the airplane in the database.
                      myDAO.updateAirplane(input);

                      // Clear the text fields.
                      typeController.text = "";
                      passengersController.text = "";
                      maxSpeedController.text = "";
                      distanceController.text = "";
                    });
                    showSnackbar(context, AppLocalizations.of(context)!.translate('airplane_updated')!);
                  } else {
                    showSnackbar(context, AppLocalizations.of(context)!.translate('all_fields_required')!);
                  }
                },
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.translate('delete')!),
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          title: Text(AppLocalizations.of(context)!.translate('delete_airplane')!),
                          content: Text(AppLocalizations.of(context)!.translate('delete_plane_confirmation')!),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () async {
                                var selectedAirplaneID = selectedAirplane!.id;
                                savedData.getString("ID").then((ID) async {
                                  if (selectedAirplaneID == int.parse(ID)) {
                                    await savedData.remove("Type");
                                  }
                                });
                                setState(() {
                                  myDAO.deleteAirplane(selectedAirplane!);
                                  airplanes.remove(selectedAirplane);
                                  selectedAirplane = null;
                                  // Clear the text fields.
                                  typeController.text = "";
                                  passengersController.text = "";
                                  maxSpeedController.text = "";
                                  distanceController.text = "";
                                });
                                Navigator.pop(context); // Close the dialog.
                                showSnackbar(context, AppLocalizations.of(context)!.translate('airplane_deleted')!);
                              },
                              child: Text(AppLocalizations.of(context)!.translate('yes')!),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog without deleting.
                              },
                              child: Text(AppLocalizations.of(context)!.translate('no')!),
                            ),
                          ],
                        ),
                  );
                },
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.translate('go_back')!),
                onPressed: () {
                  setState(() {
                    selectedAirplane = null; // Deselect the current airplane.
                    typeController.text = "";
                    passengersController.text = "";
                    maxSpeedController.text = "";
                    distanceController.text = "";
                  });
                },
              ),
            ],
          ),
          Column(
            children: [
              Text("${AppLocalizations.of(context)!.translate('airplane_id')!}: ${selectedAirplane!.id}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_type')!}: ${selectedAirplane!.type}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_passengers')!}: ${selectedAirplane!.passengers}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_maxSpeed')!}: ${selectedAirplane!.maxSpeed}"),
              Text("${AppLocalizations.of(context)!.translate('airplane_distance')!}: ${selectedAirplane!.distance}"),
            ],
          ),
        ],
      );
    } else {
      // Return a message if no airplane is selected.
      return Column(children: [Text(AppLocalizations.of(context)!.translate('nothing_selected')!)]);
    }
  }

  /// Builds the list view of airplanes and the form to add a new airplane.
  ///
  /// [context] The build context.
  /// Returns a [Widget] that displays the list view of airplanes or the add form based on [showAddForm] flag.
  Widget buildListView(BuildContext context) {
    if (showAddForm) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: (airplanes.isNotEmpty)
                  ? ListView.builder(
                itemCount: airplanes.length,
                itemBuilder: (context, rowNumber) {
                  return GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("${rowNumber + 1}", textAlign: TextAlign.center),
                        Padding(padding: EdgeInsets.fromLTRB(100, 0, 0, 0)),
                        Text(airplanes[rowNumber].type),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedAirplane = airplanes[rowNumber];
                        showAddForm = false; // Hide the add form.
                      });
                    },
                  );
                },
              )
                  : Column(children: [Text(AppLocalizations.of(context)!.translate('no_items')!)],
              ),
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
                if (typeController.text.isNotEmpty &&
                    passengersController.text.isNotEmpty &&
                    maxSpeedController.text.isNotEmpty &&
                    distanceController.text.isNotEmpty) {

                  var input = Airplane(Airplane.ID++, typeController.text,
                      int.parse(passengersController.text), double.parse(maxSpeedController.text),
                      double.parse(distanceController.text));

                  await savedData.setString("Type", typeController.value.text);
                  await savedData.setString("ID", input.id.toString());

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
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: (airplanes.isNotEmpty)
                    ? ListView.builder(
                  itemCount: airplanes.length,
                  itemBuilder: (context, rowNumber) {
                    return GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("${rowNumber + 1}", textAlign: TextAlign.center),
                          Padding(padding: EdgeInsets.fromLTRB(100, 0, 0, 0)),
                          Text(airplanes[rowNumber].type),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedAirplane = airplanes[rowNumber];
                          showAddForm = false; // Hide the add form.
                        });
                      },
                    );
                  },
                )
                    : Column(children: [Text(AppLocalizations.of(context)!.translate('no_items')!)],)
            ),
          ],
        ),
      );
    }
  }

  /// Builds a responsive layout based on the screen size.
  ///
  /// [context] The build context.
  /// Returns a [Widget] that adjusts the layout based on the screen orientation and size.
  Widget responsiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) { // Landscape mode
      return Row(
        children: [
          Expanded(flex: 1, child: buildListView(context)),
          Expanded(flex: 1, child: buildDetailsPage(context)),
        ],
      );
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
          OutlinedButton(
            onPressed: () {
              setState(() {
                if (selectedAirplane != null) {
                  typeController.text = "";
                  passengersController.text = "";
                  maxSpeedController.text = "";
                  distanceController.text = "";
                }
                showAddForm = true; // Show the add form.
                selectedAirplane = null; // Deselect any selected airplane.
              });
            },
            child: Text(AppLocalizations.of(context)!.translate('add')!),
          ),
          SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {
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
                          Navigator.of(context).pop(); // Close the dialog.
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(AppLocalizations.of(context)!.translate('instructions')!),
          ),
          TextButton(
            child: const Text('中文'),
            onPressed: () {
              MyApp.setLocale(context, Locale("zh", "ZH")); // Set locale to Chinese.
            },
          ),
          TextButton(
            child: const Text('English'),
            onPressed: () {
              MyApp.setLocale(context, Locale("en", "CA")); // Set locale to English.
            },
          ),
        ],
      ),
      body: responsiveLayout(context), // Display the responsive layout.
    );
  }
}
