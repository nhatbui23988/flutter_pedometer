// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  StepRecordDao? _stepRecordDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
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
            'CREATE TABLE IF NOT EXISTS `StepRecord` (`day` INTEGER NOT NULL, `month` INTEGER NOT NULL, `year` INTEGER NOT NULL, `weekOfYear` INTEGER NOT NULL, `count` INTEGER NOT NULL, PRIMARY KEY (`day`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  StepRecordDao get stepRecordDao {
    return _stepRecordDaoInstance ??= _$StepRecordDao(database, changeListener);
  }
}

class _$StepRecordDao extends StepRecordDao {
  _$StepRecordDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _stepRecordInsertionAdapter = InsertionAdapter(
            database,
            'StepRecord',
            (StepRecord item) => <String, Object?>{
                  'day': item.day,
                  'month': item.month,
                  'year': item.year,
                  'weekOfYear': item.weekOfYear,
                  'count': item.count
                },
            changeListener),
        _stepRecordUpdateAdapter = UpdateAdapter(
            database,
            'StepRecord',
            ['day'],
            (StepRecord item) => <String, Object?>{
                  'day': item.day,
                  'month': item.month,
                  'year': item.year,
                  'weekOfYear': item.weekOfYear,
                  'count': item.count
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StepRecord> _stepRecordInsertionAdapter;

  final UpdateAdapter<StepRecord> _stepRecordUpdateAdapter;

  @override
  Future<List<StepRecord>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM StepRecord',
        mapper: (Map<String, Object?> row) => StepRecord(
            row['day'] as int,
            row['weekOfYear'] as int,
            row['month'] as int,
            row['year'] as int,
            row['count'] as int));
  }

  @override
  Stream<StepRecord?> findStepRecordByDate(int day, int month, int year) {
    return _queryAdapter.queryStream(
        'SELECT * FROM StepRecord WHERE day = ?1 AND month = ?2 AND year = ?3',
        mapper: (Map<String, Object?> row) => StepRecord(
            row['day'] as int,
            row['weekOfYear'] as int,
            row['month'] as int,
            row['year'] as int,
            row['count'] as int),
        arguments: [day, month, year],
        queryableName: 'StepRecord',
        isView: false);
  }

  @override
  Stream<StepRecord?> findStepRecordInMonth(int month, int year) {
    return _queryAdapter.queryStream(
        'SELECT * FROM StepRecord WHERE month = ?1 AND year = ?2',
        mapper: (Map<String, Object?> row) => StepRecord(
            row['day'] as int,
            row['weekOfYear'] as int,
            row['month'] as int,
            row['year'] as int,
            row['count'] as int),
        arguments: [month, year],
        queryableName: 'StepRecord',
        isView: false);
  }

  @override
  Future<List<StepRecord?>> findStepRecordInWeek(int week, int year) async {
    return _queryAdapter.queryList(
        'SELECT * FROM StepRecord WHERE weekOfYear = ?1 AND year = ?2',
        mapper: (Map<String, Object?> row) => StepRecord(
            row['day'] as int,
            row['weekOfYear'] as int,
            row['month'] as int,
            row['year'] as int,
            row['count'] as int),
        arguments: [week, year]);
  }

  @override
  Future<void> insertStepRecord(StepRecord stepRecord) async {
    await _stepRecordInsertionAdapter.insert(
        stepRecord, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateStepRecord(StepRecord stepRecord) {
    return _stepRecordUpdateAdapter.updateAndReturnChangedRows(
        stepRecord, OnConflictStrategy.abort);
  }
}
