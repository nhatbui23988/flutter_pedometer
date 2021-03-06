import 'package:count_step_tracking/dao/StepRecordDao.dart';
import 'package:count_step_tracking/data/AppDatabase.dart';
import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:count_step_tracking/utils/DatabaseHelper.dart';
import 'package:count_step_tracking/utils/DateUtils.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:charts_flutter/flutter.dart' as chart;
import 'package:permission_handler/permission_handler.dart';

class DataManager {
  static final DataManager instance = DataManager.privateConstructor();
  static const int NEARLY_MONTH = 6;
  static const int NEAREST_WEEKS = 6;
  static const int MIN_MONTH = 1;

  //
  List<StepRecord?> listStepRecordsOfDays = [];
  List<StepRecord?> listStepRecordsOfWeeks = [];
  List<StepRecord?> listStepRecordsOfMonths = [];
  List<StepRecord?> _rawListStepRecords = [];

  //
  factory DataManager() {
    return instance;
  }

  DataManager.privateConstructor();

  late AppDatabase _database;
  late StepRecordDao stepRecordDao;

  Future<void> initDatabase() async {
    _database = await $FloorAppDatabase
        .databaseBuilder(DATABASE_NAME)
        .addMigrations(DatabaseHelper.getListMigration())
        .build();
    stepRecordDao = _database.stepRecordDao;
  }

  Future<void> initChartData() async {
    await getRawStepRecords();
    listStepRecordsOfDays = await getStepRecordDaysOfWeek();
    listStepRecordsOfWeeks = await getStepRecordOfWeeks();
    listStepRecordsOfMonths = await getStepRecordOfMonths();
  }

  Future<int> getStepRecordToday() async {
    var datetime = DateTime.now();
    var stepRecord = await stepRecordDao.findStepRecordByDate(
        datetime.day, datetime.month, datetime.year);
    // get today steps
    if (stepRecord != null) {
      return stepRecord.count;
    } else {
      return 0;
    }
  }

  Future<void> updateDailyStepRecord(int newStepCount) async {
    var today = DateTime.now();
    StepRecord stepRecord = StepRecord(today.day, today.weekOfYear,
        today.month, today.year, newStepCount);
    var result = await stepRecordDao.updateStepRecord(stepRecord);
    // if result == 0 ->row kh??ng t???n t???i
    // => insert
    if (result == 0) {
      stepRecordDao.insertStepRecord(stepRecord);
    }
  }

  Future<void> updateChartData(int newRecord) async{
    await updateDaysOfWeeks(newRecord);
    await updateNearlyWeeks(newRecord);
    await updateNearlyMonths(newRecord);
  }

  Future<void> updateDaysOfWeeks(int newRecord) async{
    var today = DateTime.now();
    if(listStepRecordsOfDays.isNotEmpty){
      var recordIndex = listStepRecordsOfDays.indexWhere((stepRecord) => (stepRecord?.day == today.day) && (stepRecord?.weekOfYear == today.weekOfYear));
      if(recordIndex != -1){
        listStepRecordsOfDays[recordIndex]?.count = newRecord;
      }
    }
  }

  Future<void> updateNearlyWeeks(int newRecord) async {
    var today = DateTime.now();
    if(listStepRecordsOfWeeks.isNotEmpty){
      var recordIndex = listStepRecordsOfWeeks.indexWhere((stepRecord) => (stepRecord?.weekOfYear == today.weekOfYear) && (stepRecord?.year == today.year));
      if(recordIndex != -1){
        listStepRecordsOfWeeks[recordIndex]?.count = newRecord;
      }
    }
  }

  Future<void> updateNearlyMonths(int newRecord) async{
    var today = DateTime.now();
    if(listStepRecordsOfMonths.isNotEmpty){
      var recordIndex = listStepRecordsOfMonths.indexWhere((stepRecord) => (stepRecord?.month == today.month) && (stepRecord?.year == today.year));
      if(recordIndex != -1){
        listStepRecordsOfMonths[recordIndex]?.count = newRecord;
      }
    }
  }

  // list step record ngay trong tuan
  Future<List<StepRecord?>> getStepRecordDaysOfWeek() async {
    // gen 1 list record c??c ng??y trong tu???n n??y v???i count = 0
    List<StepRecord?> listRecordDaysOfWeek =
        AppDateUtils.generateStepRecordsDaysOfWeek();
    var today = DateTime.now();
    // l???c ra data trong tu???n v?? n??m
    var listLocalDataFiltered = _rawListStepRecords
        .where((stepRecord) => (stepRecord?.weekOfYear == today.weekOfYear &&
            stepRecord?.year == today.year))
        .toList();
    // update l???i step count trong stepRecord
    if (listLocalDataFiltered.isNotEmpty) {
      listLocalDataFiltered.forEach((stepRecordLocal) {
        int indexSameRecordDay = listRecordDaysOfWeek.indexWhere(
            (stepRecordEmpty) =>
                (stepRecordEmpty?.day == stepRecordLocal?.day));
        if (indexSameRecordDay != -1) {
          listRecordDaysOfWeek[indexSameRecordDay]?.count =
              stepRecordLocal?.count ?? 0;
        }
      });
      return listRecordDaysOfWeek;
    } else
      return [];
  }

