import 'package:intl/intl.dart';

extension IntExtension on int {
  String formatPointNumber(){
    var numberFormat = NumberFormat("#,###");
    return numberFormat.format(this);
  }
}