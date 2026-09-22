import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:http/http.dart' as http;
import 'package:talk_in/payment/stripe/stripe_pay_model.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class StripeService {
  bool isTest = false;

  init({
    required bool isTest,
  }) async {
    Stripe.publishableKey = Database.settingApiModel?.data?.stripePublicKey ?? '';
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    await Stripe.instance.applySettings().catchError((e) {
      log("Stripe Apply Settings => $e");
      throw e.toString();
    });

    this.isTest = isTest;
  }

  Future<dynamic> stripePay({required int amount, required Callback callback}) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': 'usd',
        'description': 'Name: ${Database.loginUserName} - Email: "${Database.loginUserEmail}"',
      };

      log("Start Payment Intent Http Request.....");

      var response = await http.post(Uri.parse(Database.stripeUrl), body: body, headers: {
        "Authorization": "Bearer ${Database.settingApiModel?.data?.stripeSecretKey ?? ''}",
        "Content-Type": 'application/x-www-form-urlencoded'
      });

      log("Payment Intent Http Response => ${response.body}");

      if (response.statusCode == 200) {
        StripePayModel result = StripePayModel.fromJson(jsonDecode(response.body));

        log("Stripe Payment Response => $result");

        SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          appearance: PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: AppColors.primary)),
          googlePay: PaymentSheetGooglePay(merchantCountryCode: Database.settingApiModel?.data?.currency?.countryCode ?? '', testEnv: isTest),
          merchantDisplayName: Database.loginUserName,
          customerId: Database.loginUserId,
          billingDetails: const BillingDetails(name: "Hello", email: "hello@gmail.com"),
        );

        await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
          await Stripe.instance.presentPaymentSheet().then((value) async {
            log("***** Payment Done *****");
            callback.call();
            Utils.showLog("Stripe Payment Success Method Called....");
            Utils.showLog("Stripe Payment Successfully");
          }).catchError((e) {
            log("Init Payment Sheet Error => $e");
          });
        }).catchError((e) {
          log("Something Went Wrong => $e");
        });
      } else if (response.statusCode == 401) {
        // appStore.setLoading(false);
        log("Error During Stripe Payment");
      }
      return jsonDecode(response.body);
    } catch (e) {
      log('Error Charging User: ${e.toString()}');
    }
  }
}
