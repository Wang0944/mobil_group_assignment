import 'package:flutter/material.dart';
import 'customer_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late AppDatabase database;
  List<Customer> customers = [];
  Customer? selectedCustomer;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final birthdayController = TextEditingController();

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

  Future<void> insertCustomer(BuildContext context, Customer customer) async {
    await database.customerDao.insertCustomer(customer);
    loadCustomers();
    showSnackbar(context, 'Customer added successfully');
  }

  Future<void> updateCustomer(BuildContext context, Customer customer) async {
    await database.customerDao.updateCustomer(customer);
    loadCustomers();
    showSnackbar(context, 'Customer updated successfully');
  }

  Future<void> deleteCustomer(BuildContext context, Customer customer) async {
    await database.customerDao.deleteCustomer(customer);
    loadCustomers();
    showSnackbar(context, 'Customer deleted successfully');
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

  void selectCustomer(Customer customer) {
    setState(() {
      selectedCustomer = customer;
      firstNameController.text = customer.firstName;
      lastNameController.text = customer.lastName;
      addressController.text = customer.address;
      birthdayController.text = customer.birthday;
    });
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showDeleteConfirmationDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await deleteCustomer(context, customer);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var isLandscape = size.width > size.height && size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Instructions'),
                    content: const Text('This is the customer page, you can add, modify, and delete users'),
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
            },
          ),
        ],
      ),
      body: isLandscape ? buildLandscapeLayout(context) : buildPortraitLayout(context),
    );
  }

  Widget buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: buildCustomerListView(context, showForm: false)),
        Expanded(flex: 2, child: buildCustomerDetailsView(context)),
      ],
    );
  }

  Widget buildPortraitLayout(BuildContext context) {
    return selectedCustomer == null
        ? buildCustomerListView(context, showForm: true)
        : buildCustomerDetailsView(context, showBackButton: true);
  }

  Widget buildCustomerListView(BuildContext context, {bool showForm = false}) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${customers[index].firstName} ${customers[index].lastName}'),
                subtitle: Text(customers[index].address),
                onTap: () => selectCustomer(customers[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          firstNameController.text = customers[index].firstName;
                          lastNameController.text = customers[index].lastName;
                          addressController.text = customers[index].address;
                          birthdayController.text = customers[index].birthday;
                          selectedCustomer = customers[index];
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDeleteConfirmationDialog(context, customers[index]);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (showForm) buildForm(context),
      ],
    );
  }

  Widget buildCustomerDetailsView(BuildContext context, {bool showBackButton = false}) {
    return Scaffold(
      appBar: showBackButton
          ? AppBar(
        leading: BackButton(onPressed: () {
          setState(() {
            selectedCustomer = null;
          });
        }),
        title: const Text('Customer Details'),
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildForm(context),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: firstNameController,
          decoration: const InputDecoration(labelText: 'First Name'),
        ),
        TextField(
          controller: lastNameController,
          decoration: const InputDecoration(labelText: 'Last Name'),
        ),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        TextField(
          controller: birthdayController,
          decoration: const InputDecoration(labelText: 'Birthday'),
        ),
        Row(
          children: [
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
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
                  await insertCustomer(context, newCustomer);
                  savePreferences(newCustomer);
                  clearForm();
                } else {
                  showSnackbar(context, 'All fields are required!');
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                if (firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    birthdayController.text.isNotEmpty) {
                  final updatedCustomer = Customer(
                    id: selectedCustomer?.id,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    address: addressController.text,
                    birthday: birthdayController.text,
                  );
                  await updateCustomer(context, updatedCustomer);
                  clearForm();
                } else {
                  showSnackbar(context, 'All fields are required!');
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}