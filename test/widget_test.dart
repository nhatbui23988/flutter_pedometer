// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:count_step_tracking/data/DataManager.dart';
import 'package:count_step_tracking/data/SharePreference.dart';
import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:count_step_tracking/utils/DateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/week_of_year.dart';

const int LAST_MONTH = 6;
const int MIN_MONTH = 1;

void main() {
  testWidgets("Test SharedPreferences", (WidgetTester tester) async {
    Future<SharedPreferences> _prefsFuture = SharedPreferences.getInstance();
    SharedPreferences _prefs = await _prefsFuture;
    // var lastDay = _prefs.getString(LAST_DAY) ?? "";
    // print("#lastDay $lastDay");
    String lastDay = await SharePreferenceManager().getLastDay();
    print("#lastDay $lastDay");
  });
}
