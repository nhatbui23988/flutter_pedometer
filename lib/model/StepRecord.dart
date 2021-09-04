import 'package:floor/floor.dart';

const TABLE_STEP_RECORD = "StepRecord";
const COLUMN_DAY = "day";
const COLUMN_WEEK_OF_YEAR = "weekOfYear";
const COLUMN_MONTH = "month";
const COLUMN_YEAR = "year";
const COLUMN_COUNT = "count";
const DROP_TABLE_IF_EXIST_QUERY = "DROP TABLE IF EXISTS $TABLE_STEP_RECORD";
const CREATE_TABLE_QUERY =
    "CREATE TABLE IF NOT EXISTS $TABLE_STEP_RECORD ($COLUMN_DAY INTEGER, $COLUMN_WEEK_OF_YEAR INTEGER, $COLUMN_MONTH INTEGER, $COLUMN_YEAR INTEGER, $COLUMN_COUNT INTEGER,  PRIMARY KEY ($COLUMN_DAY, $COLUMN_WEEK_OF_YEAR, $COLUMN_MONTH, $COLUMN_YEAR))";

@entity
class StepRecord {
  @primaryKey
  final int day;
  @primaryKey
  final int month;
  @primaryKey
  final int year;
  @primaryKey
  final int weekOfYear;

  int count;

  StepRecord(this.day, this.weekOfYear, this.month, this.year, this.count);
}
