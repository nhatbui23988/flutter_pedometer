


import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:floor/floor.dart';

class DatabaseHelper{
  static List<Migration> getListMigration() => [
    Migration(1, 2, (database) async {
      print("database version ${database.getVersion()}");
      print("Migration 1->2");
      await database.execute(DROP_TABLE_IF_EXIST_QUERY);
    }),
    Migration(2, 3, (database) async {
      print("database version ${await database.getVersion()}");
      print("Migration 2->3");
      await database.execute(DROP_TABLE_IF_EXIST_QUERY);
      await database.execute(CREATE_TABLE_QUERY);
    })
  ];
}