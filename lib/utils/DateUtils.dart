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

  static List<StepRecord> generateStepRecordsOfWeek(){
    // print("generateStepRecordsOfWeek");
    var today = DateTime.now();
    // print("today: ${today.day}/${today.month}/${today.year} - weekDay: ${AppDateUtils.getDayName(today.weekday)} - WeekOfYear ${today.weekOfYear}");
    var firstDayOfWeek = today.subtract(Duration(days: today.weekday-1));
    // print("firstDayOfWeek: ${firstDayOfWeek.day}/${firstDayOfWeek.month}/${firstDayOfWeek.year} - weekDay: ${AppDateUtils.getDayName(firstDayOfWeek.weekday)} - WeekOfYear ${firstDayOfWeek.weekOfYear}");
    // print("generate days");
    return List<StepRecord>.generate(7, (index)
    {
      // print("#index $index");
      var day = firstDayOfWeek.add(Duration(days: index));
      // print("day: ${day.day}/${day.month}/${day.year} - weekDay: ${AppDateUtils.getDayName(day.weekday)} - WeekOfYear ${day.weekOfYear}");
      return StepRecord(day.day, 0, 0, 0, 0);
    });
  }
}
