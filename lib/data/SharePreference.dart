import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAST_DAY = "last_day";
const String LAST_COUNT = "last_count";
const String TODAY_COUNT = "today_count";

class SharePreferenceManager {
  static final SharePreferenceManager instance = SharePreferenceManager.privateConstructor();

  factory SharePreferenceManager() {
    return instance;
  }
  SharePreferenceManager.privateConstructor();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  // base

  // int
  Future<int> getInt(String key) async {
    SharedPreferences prefs = await _prefs;
    return prefs.getInt(key) ?? 0;
  }

  setInt(String key, int value) async {
    SharedPreferences prefs = await _prefs;
    prefs.setInt(key, value);
  }

  // String
  Future<String> getString(String key) async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString(key) ?? "";
  }

  setString(String key, String value) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString(key, value);
  }

  // last day
  Future<String> getLastDay() async {
    return await getString(LAST_DAY);
  }

  setLastDay(String lastDay) async {
    await setString(LAST_DAY, lastDay);
  }

  // last count
  Future<int> getLastCount() async {
    return await getInt(LAST_COUNT);
  }

  setLastCount(int lastCount) async {
    await setInt(LAST_COUNT, lastCount);
  }

  // today count
  Future<int> getTodayCount() async {
    return await getInt(TODAY_COUNT);
  }

  setTodayCount(int todayCount) async {
    await setInt(TODAY_COUNT, todayCount);
  }
}
