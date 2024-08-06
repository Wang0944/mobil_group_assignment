// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $flight_databaseBuilderContract {
  /// Adds migrations to the builder.
  $flight_databaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $flight_databaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<flight_database> build();
}

// ignore: avoid_classes_with_only_static_members
class $Floorflight_database {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $flight_databaseBuilderContract databaseBuilder(String name) =>
      _$flight_databaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $flight_databaseBuilderContract inMemoryDatabaseBuilder() =>
      _$flight_databaseBuilder(null);
}

class _$flight_databaseBuilder implements $flight_databaseBuilderContract {
  _$flight_databaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $flight_databaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $flight_databaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<flight_database> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$flight_database();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$flight_database extends flight_database {
  _$flight_database([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  flight_DAO? _flightDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `flights` (`id` INTEGER NOT NULL, `departure` TEXT NOT NULL, `destination` TEXT NOT NULL, `departureTime` TEXT NOT NULL, `arriveTime` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  flight_DAO get flightDAO {
    return _flightDAOInstance ??= _$flight_DAO(database, changeListener);
  }
}

class _$flight_DAO extends flight_DAO {
  _$flight_DAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightsInsertionAdapter = InsertionAdapter(
            database,
            'flights',
            (flights item) => <String, Object?>{
                  'id': item.id,
                  'departure': item.departure,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arriveTime': item.arriveTime
                }),
        _flightsUpdateAdapter = UpdateAdapter(
            database,
            'flights',
            ['id'],
            (flights item) => <String, Object?>{
                  'id': item.id,
                  'departure': item.departure,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arriveTime': item.arriveTime
                }),
        _flightsDeletionAdapter = DeletionAdapter(
            database,
            'flights',
            ['id'],
            (flights item) => <String, Object?>{
                  'id': item.id,
                  'departure': item.departure,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arriveTime': item.arriveTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<flights> _flightsInsertionAdapter;

  final UpdateAdapter<flights> _flightsUpdateAdapter;

  final DeletionAdapter<flights> _flightsDeletionAdapter;

  @override
  Future<List<flights>> getFlights() async {
    return _queryAdapter.queryList('SELECT * from flights',
        mapper: (Map<String, Object?> row) => flights(
            row['id'] as int,
            row['departure'] as String,
            row['destination'] as String,
            row['departureTime'] as String,
            row['arriveTime'] as String));
  }

  @override
  Future<void> insertFlight(flights flight) async {
    await _flightsInsertionAdapter.insert(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(flights flight) async {
    await _flightsUpdateAdapter.update(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFlight(flights flight) async {
    await _flightsDeletionAdapter.delete(flight);
  }
}
