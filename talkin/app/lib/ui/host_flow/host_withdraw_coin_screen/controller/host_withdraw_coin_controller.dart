import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/api/payment_option_api.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/api/withdraw_coin_submit_api.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/payment_option_model.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/withdraw_coin_submit_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class HostWithdrawCoinController extends GetxController {
  bool isLoading = false;
  PaymentOptionModel? paymentOptionModel;
  final TextEditingController coinController = TextEditingController();
  bool isShowPaymentMethod = false;
  List<PaymentOption> withdrawMethods = []; // Fill this from your API
  int? selectedPaymentMethod;

  List<TextEditingController> withdrawPaymentDetails = [];
  WithdrawCoinSubmitModel? withdrawCoinSubmitModel;
  @override
  void onInit() {
    onGetWithdrawMethods();
    super.onInit();
  }

  /// get withdraw coin method
  onGetWithdrawMethods() async {
    isLoading = true;
    update([Constant.idPaymentOption]);
    paymentOptionModel = await PaymentOptionApi.callApi(endDate: "All", startDate: "All");

    if (paymentOptionModel?.data != null) {
      withdrawMethods.addAll(paymentOptionModel?.data ?? []);
      isLoading = false;
      update([Constant.idPaymentOption]);
    }
    // paymentOptions = paymentOptionModel?.data ?? [];
    //
    // isLoading = false;
    // update([Constant.idPaymentOption]);
  }

  Future<void> onSwitchWithdrawMethod() async {
    isShowPaymentMethod = !isShowPaymentMethod;
    update();
  }

  Future<void> onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    if (isShowPaymentMethod) {
      onSwitchWithdrawMethod();
    }
    withdrawPaymentDetails = List<TextEditingController>.generate(withdrawMethods[index].details?.length ?? 0, (counter) => TextEditingController());

    update();
  }

  /// validation withdraw coin
  Future<void> onClickWithdraw() async {
    bool isWithdrawDetailsEmpty = false;
    for (int i = 0; i < withdrawPaymentDetails.length; i++) {
      if (withdrawPaymentDetails[i].text.isEmpty) {
        isWithdrawDetailsEmpty = true;
      } else {
        isWithdrawDetailsEmpty = false;
      }
    }

    if (coinController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterWithdrawCoin.name.tr);
    } else if (int.parse(coinController.text) < (Database.settingApiModel?.data?.minimumCoinsForPayout ?? 0)) {
      Utils.showToast(Get.context!, EnumLocale.txtWithdrawalRequestedCoinMustBeGreaterThanSpecifiedByTheAdmin.name.tr);
    } else if (int.parse(coinController.text) > (Database.fetchListenerProfileModel?.data?.currentCoinBalance ?? 0)) {
      Utils.showToast(Get.context!, EnumLocale.txtTheUserDoesNotHaveSufficientFundsToMakeTheWithdrawal.name.tr);
    } else if (selectedPaymentMethod == null) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseSelectWithdrawMethod.name.tr);
    } else if (isWithdrawDetailsEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterAllPaymentDetails.name.tr);
    } else {
      onWithdraw();
    }
  }

  /// withdraw coin api
  Future<void> onWithdraw() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
    Map<String, String> details = {};

    for (int i = 0; i < withdrawMethods[selectedPaymentMethod ?? 0].details!.length; i++) {
      final key = withdrawMethods[selectedPaymentMethod ?? 0].details![i];
      final value = withdrawPaymentDetails[i].text;
      details[key] = value;
    }

    await 1.seconds.delay();

    withdrawCoinSubmitModel = await WithdrawCoinSubmitApi.callApi(
      listenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      coin: coinController.text,
      paymentGateway: withdrawMethods[selectedPaymentMethod ?? 0].name ?? "",
      // paymentDetails: details,
      paymentDetails: details,
    );

    if (withdrawCoinSubmitModel?.status == true) {
      log("withdrawCoinSubmitModel?.status  :: ${withdrawCoinSubmitModel?.status}");
      Utils.showToast(Get.context!, withdrawCoinSubmitModel?.message ?? "");
      Get.back(); // Close Withdraw Page...
    } else {
      Utils.showToast(Get.context!, withdrawCoinSubmitModel?.message ?? "");
      Get.back();
    }

    Get.back(); // Stop Loading / Close Dialog
  }
}
