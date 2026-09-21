import 'dart:developer';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/payment/api/purchase_coin_plan_api.dart';
import 'package:talk_in/payment/flutter_wave/flutter_wave_services.dart';
import 'package:talk_in/payment/in_app_purchase/iap_callback.dart';
import 'package:talk_in/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:talk_in/payment/razor_pay/razor_pay_service.dart';
import 'package:talk_in/payment/stripe/stripe_service.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/api/fetch_coin_plan_api.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/purchase_coin_plan.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class MyWalletController extends GetxController implements IAPCallback {
  FetchCoinPlan? fetchCoinPlan;
  List<CoinPlan> coinPlan = [];
  bool isLoading = false;
  int selectedPaymentMethod = -1;
  PurchaseCoinPlan? purchaseCoinPlan;
  UserCoinModel? userCoinModel;
  // String productKey = '';
  Map<String, PurchaseDetails>? purchases;
  CoinPlan? selectedCoinPlan;

  @override
  void onInit() {
    fetchCoinPlanList();
    super.onInit();
  }

  /// fetch coin plan
  Future<void> fetchCoinPlanList() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    isLoading = true;
    update([Constant.idGetCoinPlan]);

    fetchCoinPlan = await FetchCoinPlanApi.callApi(
      uid: uid,
      token: token,
    );
    coinPlan.clear();
    coinPlan.addAll(fetchCoinPlan?.data ?? []);

    isLoading = false;
    update([Constant.idGetCoinPlan]);
  }

  /// change payment method
  void onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    update([Constant.onChangePaymentMethod]);
  }

  /// payment method condition
  Future<void> onClickPayNow({required String id, required num amount, required String productKey}) async {
    if (selectedPaymentMethod == -1) {
      Utils.showToast(Get.context!, EnumLocale.txtSelectPaymentMethod.name.tr);
    }
    if (Database.settingApiModel?.data?.isRazorpayEnabled == true) {
      if (selectedPaymentMethod == 0) {
        await onClickRazorPay(amount, id);
      }
    }
    if (Database.settingApiModel?.data?.isStripeEnabled == true) {
      if (selectedPaymentMethod == 1) {
        await onClickStripe(amount, id);
      }
    }
    if (Database.settingApiModel?.data?.isFlutterwaveEnabled == true) {
      if (selectedPaymentMethod == 2) {
        onClickFlutterWave(amount, id);
      }
    }
    if (Database.settingApiModel?.data?.isGooglePlayEnabled == true) {
      if (selectedPaymentMethod == 3) {
        onClickInAppPurchase(amount, id, productKey);
      }
    }
  }

  /// flutter wave
  Future<void> onClickFlutterWave(num amount, String id) async {
    Utils.showLog("Flutter Wave Payment Working....");
    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
      FlutterWaveService.init(
        context: Get.context!,
        amount: (amount * 100).toString(),
        onPaymentComplete: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("Flutter Wave Payment Successfully");

          Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(coinPlanId: id, paymentGateway: "Stripe", token: token, uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            Get.find<RandomCallController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");

            Utils.showToast(Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("Flutter Wave Payment Failed => $e");
    }
  }

  /// stripe
  Future<void> onClickStripe(num amount, String id) async {
    try {
      Utils.showLog("Stripe Payment Working...");

      Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
      await StripeService().init(isTest: true);
      await 1.seconds.delay();

      StripeService()
          .stripePay(
        amount: (amount * 100).toInt(),
        callback: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("Stripe Payment Success Method Called....");

          Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(coinPlanId: id, paymentGateway: "Stripe", token: token, uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();

            Utils.showToast(Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      )
          .then((value) async {
        Utils.showLog("Stripe Payment Successfully");
      }).catchError((e) {
        Utils.showLog("Stripe Payment Error !!!");
      });
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("Stripe Payment Failed !! => $e");
    }
  }

  /// razor pay
  Future<void> onClickRazorPay(num amount, String id) async {
    Utils.showLog("Razorpay Payment Working....");

    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
      RazorPayService().init(
        razorKey: Database.settingApiModel?.data?.razorpayKeySecret ?? '',
        // razorKey: "rzp_test_SjZz9HC7RGCfCb",
        callback: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("RazorPay Payment Successfully");

          Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(coinPlanId: id, paymentGateway: "RazorPay", token: token, uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);

            Utils.showToast(Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
            Get.toNamed(AppRoutes.coinPurchaseScreen, arguments: {
              "date": purchaseCoinPlan?.historyRecord?.date,
              "amount": purchaseCoinPlan?.historyRecord?.amountPaid,
              "paymentMode": purchaseCoinPlan?.historyRecord?.paymentMode,
              "transactionId": purchaseCoinPlan?.historyRecord?.transactionId,
            });
          } else {
            Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      await 1.seconds.delay();
      RazorPayService().razorPayCheckout((amount * 100).toInt());
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("RazorPay Payment Failed => $e");
    }
  }

  Future<void> onClickInAppPurchase(num amount, String id, String productKey) async {
    List<String> kProductIds = <String>[productKey];

    Utils.showLog("Starting IAP with product: $productKey");

    await InAppPurchaseHelper().init(
      paymentType: "In App Purchase",
      userId: Database.loginUserFirebaseId,
      productKey: kProductIds,
      rupee: amount.toDouble(),
      callBack: () async {
        Utils.showLog("In App Purchase Payment Successfully");
        // This callback is called from InAppPurchaseHelper
        // The actual API call will be made in onSuccessPurchase method below
      },
    );

    // Add debug logging
    await InAppPurchaseHelper().debugProductLoading();

    InAppPurchaseHelper().initStoreInfo();
    await Future.delayed(const Duration(seconds: 3)); // Increased delay

    ProductDetails? product = InAppPurchaseHelper().getProductDetail(productKey);

    if (product != null) {
      Utils.showLog("Product found: ${product.title} - ${product.price}");
      InAppPurchaseHelper().buySubscription(product, purchases!);
    } else {
      Utils.showToast(Get.context!, "Product not found: $productKey");
      Utils.showLog("Available products: ${InAppPurchaseHelper().getAvailableProducts()}");
    }
  }

  onRefresh() async {
    fetchCoinPlanList();
  }

  @override
  void onBillingError(error) {
    Utils.showLog("IAP Billing Error: $error");
    Utils.showToast(Get.context!, "Payment failed: $error");
  }

  @override
  void onLoaded(bool initialized) {
    Utils.showLog("IAP Loaded: $initialized");
  }

  @override
  void onPending(PurchaseDetails product) {
    Utils.showLog("IAP Pending: ${product.productID}");
    Utils.showToast(Get.context!, "Payment is pending...");
  }

  @override
  void onSuccessPurchase(PurchaseDetails product) async {
    Utils.showLog("IAP Success: ${product.productID}");

    try {
      // Show loading dialog
      Get.dialog(const LoadingWidget(), barrierDismissible: false);
      final token = await FirebaseAccessToken.onGet() ?? "";
      final uid = Database.loginUserFirebaseId;

      // Call the API to record the purchase
      // final isSuccess =
      //     await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "In App Purchase");

      final isSuccess = await PurchaseCoinPlanApi.callApi(
          coinPlanId: selectedCoinPlan?.id.toString() ?? '', paymentGateway: "In App Purchase", token: token, uid: uid);

      // Hide loading dialog
      Get.back();

      if (isSuccess?.status == true) {
        Utils.showToast(Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
        Get.close(2); // Close payment screens
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } catch (e) {
      // Hide loading dialog if there's an error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Utils.showLog("API call failed: $e");
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }
}
