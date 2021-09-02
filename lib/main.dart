import 'dart:async';
import 'package:charts_flutter/flutter.dart' as chart;
import 'package:count_step_tracking/data/AppDatabase.dart';
import 'package:count_step_tracking/data/DataManager.dart';
import 'package:count_step_tracking/extensions/IntExtension.dart';
import 'package:count_step_tracking/model/StepRecord.dart';
import 'package:count_step_tracking/utils/AppColors.dart';
import 'package:count_step_tracking/utils/AppImage.dart';
import 'package:count_step_tracking/utils/DateUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fluttertoast/fluttertoast.dart';

//export PATH="$PATH:/Users/NhatBui/flutter/bin"
//flutter packages pub run build_runner build
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager().initDatabase();
  runApp(MaterialApp(home: StepCountHomePage()));
}

class StepCountHomePage extends StatefulWidget {
  const StepCountHomePage();

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

const int MAX_TARGET_DAILY_STEP = 4000;

class HomePageState extends State<StepCountHomePage>
    with SingleTickerProviderStateMixin {
  /// quản lý số lượng tab và điều hướng tab bar và tab view tương ứng
  late TabController _tabController;
  int _todaySteps = 0;

  // điều chỉnh vị trí thanh divider target lớn nhất
  int _maxDisplayTargetValue = (MAX_TARGET_DAILY_STEP * 0.9).toInt();

  // giá trị nhỏ nhất hiển thị trên thanh progress bar
  int _minDisplayValue = (MAX_TARGET_DAILY_STEP * 0.01).toInt();
  double _spacingHorizontal = 20;

  // màu của progress bar
  Color _progressBarColor = Colors.blueGrey;

  // màu của thanh progress hiện tại
  Gradient _currentProgressBarColor = AppColors.progressBarGradient;
  String _title = "Step Count";

  bool _isLoading = false;
  bool _isEmptyData = true;

  /// các mốc mục tiêu bước
  List<int> _listTarget = [500, 2000, 4000];
  List<StepRecord?> _stepRecordsOfWeek = [];

  // pedometer
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  @override
  void initState() {
    getTodayStepCount();
    _stepRecordsOfWeek = AppDateUtils.generateStepRecordsOfWeek();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    // initPlatformState();
  }

  getTodayStepCount() async {
    var steps = await DataManager().getStepRecordToday();
    setState(() {
      _todaySteps = steps;
    });
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

  /// Tab bar title
  Widget _buildTabBar() => Center(
      child: Container(
          height: 30,
          margin: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: TabBar(
              indicatorPadding: EdgeInsets.all(0),
              labelPadding: EdgeInsets.all(0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  20,
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

  /// Các tab view
  Widget _buildTabView() => Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStepCountChart(_chartDataOfWeek()),
            Container(),
            Container()
          ],
        ),
      );

  /// Hiển thị số bước chân trong ngày (text)
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
            "${_todaySteps.formatPointNumber()}",
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
            "${MAX_TARGET_DAILY_STEP.formatPointNumber()}",
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

  /// Hiển thị số bước chân trong ngày dưới dạng progress bar
  Widget _buildStepsCountProgress() {
    return LayoutBuilder(builder: (buildContext, constraints) {
      var bodyWidth = constraints.maxWidth - _spacingHorizontal * 2;
      return Container(
        margin:
            EdgeInsets.symmetric(vertical: 6, horizontal: _spacingHorizontal),
        height: kToolbarHeight,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Stack(
                children: _listTarget
                    .map((targetValue) =>
                        _buildTextTargetValue(bodyWidth, targetValue))
                    .toList(),
              ),
            )),
            SizedBox(height: 3),
            Container(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  _buildListTargetDivider(bodyWidth, _listTarget),
                  _buildProgressBar(),
                  _buildCurrentProgressBar(
                      bodyWidth, _todaySteps, MAX_TARGET_DAILY_STEP),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Hiển thị mục tiêu số bước chân = progress bar
  Widget _buildProgressBar() => Container(
        height: 20,
        decoration: ShapeDecoration(
            color: _progressBarColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)))),
      );

  /// Hiển thị quá trình bước chân hiện tại
  Widget _buildCurrentProgressBar(
      double bodyWidth, int currentValue, int maxTargetValue) {
    double borderSide = 2;
    int currentStepDisplay = currentValue.compareTo(_minDisplayValue) == 1
        ? currentValue
        : _minDisplayValue;
    var currentWidth =
        bodyWidth * (currentStepDisplay / maxTargetValue) + (borderSide * 2);
    return Container(
        width: currentWidth,
        height: 20,
        decoration: BoxDecoration(
            gradient: _currentProgressBarColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _progressBarColor, width: borderSide),
            shape: BoxShape.rectangle));
  }

  /// Hiển thị các mốc mục tiêu
  Widget _buildListTargetDivider(double bodyWidth, List<int> listTargetValue) {
    return Stack(
        children: listTargetValue
            .map((targetValue) => _buildTargetDivider(bodyWidth, targetValue))
            .toList());
  }

  /// Mốc mục tiêu
  Widget _buildTargetDivider(double bodyWidth, int targetValue) {
    if (targetValue > _maxDisplayTargetValue)
      targetValue = _maxDisplayTargetValue;
    return Container(
      margin: EdgeInsets.only(
          left: bodyWidth * (targetValue / MAX_TARGET_DAILY_STEP)),
      height: 28,
      width: 2,
      color: _progressBarColor,
    );
  }

  /// Text thể hiện giá trị mục tiêu
  Widget _buildTextTargetValue(double bodyWidth, int targetValue) {
    double textSize = 14;
    int displayValue = (targetValue.compareTo(_maxDisplayTargetValue) == 1)
        ? _maxDisplayTargetValue
        : targetValue;
    var textLength = targetValue.toString().length;
    var textSpacing = (textLength / 2) * (textSize / 2);
    return Container(
      margin: EdgeInsets.only(
          left:
              bodyWidth * (displayValue / MAX_TARGET_DAILY_STEP) - textSpacing),
      child: Text(
        "$targetValue",
        style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            decoration: TextDecoration.none),
      ),
    );
  }

  /// Hiển thị quá trình số bước chân dạng Chart
  Widget _buildStepCountChart(
          List<chart.Series<StepRecord?, String>> listData) =>
      Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: _spacingHorizontal, vertical: _spacingHorizontal),
            child: chart.BarChart(
              listData,
              animate: false,
            ),
          ),
          Visibility(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  "Data is empty",
                  style: TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.none,
                      color: Colors.black),
                ),
              ),
            ),
            visible: _isEmptyData,
          ),
          Visibility(
            child: Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            visible: _isLoading,
          )
        ],
      );

  List<chart.Series<StepRecord?, String>> _chartDataOfWeek() {
    var today = DateTime.now();
    return [
      chart.Series<StepRecord?, String>(
          id: "Data",
          colorFn: (StepRecord? data, __) {
            if (data?.day == today.day) {
              return chart.MaterialPalette.green.shadeDefault;
            } else
              return chart.MaterialPalette.blue.shadeDefault;
          },
          // vừa là display name, vừa là ID,
          // nếu trong list data có 1 data cùng domainFn thì data add sau sẽ thực hiện ghi đè lên data cũ có cùng domainFn
          domainFn: (StepRecord? data, index) =>
              "${AppDateUtils.getDayName(index != null ? index + 1 : 0)}",
          // giá trị để hiển thị ( display value)
          measureFn: (StepRecord? data, _) => data?.count,
          data: _stepRecordsOfWeek)
    ];
  }

  /// pedometer
  Future<void> initPlatformState() async {
    /// Init streams
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    /// Listen to streams and handle errors
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  void onStepCount(StepCount event) {
    int steps = event.steps;
    setState(() async {
      _todaySteps = steps;
      _isLoading = true;
      _stepRecordsOfWeek = await DataManager().getStepRecordOfWeek();
      _isEmptyData = _stepRecordsOfWeek.isEmpty;
      _isLoading = false;
    });
    DataManager().updateStepRecord(_todaySteps);
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    /// Handle status changed
    String status = event.status;
    // Fluttertoast.showToast(msg: status);
  }

  void onPedestrianStatusError(error) {
    Fluttertoast.showToast(msg: error.toString());
  }

  void onStepCountError(error) {
    Fluttertoast.showToast(msg: error.toString());
    setState(() async {
      _stepRecordsOfWeek = await DataManager().getStepRecordOfWeek();
    });
  }
}
