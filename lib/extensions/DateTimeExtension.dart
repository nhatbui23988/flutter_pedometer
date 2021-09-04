
extension DateTimeExtension on DateTime{
  String toId(){
    return "${this.day}${this.month}${this.year}";
  }
}