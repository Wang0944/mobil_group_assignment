import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flight_DAO.dart';
import 'flight_database.dart';


///a widget for flights
class FlightsPage extends StatefulWidget {
  @override
  FlightsPageState createState() => FlightsPageState();
}

class FlightsPageState extends State<FlightsPage> {

  ///holds list of mapped flights.
  List<Map<String, dynamic>> flights = [
  ]; //dynamic lets the stores data be of any type

  ///controllers that take user text input for details of flight.
  final TextEditingController _departureController = TextEditingController(); //controller objects for flight departure
  final TextEditingController _destinationController = TextEditingController(); // destination
  final TextEditingController _departureTimeController = TextEditingController(); // departure time
  final TextEditingController _arrivalTimeController = TextEditingController(); //destination arrival time


  /// nullable database object that accesses flight data.
  Database? _database; //nullable

  @override
  void initState() {
    super.initState();
    // $Floorflight_database.databaseBuilder('app_database.db').build().then( (database) async {
    //   flight_DAO = database.flightDAO;
    //
    //   List<flight> items = await myDAO.flight();
    //
    //   setState(() {
    //     listObjects.addAll(items);
    //   });
    // });
    loadFlights(); //calls database
  }

  /// loads flight data and creates flights table the first time. Reloads data with new flights data.
  Future<void> loadFlights() async {
    final databasePath = await getDatabasesPath(); //waits until the path to the app's db is found.
    final path = join(
        databasePath, 'flights.db'); //combines parameters to create full path.

    _database = await openDatabase( //creates db if null
      path,
      onCreate: (db,
          version) { //part of sqflite package - lets me define a db schema.
        return db.execute( //execute SQL
          "CREATE TABLE flights(id INTEGER PRIMARY KEY, departure TEXT, destination TEXT, departureTime TEXT, arrivalTime TEXT)", //SQLite
        );
      },
      version: 1, //the schema version. Only update, manually, if schema is updated.
    );

    final List<Map<String, dynamic>> maps = await _database!.query('flights');
    setState(() {
      flights = maps;
    });
  }

  /// adds a new flight to the flights table.
  Future<void> _addFlight(String departure, String destination,
      String departureTime, String arrivalTime) async {
    await _database!.insert( //inserts flights into db
      'flights',
      {
        'departure': departure,
        'destination': destination,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
      },
    );

    loadFlights(); //reloads page to update for new flights.
  }

  ///updates existing flights.
  Future<void> _updateFlight(int id, String departure, String destination,
      String departureTime, String arrivalTime) async {
    await _database!.update(
      'flights',
      {
        'departure': departure,
        'destination': destination,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
      },
      where: 'id= ?',
      whereArgs: [id],
    );
    loadFlights(); //reloads.
  }

  ///deletes existing flights.
  Future<void> _deleteFlight(int id) async {
    await _database!.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
    loadFlights(); //reloads
  }


  ///should validate that all text fields are not null, else a snackbar shows error message. Incomplete implementation.
  bool _validate() {
    if (_departureTimeController == null ||
        _destinationController == null ||
        _departureTimeController == null ||
        _arrivalTimeController == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
        content: Text('All fields required'),
      ),
      );
      return false;
    }
    return true;
  }

  /// creates a dialog for update/add flight depending on whether instance exists or is null. Null = add, !null = update existing.
  void _showFlightDialog(BuildContext context, {Map<String, dynamic>? flight}) {
    if (flight != null) {
      _departureController.text = flight['departure'];
      _destinationController.text = flight['destination'];
      _departureTimeController.text = flight['departureTime'];
      _arrivalTimeController.text = flight['arrivalTime'];
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(flight == null ? 'Add Flight' : 'Update Flight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _departureController,
                decoration: const InputDecoration(labelText: 'Departure City'),
              ),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                    labelText: 'Destination City'),
              ),
              TextField(
                controller: _departureTimeController,
                decoration: const InputDecoration(labelText: 'Departure Time'),
              ),
              TextField(
                controller: _arrivalTimeController,
                decoration: const InputDecoration(labelText: 'Arrival Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (flight != null) {
                  _deleteFlight(flight['id']);
                  _clearTextControllers();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                if (flight == null) {
                  _addFlight(
                    _departureController.text,
                    _destinationController.text,
                    _departureTimeController.text,
                    _arrivalTimeController.text,
                  );
                } else {
                  _updateFlight(
                    flight['id'],
                    _departureController.text,
                    _destinationController.text,
                    _departureTimeController.text,
                    _arrivalTimeController.text,
                  );
                }
                _clearTextControllers();
                Navigator.pop(dialogContext);
              },
              child: Text(flight == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    ).then((_) {
      _clearTextControllers(); //clears text fields for new entries
    });
  }

  ///clears text fields
  void _clearTextControllers() {
    _departureController.clear();
    _destinationController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          if ((width > height) && (width > 720)) { //standard screen size for responsiveness
            return Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: flights.length,
                    //list should equal length of flights table list.
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            '${flights[index]['departure']} to ${flights[index]['destination']}'),
                        subtitle: Text(
                            '${flights[index]['departureTime']} - ${flights[index]['arrivalTime']}'),
                        onTap: () =>
                            _showFlightDialog(context, flight: flights[index]),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      //takes up whole horizontal screen.
                      children: [
                        TextField(
                          controller: _departureController,
                          decoration: const InputDecoration(
                              labelText: 'Departure City'),
                        ),
                        const SizedBox(width: 8),
                        TextField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                              labelText: 'Destination'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _departureTimeController,
                          decoration: const InputDecoration(
                              labelText: 'Departure Time'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _arrivalTimeController,
                          decoration: const InputDecoration(
                              labelText: 'Arrival Time'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          //plus icon - opens up dialog for adding/updating
                          onPressed: () {
                            _showFlightDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else { //if not meets requirement, should just be single page display.
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: flights.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              '${flights[index]['departure']} to ${flights[index]['destination']}'),
                          subtitle: Text(
                              '${flights[index]['departureTime']} - ${flights[index]['arrivalTime']} '),
                          onTap: () =>
                              _showFlightDialog(
                                  context, flight: flights[index]),
                        );
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _departureTimeController,
                        decoration: const InputDecoration(
                            labelText: 'Departing City'),
                      ),
                      const SizedBox(width: 8),
                      TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                            labelText: 'Destination City'),

                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _departureTimeController,
                        decoration: InputDecoration(
                            labelText: 'Departime Time'),

                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _arrivalTimeController,
                        decoration: InputDecoration(labelText: 'Arrival Time'),
                      ),
                      IconButton(icon: const Icon(Icons.add),
                        onPressed: () {
                          _showFlightDialog(context);
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}


