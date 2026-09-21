// import 'package:intl/intl.dart';
//
// class CustomFormatChatTime {
//   static String convert(String dateTimeString) {
//     DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
//
//     DateTime today = DateTime.now();
//
//     bool isToday = dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day;
//
//     if (isToday) {
//       DateFormat timeFormatter = DateFormat('hh:mm a');
//       return timeFormatter.format(dateTime);
//     } else {
//       DateFormat dateFormatter = DateFormat('dd/MM/yy');
//       return dateFormatter.format(dateTime);
//     }
//   }
// }

import 'package:intl/intl.dart';

class CustomFormatChatTime {
  static String convert(String dateTimeString) {
    if (dateTimeString.isEmpty) {
      return 'Invalid date'; // Return a default value if the date is empty or invalid
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal(); // Parse the date string

      DateTime today = DateTime.now();
      bool isToday = dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day;

      if (isToday) {
        DateFormat timeFormatter = DateFormat('hh:mm a');
        return timeFormatter.format(dateTime);
      } else {
        DateFormat dateFormatter = DateFormat('dd/MM/yy');
        return dateFormatter.format(dateTime);
      }
    } catch (e) {
      // If the date is invalid, return a fallback string
      return 'Invalid date';
    }
  }
}
