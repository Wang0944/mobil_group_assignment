import 'package:flutter/material.dart';
import 'customer_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late AppDatabase database;
  List<Customer> customers = [];
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();
  bool copyPrevious = false;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final databasePath = await sqflite.getDatabasesPath();
    final path = join(databasePath, 'customer_database.db');
    database = await $FloorAppDatabase.databaseBuilder(path).build();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    customers = await database.customerDao.findAllCustomers();
    setState(() {});
  }

  Future<void> insertCustomer(Customer customer) async {
    await database.customerDao.insertCustomer(customer);
    loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await database.customerDao.updateCustomer(customer);
    loadCustomers();
  }

  Future<void> deleteCustomer(Customer customer) async {
    await database.customerDao.deleteCustomer(customer);
    loadCustomers();
  }

  Future<void> savePreferences(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', customer.firstName);
    await prefs.setString('lastName', customer.lastName);
    await prefs.setString('address', customer.address);
    await prefs.setString('birthday', customer.birthday);
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    firstNameController.text = prefs.getString('firstName') ?? '';
    lastNameController.text = prefs.getString('lastName') ?? '';
    addressController.text = prefs.getString('address') ?? '';
    birthdayController.text = prefs.getString('birthday') ?? '';
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    birthdayController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${customers[index].firstName} ${customers[index].lastName}'),
                  subtitle: Text(customers[index].address),
                  onTap: () {
                    setState(() {
                      firstNameController.text = customers[index].firstName;
                      lastNameController.text = customers[index].lastName;
                      addressController.text = customers[index].address;
                      birthdayController.text = customers[index].birthday;
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            firstNameController.text = customers[index].firstName;
                            lastNameController.text = customers[index].lastName;
                            addressController.text = customers[index].address;
                            birthdayController.text = customers[index].birthday;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteCustomer(customers[index]);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(labelText: 'Birthday'),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            addressController.text.isNotEmpty &&
                            birthdayController.text.isNotEmpty) {
                          final newCustomer = Customer(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            address: addressController.text,
                            birthday: birthdayController.text,
                          );
                          insertCustomer(newCustomer);
                          savePreferences(newCustomer);
                          clearForm();
                        } else {
                          final snackBar = SnackBar(
                            content: Text('All fields are required!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text('Update'),
                      onPressed: () {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            addressController.text.isNotEmpty &&
                            birthdayController.text.isNotEmpty) {
                          final updatedCustomer = Customer(
                            id: customers.firstWhere((c) =>
                            c.firstName == firstNameController.text &&
                                c.lastName == lastNameController.text).id,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            address: addressController.text,
                            birthday: birthdayController.text,
                          );
                          updateCustomer(updatedCustomer);
                          clearForm();
                        } else {
                          final snackBar = SnackBar(
                            content: Text('All fields are required!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}