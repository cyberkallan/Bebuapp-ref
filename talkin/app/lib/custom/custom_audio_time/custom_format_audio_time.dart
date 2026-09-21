class CustomFormatAudioTime {
  static String convert(int second) {
    int hours = second ~/ 3600;
    int minutes = (second % 3600) ~/ 60;
    int seconds = second % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }
}
