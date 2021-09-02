import 'package:count_step_tracking/dao/StepRecordDao.dart';
import 'package:count_step_tracking/data/AppDatabase.dart';
import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:count_step_tracking/utils/DatabaseHelper.dart';
import 'package:count_step_tracking/utils/DateUtils.dart';
import 'package:week_of_year/week_of_year.dart';

class DataManager {
  static final DataManager instance = DataManager.privateConstructor();

  factory DataManager() {
    return instance;
  }

  DataManager.privateConstructor();

  late AppDatabase _database;
  late StepRecordDao _stepRecordDao;

  initDatabase() async {
    _database = await $FloorAppDatabase
        .databaseBuilder(DATABASE_NAME)
        .addMigrations(DatabaseHelper.getListMigration())
        .build();
    _stepRecordDao = _database.stepRecordDao;
  }

  Future<int> getStepRecordToday() async {
    var datetime = DateTime.now();
    var stepRecordStream = _stepRecordDao.findStepRecordByDate(
        datetime.day, datetime.month, datetime.year);
    var stepRecord = await stepRecordStream.first;
    // get today steps
    if (stepRecord != null) {
      return stepRecord.count;
    } else {
      return 0;
    }
  }

  Future<void> updateStepRecord(int newStepCount) async {
    var datetime = DateTime.now();
    StepRecord stepRecord = StepRecord(datetime.day, datetime.weekOfYear,
        datetime.month, datetime.year, newStepCount);
    var result = await _stepRecordDao.updateStepRecord(stepRecord);
    // if result == 0 ->row không tồn tại
    // => insert
    if (result == 0) {
      _stepRecordDao.insertStepRecord(stepRecord);
    }
  }

  // lấy danh sách step record trong tuần
  Future<List<StepRecord?>> getStepRecordOfWeek() async {
    DateTime today = DateTime.now();
    // gen ra 1 list step record count = 0, chỉ có day có giá trị
    List<StepRecord?> listRecordEmpty = AppDateUtils.generateStepRecordsOfWeek();
    // lấy ra list record trong database
    var localStepRecord = await _stepRecordDao.findStepRecordInWeek(today.weekOfYear, today.year);
    List<StepRecord?> listResult = [];
    for (StepRecord? stepRecordEmpty in listRecordEmpty) {
      bool isExist = false;
      for (StepRecord? stepRecordLocal in localStepRecord) {
        if (stepRecordEmpty?.day == stepRecordLocal?.day) {
          listResult.add(stepRecordLocal);
          isExist = true;
          break;
        }
      }
      if (!isExist) {
        listResult.add(stepRecordEmpty);
      }
    }
    return listResult;
  }
}
