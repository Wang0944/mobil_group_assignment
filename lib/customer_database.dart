import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
part 'customer_database.g.dart';

// Entity
@Entity(tableName: 'customers')
class Customer {
  @primaryKey
  final int? id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthday;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.birthday,
  });
}

// DAO
@dao
abstract class CustomerDao {
  @Query('SELECT * FROM customers')
  Future<List<Customer>> findAllCustomers();

  @insert
  Future<void> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);
}

// Database
@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase {
  CustomerDao get customerDao;
}