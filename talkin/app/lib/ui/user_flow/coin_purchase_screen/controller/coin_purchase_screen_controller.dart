import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/utils/database.dart';

class CoinPurchaseScreenController extends GetxController {
  String? date;
  String? amountPaid;
  String? paymentMode;
  String? transactionId;

  /// Coins bought in this purchase (0 when the gateway did not tell us).
  int coinsAdded = 0;

  /// Balance before/after, for the count-up on the celebration screen.
  int previousBalance = 0;
  int newBalance = 0;

  @override
  void onInit() {
    Map<String, dynamic> data = Get.arguments ?? {};

    log("purchase coin plan arguments :: $data");

    date = formatToCustomDate("${data['date']?.toString()}");
    amountPaid = data['amount']?.toString();
    paymentMode = data['paymentMode']?.toString();
    transactionId = data['transactionId']?.toString();

    coinsAdded = _asInt(data['coins']);
    newBalance = data['balance'] != null ? _asInt(data['balance']) : (int.tryParse(Database.userCoin) ?? 0);
    previousBalance = data['previousBalance'] != null ? _asInt(data['previousBalance']) : (newBalance - coinsAdded).clamp(0, newBalance);
    if (coinsAdded == 0 && newBalance > previousBalance) coinsAdded = newBalance - previousBalance;

    super.onInit();
  }

  static int _asInt(dynamic v) => v is num ? v.round() : int.tryParse(v?.toString() ?? '') ?? 0;

  String formatToCustomDate(String input) {
    try {
      final inputFormat = DateFormat("M/d/y, h:mm:ss a");
      final dateTime = inputFormat.parse(input);
      return DateFormat("d MMM y · h:mm a").format(dateTime);
    } catch (e) {
      return DateFormat("d MMM y · h:mm a").format(DateTime.now());
    }
  }
}
