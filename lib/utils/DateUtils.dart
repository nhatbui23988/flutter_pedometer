import 'package:count_step_tracking/data/DataManager.dart';
import 'package:flutter/material.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:count_step_tracking/model/StepRecord.dart';

class AppDateUtils {
  static String getDayName(int? day) {
    switch (day) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sar";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  static List<StepRecord> generateStepRecordsDaysOfWeek() {
    var today = DateTime.now();
    // [monday = 1] và [sunday = 7]
    // ngày hôm nay - (ngày hôm nay - 1) sẽ = ngày đầu tuần
    var firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List<StepRecord>.generate(7, (index) {
      var day = firstDayOfWeek.add(Duration(days: index));
      return StepRecord(day.day, day.weekOfYear, day.month, day.year, 0);
    });
  }

  static List<StepRecord> generateStepRecordOfWeeks() {
    var today = DateTime.now();
    // lấy ngày đầu tuần cho đẹp
    var firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List<StepRecord>.generate(DataManager.NEAREST_WEEKS, (index) {
      // lấy ngày hiện tại - 7 ngày là ra tuần trước
      var day =
          firstDayOfWeek.subtract(Duration(days: DateTime.daysPerWeek * index));
      return StepRecord(day.day, day.weekOfYear, day.month, day.year, 0);
    });
  }

  // gen ra list record của 6 tháng
  // list record tháng chỉ quan tâm tháng và year
  // => chỉ cần khởi tạo [tháng] và [năm] cho StepRecord, còn lại default = 0
  static List<StepRecord> generateStepRecordsOfMonths() {
    var today = DateTime.now();
    var listRecordsOfMonths =
        List<StepRecord>.generate(DataManager.NEARLY_MONTH, (index) {
      // ví dụ tháng hiện tại là tháng 2 năm 2021
      //dùng month - index để xác định tháng sẽ khởi tạo
      // tháng 2 - index 0 = 2 -> tháng 2
      // tháng 2 - 1 = 1 -> tháng 1
      if (today.month - index >= DataManager.MIN_MONTH) {
        var month = today.month - index;
        return StepRecord(0, 0, month, today.year, 0);
      } else {
        // tháng 2 - 2 = 0 < MIN_MONTH (=1) -> last year
        // -> month = 12 - (index 2 - tháng 2) ; year - 1
        // tháng 2 - 3 = -1 ~ tương tự
        var month = 12 - (index - today.month);
        var year = today.year - 1;
        return StepRecord(0, 0, month, year, 0);
      }
    });
    return listRecordsOfMonths;
  }
}