  // list step record cac tuan gan nhat
  Future<List<StepRecord?>> getStepRecordOfWeeks() async {
    List<StepRecord?> listRecordOfWeeks =
        AppDateUtils.generateStepRecordOfWeeks();
    // tu???n ?????u danh s??ch
    var startWeekRecord = listRecordOfWeeks.first;
    // tu???n cu???i danh s??ch
    var endWeekRecord = listRecordOfWeeks.last;
    // filter l???y ra record c?? weekOfYear v?? Year n???m trong range t??? tu???n ?????u t???i tu???n cu???i danh s??ch
    var listLocalDataFiltered = _rawListStepRecords.where((stepRecord) {
      if (startWeekRecord?.year == endWeekRecord?.year) {
        // n???u l?? c??c tu???n trong c??ng 1 n??m
        return findRecordByWeekYearCondition(
            stepRecord, startWeekRecord, endWeekRecord);
      } else {
        // n???u c?? tu???n kh??c n??m
        var endCurrentYearRecord = listRecordOfWeeks.lastWhere(
            (stepRecord) => stepRecord?.year == startWeekRecord?.year);
        var startLastYearRecord = listRecordOfWeeks.firstWhere(
            (stepRecord) => stepRecord?.year == endWeekRecord?.year);
        // query c??c tu???n trong n??m hi???n t???i v?? n??m ngo??i
        return findRecordByWeekYearCondition(
                stepRecord, startWeekRecord, endCurrentYearRecord) ||
            findRecordByWeekYearCondition(
                stepRecord, startLastYearRecord, endWeekRecord);
      }
    }).toList();
    // update l???i step count trong stepRecord
    if (listLocalDataFiltered.isNotEmpty) {
      listLocalDataFiltered.forEach((stepRecordLocal) {
        int indexSameRecordDay = listRecordOfWeeks.indexWhere(
            (stepRecordEmpty) =>
                (stepRecordEmpty?.weekOfYear == stepRecordLocal?.weekOfYear));
        if (indexSameRecordDay != -1) {
          // c???ng d???n step count c???a record c??ng 1 tu???n
          listRecordOfWeeks[indexSameRecordDay]?.count +=
              stepRecordLocal?.count ?? 0;
        }
      });
      return listRecordOfWeeks;
    } else
      return [];
  }

  bool findRecordByWeekYearCondition(StepRecord? stepRecord,
      StepRecord? startWeekRecord, StepRecord? endWeekRecord) {
    return ((stepRecord?.weekOfYear ?? 0) <=
            (startWeekRecord?.weekOfYear ?? 0)) &&
        ((stepRecord?.weekOfYear ?? 0) >= (endWeekRecord?.weekOfYear ?? 0)) &&
        ((stepRecord?.year ?? 0) <= (startWeekRecord?.year ?? 0));
  }

  // t????ng t??? weeks
  // list step record cac thang gan nhat
  Future<List<StepRecord?>> getStepRecordOfMonths() async {
    List<StepRecord?> listRecordOfMonths =
        AppDateUtils.generateStepRecordsOfMonths();
    var startMonthRecord = listRecordOfMonths.first;
    var endMonthRecord = listRecordOfMonths.last;
    // filter l???y ra record c?? 'month' v?? 'year' n???m trong range t??? th??ng ?????u t???i th??ng cu???i danh s??ch
    var listLocalDataFiltered = _rawListStepRecords.where((stepRecord) {
      if (startMonthRecord?.year == endMonthRecord?.year) {
        // n???u l?? c??c th??ng trong c??ng 1 n??m
        return findRecordByMonthYearCondition(
            stepRecord, startMonthRecord, endMonthRecord);
      } else {
        // n???u c?? th??ng kh??c n??m
        var endCurrentYearRecord = listRecordOfMonths.lastWhere(
            (stepRecord) => stepRecord?.year == startMonthRecord?.year);
        var startLastYearRecord = listRecordOfMonths.firstWhere(
            (stepRecord) => stepRecord?.year == endMonthRecord?.year);
        // query c??c th??ng trong n??m hi???n t???i v?? n??m ngo??i
        return findRecordByMonthYearCondition(
                stepRecord, startMonthRecord, endCurrentYearRecord) ||
            findRecordByMonthYearCondition(
                stepRecord, startLastYearRecord, endMonthRecord);
      }
    }).toList();
    // update l???i step count trong stepRecord
    if (listLocalDataFiltered.isNotEmpty) {
      listLocalDataFiltered.forEach((stepRecordLocal) {
        int indexSameRecordDay = listRecordOfMonths.indexWhere(
            (stepRecordEmpty) =>
                (stepRecordEmpty?.month == stepRecordLocal?.month));
        if (indexSameRecordDay != -1) {
          // c???ng d???n step count c???a record c??ng 1 th??ng
          listRecordOfMonths[indexSameRecordDay]?.count +=
              stepRecordLocal?.count ?? 0;
        }
      });
      return listRecordOfMonths;
    }
    return [];
  }

