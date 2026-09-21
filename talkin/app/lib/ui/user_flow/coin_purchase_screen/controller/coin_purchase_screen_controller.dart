import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CoinPurchaseScreenController extends GetxController {
  String? date;
  String? amountPaid;
  String? paymentMode;
  String? transactionId;

  @override
  void onInit() {
    Map<String, dynamic> data = Get.arguments ?? {};

    log("purchase coin plan arguments :: $data");

    // date = data['date']?.toString();
    date = formatToCustomDate("${data['date']?.toString()}");
    amountPaid = data['amount']?.toString(); // ✅ Convert to string
    paymentMode = data['paymentMode']?.toString();
    transactionId = data['transactionId']?.toString();

    super.onInit();
  }

  String formatToCustomDate(String input) {
    try {
      final inputFormat = DateFormat("M/d/y, h:mm:ss a"); // your original format
      final dateTime = inputFormat.parse(input);

      final outputFormat = DateFormat("d MMM y"); // your desired format
      return outputFormat.format(dateTime); // e.g., 7 Jul 2025
    } catch (e) {
      return "Invalid date";
    }
  }
}
