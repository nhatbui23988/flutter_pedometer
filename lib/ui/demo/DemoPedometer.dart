import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyStateApp();
  }
}

class MyStateApp extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _text = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: Center(child: Text(_text),),);
  }

  void onStepCount(StepCount event) {
    print("###onStepCount");
    /// Handle step count changed
    int steps = event.steps;
    setState(() {
      _text = "$steps";
    });
    print("#1 steps: $steps");
    DateTime timeStamp = event.timeStamp;
    print("#2 timeStamp: $timeStamp");
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print("###onPedestrianStatusChanged");
    /// Handle status changed
    String status = event.status;
    print("#1 status: $status");
    DateTime timeStamp = event.timeStamp;
    print("#2 timeStamp: $timeStamp");
  }

  void onPedestrianStatusError(error) {
    print("###onPedestrianStatusError");
    print("#error: $error");
    setState(() {
      _text = "$error";
    });
    /// Handle the error
  }

  void onStepCountError(error) {
    print("###onStepCountError");
    print("#error: $error");
    setState(() {
      _text = "$error";
    });
    /// Handle the error
  }

  Future<void> initPlatformState() async {
    print("initPlatformState");
    print("#1 Init streams");
    /// Init streams
    _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    _stepCountStream = await Pedometer.stepCountStream;

    print("#2 Listen to streams and handle errors");
    /// Listen to streams and handle errors
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

  }
}
