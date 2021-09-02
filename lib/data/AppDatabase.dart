
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:count_step_tracking/dao/StepRecordDao.dart';
import 'package:count_step_tracking/model/StepRecord.dart';

part 'AppDatabase.g.dart'; // the generated code will be there
const DATABASE_NAME = "flutter_database.db";
@Database(version: 3, entities: [StepRecord])
abstract class AppDatabase extends FloorDatabase {
  StepRecordDao get stepRecordDao;
}
