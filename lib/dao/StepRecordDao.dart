

import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:floor/floor.dart';

@dao
abstract class StepRecordDao {
  @Query('SELECT * FROM StepRecord')
  Future<List<StepRecord>> findAllRecords();

  @Query('SELECT * FROM $TABLE_STEP_RECORD WHERE $COLUMN_DAY = :day AND $COLUMN_MONTH = :month AND $COLUMN_YEAR = :year')
  Future<StepRecord?> findStepRecordByDate(int day, int month, int year);

  @Query('SELECT * FROM $TABLE_STEP_RECORD WHERE $COLUMN_MONTH = :month AND $COLUMN_YEAR = :year')
  Future<StepRecord?> findStepRecordInMonth(int month, int year);

  @Query('SELECT * FROM $TABLE_STEP_RECORD WHERE $COLUMN_WEEK_OF_YEAR = :week AND $COLUMN_YEAR = :year')
  Future<List<StepRecord?>> findStepRecordInWeek(int week, int year);

  @Query('SELECT * FROM $TABLE_STEP_RECORD WHERE $COLUMN_MONTH >= :startMonth AND $COLUMN_MONTH <= :endMonth AND $COLUMN_YEAR = :year')
  Future<List<StepRecord?>> findStepRecordMonthRange(int startMonth, int endMonth, int year);

  @insert
  Future<void> insertStepRecord(StepRecord stepRecord);

  @update
  Future<int> updateStepRecord(StepRecord stepRecord);
}