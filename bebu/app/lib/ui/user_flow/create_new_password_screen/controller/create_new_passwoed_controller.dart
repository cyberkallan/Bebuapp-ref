import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/api/forgot_password_api.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/model/forgot_password_response_model.dart';
import 'package:talk_in/utils/utils.dart';

class CreateNewPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  TextEditingController passwordCnt = TextEditingController();
  TextEditingController confirmPasswordCnt = TextEditingController();
  String? email;
  bool isObscure = true;
  bool isObscure1 = true;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments ?? '';
    log("Received Email: $email");
  }

  void onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  void onClickObscure1() {
    log("isObscure1 :: $isObscure1");
    isObscure1 = !isObscure1;
    update();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter confirm password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (value != passwordCnt.text) return 'Passwords do not match';
    return null;
  }

  ForgotPasswordResponseModel? forgotPasswordResponseModel;
  bool isLoading = false;

  Future<void> handleForgotPassword() async {
    String password = passwordCnt.text.trim();
    String confirmPassword = confirmPasswordCnt.text.trim();

    if (password.length < 6 || confirmPassword.length < 6) {
      Utils.showToast(Get.context!, "Passwords must be at least 6 characters.");
      return;
    }

    if (password != confirmPassword) {
      Utils.showToast(Get.context!, "Passwords do not match.");
      return;
    }

    if (!formKey.currentState!.validate()) return;

    try {
      Get.dialog(LoadingWidget(), barrierDismissible: false);

      final response = await ForgotPasswordApi.callApi(
        email: email.toString(),
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      forgotPasswordResponseModel = response;
      update();

      Get.close(3);

      if (response != null && response.status == true) {
        Utils.showToast(Get.context!, forgotPasswordResponseModel?.message ?? '');
      } else {
        Utils.showToast(Get.context!, forgotPasswordResponseModel?.message ?? "Something went wrong");
      }
    } catch (e) {
      Get.back();
      update();
      Utils.showLog("Error in handleForgotPassword: $e");
      Utils.showToast(Get.context!, "An unexpected error occurred. Please try again.");
    }
  }
}