  bool findRecordByMonthYearCondition(StepRecord? stepRecord,
      StepRecord? startWeekRecord, StepRecord? endWeekRecord) {
    return ((stepRecord?.month ?? 0) <= (startWeekRecord?.month ?? 0)) &&
        ((stepRecord?.month ?? 0) >= (endWeekRecord?.month ?? 0)) &&
        ((stepRecord?.year ?? 0) <= (startWeekRecord?.year ?? 0));
  }

  /// get raw data
  Future<void> getRawStepRecords() async {
    var today = DateTime.now();
    // today is June = 6, June - LAST_MONTH = 0 -> isHasMonthLastYear = false
    bool isHasMonthLastYear = today.month - NEARLY_MONTH < 0;
    // print("#1.2 isHasMonthLastYear = $isHasMonthLastYear");
    if (isHasMonthLastYear) {
      // +1 v?? kh??ng th??? query month = 0 => month nh??? nh???t January ( th??ng 1) = 1
      int startMonth = 12 - (today.month - NEARLY_MONTH) + MIN_MONTH;
      List<StepRecord?> listRecordLastYear =
          await stepRecordDao.findStepRecordMonthRange(
              startMonth, 12, today.year);
      _rawListStepRecords.addAll(listRecordLastYear);
      List<StepRecord?> listRecordCurrentYear = await stepRecordDao
          .findStepRecordMonthRange(MIN_MONTH, today.month, today.year);
      _rawListStepRecords.addAll(listRecordCurrentYear);
    } else {
      int startMonth =  today.month - NEARLY_MONTH + MIN_MONTH;
      _rawListStepRecords = await stepRecordDao.findStepRecordMonthRange(
          startMonth, today.month, today.year);
    }
  }

  // bar chart data

  List<chart.Series<StepRecord?, String>> chartDataDaysOfWeek(
      List<StepRecord?> listRecordsDaysOfWeek) {
    var today = DateTime.now();
    return [
      chart.Series<StepRecord?, String>(
          id: "DaysOfWeek",
          colorFn: (StepRecord? data, __) {
            if (data?.day == today.day) {
              return chart.MaterialPalette.green.shadeDefault;
            } else
              return chart.MaterialPalette.blue.shadeDefault;
          },
          // v???a l?? display name, v???a l?? ID,
          // n???u trong list data c?? 1 data c??ng domainFn th?? data add sau s??? th???c hi???n ghi ???? l??n data c?? c?? c??ng domainFn
          domainFn: (StepRecord? data, index) =>
              "${AppDateUtils.getDayName(index != null ? index + 1 : 0)}",
          // gi?? tr??? ????? hi???n th??? ( display value)
          measureFn: (StepRecord? data, _) => data?.count,
          data: listRecordsDaysOfWeek)
    ];
  }

  List<chart.Series<StepRecord?, String>> chartDataNearlyWeeks(
      List<StepRecord?> listRecordsDaysOfWeek) {
    var today = DateTime.now();
    return [
      chart.Series<StepRecord?, String>(
          id: "NearlyWeeks",
          colorFn: (StepRecord? data, __) {
            if (data?.weekOfYear == today.weekOfYear) {
              return chart.MaterialPalette.green.shadeDefault;
            } else
              return chart.MaterialPalette.blue.shadeDefault;
          },
          domainFn: (StepRecord? data, _) => "${data?.day ?? "??"}/${data?.month ?? "??"}",
          measureFn: (StepRecord? data, _) => data?.count,
          data: listRecordsDaysOfWeek)
    ];
  }

  List<chart.Series<StepRecord?, String>> chartDataNearlyMonths(
      List<StepRecord?> listRecordsDaysOfWeek) {
    var today = DateTime.now();
    return [
      chart.Series<StepRecord?, String>(
          id: "NearlyMonths",
          colorFn: (StepRecord? data, __) {
            if (data?.month == today.month) {
              return chart.MaterialPalette.green.shadeDefault;
            } else
              return chart.MaterialPalette.blue.shadeDefault;
          },
          // v???a l?? display name, v???a l?? ID,
          // n???u trong list data c?? 1 data c??ng domainFn th?? data add sau s??? th???c hi???n ghi ???? l??n data c?? c?? c??ng domainFn
          domainFn: (StepRecord? data, index) => "T${data?.month ?? "??"}",
          // gi?? tr??? ????? hi???n th??? ( display value)
          measureFn: (StepRecord? data, _) => data?.count,
          data: listRecordsDaysOfWeek)
    ];
  }
}
