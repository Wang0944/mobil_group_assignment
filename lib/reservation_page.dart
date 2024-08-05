import 'package:flutter/material.dart';
import 'reservation_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

class ReservationPage extends StatefulWidget {
  final Function(Locale) setLocale;

  const ReservationPage({super.key, required this.setLocale});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late AppDatabase database;
  List<Reservation> reservations = [];
  Reservation? selectedReservation;
  final nameController = TextEditingController();
  final customerController = TextEditingController();
  final flightController = TextEditingController();
  final departureCityController = TextEditingController();
  final destinationCityController = TextEditingController();
  final departureTimeController = TextEditingController();
  final arrivalTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase();
    loadPreferences();
  }

  Future<void> initDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('reservations.db').build();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final result = await database.reservationDao.findAllReservations();
    setState(() {
      reservations = result;
    });
  }

  Future<void> insertReservation(Reservation reservation) async {
    try {
      await database.reservationDao.insertReservation(reservation);
      fetchReservations();
    } catch (e) {
      showSnackbar(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> updateReservation(Reservation reservation) async {
    try {
      await database.reservationDao.updateReservation(reservation);
      fetchReservations();
    } catch (e) {
      showSnackbar(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> deleteReservation(Reservation reservation) async {
    try {
      await database.reservationDao.deleteReservation(reservation);
      fetchReservations();
    } catch (e) {
      showSnackbar(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> savePreferences(Reservation reservation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reservation_name', reservation.name);
    await prefs.setString('customer_name', reservation.customerName);
    await prefs.setString('flight_details', reservation.flightDetails);
    await prefs.setString('departure_city', reservation.departureCity);
    await prefs.setString('destination_city', reservation.destinationCity);
    await prefs.setString('departure_time', reservation.departureTime.toIso8601String());
    await prefs.setString('arrival_time', reservation.arrivalTime.toIso8601String());
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('reservation_name') ?? '';
      customerController.text = prefs.getString('customer_name') ?? '';
      flightController.text = prefs.getString('flight_details') ?? '';
      departureCityController.text = prefs.getString('departure_city') ?? '';
      destinationCityController.text = prefs.getString('destination_city') ?? '';
      departureTimeController.text = prefs.getString('departure_time') ?? '';
      arrivalTimeController.text = prefs.getString('arrival_time') ?? '';
    });
  }

  void clearForm() {
    nameController.clear();
    customerController.clear();
    flightController.clear();
    departureCityController.clear();
    destinationCityController.clear();
    departureTimeController.clear();
    arrivalTimeController.clear();
    setState(() {
      selectedReservation = null;
    });
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Reservation'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Reservation Name'),
                ),
                TextField(
                  controller: customerController,
                  decoration: InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: flightController,
                  decoration: InputDecoration(labelText: 'Flight Details'),
                ),
                TextField(
                  controller: departureCityController,
                  decoration: InputDecoration(labelText: 'Departure City'),
                ),
                TextField(
                  controller: destinationCityController,
                  decoration: InputDecoration(labelText: 'Destination City'),
                ),
                TextField(
                  controller: departureTimeController,
                  decoration: InputDecoration(labelText: 'Departure Time (yyyy-MM-dd HH:mm:ss)'),
                ),
                TextField(
                  controller: arrivalTimeController,
                  decoration: InputDecoration(labelText: 'Arrival Time (yyyy-MM-dd HH:mm:ss)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                try {
                  final reservation = Reservation(
                    name: nameController.text,
                    customerName: customerController.text,
                    flightDetails: flightController.text,
                    departureCity: departureCityController.text,
                    destinationCity: destinationCityController.text,
                    departureTime: DateTime.parse(departureTimeController.text),
                    arrivalTime: DateTime.parse(arrivalTimeController.text),
                  );
                  insertReservation(reservation);
                  savePreferences(reservation);
                  clearForm();
                  Navigator.of(context).pop();
                } catch (e) {
                  showSnackbar(context, 'Error: ${e.toString()}');
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showReservationDetailsDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${reservation.name}'),
              Text('Customer: ${reservation.customerName}'),
              Text('Flight: ${reservation.flightDetails}'),
              Text('Departure City: ${reservation.departureCity}'),
              Text('Destination City: ${reservation.destinationCity}'),
              Text('Departure Time: ${reservation.departureTime.toIso8601String()}'),
              Text('Arrival Time: ${reservation.arrivalTime.toIso8601String()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Change Language'),
                  content: LanguageSelectionDialog(setLocale: widget.setLocale),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Reservation Instructions'),
                  content: Text('Use this page to add and manage reservations.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: showAddReservationDialog,
            child: Text('Add Reservation'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (BuildContext context, int index) {
                final reservation = reservations[index];
                return ListTile(
                  title: Text(reservation.name),
                  subtitle: Text('${reservation.customerName} - ${reservation.flightDetails}'),
                  onTap: () => showReservationDetailsDialog(reservation),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteReservation(reservation),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionDialog extends StatelessWidget {
  final Function(Locale) setLocale;

  const LanguageSelectionDialog({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('English'),
          onTap: () {
            setLocale(Locale('en'));
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('中文'),
          onTap: () {
            setLocale(Locale('zh'));
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
