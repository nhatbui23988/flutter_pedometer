// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as chart;

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyStateApp();
  }
}

class MyStateApp extends State<MyApp> {
  // List<chart.chart.Series<>>

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is my first app"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        height: 500,
        padding: EdgeInsets.all(32.0),
        child: chart.BarChart(_generateSimpleData(), animate: false,),
      ),
    );
  }

  List<chart.Series<SimpleData, String>> _generateSimpleData() {
    final data = [
      SimpleData("2014", 45),
      SimpleData("2014", 35),
      SimpleData("2015", 5),
      SimpleData("2016", 75),
      SimpleData("2017", 45),
      SimpleData("2018", 55),
    ];

    return [
      chart.Series<SimpleData, String>(
          id: "Data",
          colorFn: (SimpleData data, __) {
            if(data.year == "2018"){
              return chart.MaterialPalette.green.shadeDefault;
            } else return chart.MaterialPalette.blue.shadeDefault;
          },
          // display name, work như ID, nếu trong list data có 1 data cùng domainFn thì sẽ lấy data mới nhất đc add vào
          domainFn: (SimpleData data, _) => "Year ${data.year}",
          measureFn: (SimpleData data, _) => data.value,
          data: data)
    ];
  }
}

class SimpleData {
  final String year;
  final int value;

  const SimpleData(this.year, this.value);
}