import 'package:intl/intl.dart';

extension DoubleExtension on double{
  String formatPointNumber(){
    var numberFormat = NumberFormat("#,###");
    return numberFormat.format(this);
  }
}