import 'package:charts_flutter/flutter.dart' as chart;
import 'package:count_step_tracking/extensions/DoubleExtension.dart';
import 'package:count_step_tracking/utils/AppColors.dart';
import 'package:count_step_tracking/utils/AppImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  MyStateApp createState() {
    return MyStateApp();
  }
}

class MyStateApp extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _currentSteps = 600;
  double _maxTargetSteps = 4000;
  double _spacingHorizontal = 20;
  Color _progressBarColor = Colors.blueGrey;
  double _currentPercentValue = 0;
  String _title = "Step Count";
  List<int> _listTarget = [500, 2000, 4000];

  @override
  void initState() {
    _currentPercentValue = _currentSteps / _maxTargetSteps;
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_title),
          backgroundColor: Colors.green,
          centerTitle: true),
      body: Column(
        children: [
          _buildTodayStepsCount(),
          Divider(),
          _buildStepsCountProgress(),
          Divider(),
          _buildTabBar(),
          SizedBox(height: 20),
          _buildTabView()
        ],
      ),
    );
  }

  Widget _buildTabBar() => Center(
      child: Container(
          height: 36,
          margin: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(
              25.0,
            ),
          ),
          child: TabBar(
              indicatorPadding: EdgeInsets.all(0),
              labelPadding: EdgeInsets.all(0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: Colors.green,
              ),
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              controller: _tabController,
              tabs: [
                Tab(text: "Ngày"),
                Tab(text: "Tuần"),
                Tab(text: "Tháng"),
              ])));

  Widget _buildTabView() => Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStepCountChart(_generateSimpleData()),
            _buildStepCountChart(_generateSimpleData()),
            _buildStepCountChart(_generateSimpleData()),
          ],
        ),
      );

  Widget _buildTodayStepsCount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _spacingHorizontal),
      height: kToolbarHeight,
      color: Colors.white,
      child: Row(
        children: [
          Image(
            image: ImageUtils.ic_step,
            height: 30,
            width: 30,
            color: Colors.green,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            "Today",
            style: TextStyle(
              fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.green,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            "${_currentSteps.formatPointNumber()}",
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 2,
          ),
          Text(
            "/",
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 2,
          ),
          Text(
            "${_maxTargetSteps.formatPointNumber()}",
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 3,
          ),
          Text(
            "steps",
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCountProgress() {
    return LayoutBuilder(
      builder: (buildContext, constraints) => Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        height: kToolbarHeight,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  _buildTextTargetValue(constraints.maxWidth, 500),
                  _buildTextTargetValue(constraints.maxWidth, 2000),
                  _buildTextTargetValue(constraints.maxWidth, 3000),
                ],
              ),
            ),
            SizedBox(height: 3),
            Container(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  _buildTargetDivider(constraints.maxWidth, 500),
                  _buildTargetDivider(constraints.maxWidth, 2000),
                  _buildTargetDivider(constraints.maxWidth, 3000),
                  _buildProgressBar(),
                  _buildCurrentProgressBar(
                      constraints.maxWidth * _currentPercentValue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() => Container(
        margin: EdgeInsets.symmetric(horizontal: _spacingHorizontal),
        height: 20,
        decoration: ShapeDecoration(
            color: _progressBarColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)))),
      );

  Widget _buildCurrentProgressBar(double currentWidth) => Container(
      margin: EdgeInsets.symmetric(horizontal: _spacingHorizontal),
      width: currentWidth,
      height: 20,
      decoration: BoxDecoration(
          gradient: AppColors.barGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _progressBarColor, width: 2),
          shape: BoxShape.rectangle));

  Widget _buildTargetDivider(double maxWidth, int targetValue) => Container(
        margin:
            EdgeInsets.only(left: maxWidth * (targetValue / _maxTargetSteps)),
        height: 28,
        width: 2,
        color: _progressBarColor,
      );

  Widget _buildTextTargetValue(double maxWidth, int targetValue) {
    double textSize = 14;
    var textLength = targetValue.toString().length;
    var textSpacing = (textLength / 2) * (textSize / 2);
    return Container(
      margin: EdgeInsets.only(
          left: maxWidth * (targetValue / _maxTargetSteps) - textSpacing),
      child: Text(
        "$targetValue",
        style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            decoration: TextDecoration.none),
      ),
    );
  }

  Widget _buildStepCountChart(List<chart.Series<SimpleData, String>> listData) => Container(padding: EdgeInsets.symmetric(horizontal: _spacingHorizontal, vertical: _spacingHorizontal), child: chart.BarChart(listData, animate: false,),);

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
            if (data.time == "2018") {
              return chart.MaterialPalette.green.shadeDefault;
            } else
              return chart.MaterialPalette.blue.shadeDefault;
          },
          // display name, work như ID, nếu trong list data có 1 data cùng domainFn thì sẽ lấy data mới nhất đc add vào
          domainFn: (SimpleData data, _) => "Year ${data.time}",
          measureFn: (SimpleData data, _) => data.value,
          data: data)
    ];
  }
}

class SimpleData {
  final String time;
  final int value;

  const SimpleData(this.time, this.value);
}
