import 'package:flutter/cupertino.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class FlutterWaveService {
  static Future<void> init({
    required String amount,
    required Callback onPaymentComplete,
    required BuildContext context,
  }) async {
    final Customer customer = Customer(
      name: "Flutter wave Developer",
      email: Database.fetchLoginUserProfileModel?.user?.email ?? "",
      phoneNumber: Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "",
    );

    final Flutterwave flutterWave = Flutterwave(
      publicKey: Database.settingApiModel?.data?.flutterwavePublicKey ?? "",
      // publicKey: "FLWPUBK_TEST-cdc51a4df113a91fe33a914eaf8d1c75-X",
      currency: Database.settingApiModel?.data?.currency?.currencyCode ?? '',
      redirectUrl: "https://www.google.com/",
      txRef: DateTime.now().microsecond.toString(),
      amount: amount,
      customer: customer,
      paymentOptions: "ussd, card, barter, pay attitude",
      customization: Customization(title: "Heart Haven"),
      isTestMode: true,
    );

    Utils.showLog("Flutter Wave Payment Finish");

    final ChargeResponse response = await flutterWave.charge(context);

    Utils.showLog("Flutter Wave Payment Status => ${response.status.toString()}");

    if (response.success == true) {
      onPaymentComplete.call();
    }
    Utils.showLog("Flutter Wave Response => ${response.toString()}");
  }
}
