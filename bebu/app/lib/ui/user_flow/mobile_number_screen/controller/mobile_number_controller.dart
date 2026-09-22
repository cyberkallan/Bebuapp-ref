import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/utils.dart';

class MobileNumberController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  String verificationId = '';
  String? dialCode;

  @override
  void onInit() async {
    numberController.clear();
    super.onInit();
  }

  void sendOtp(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Utils.showToast(context, "Enter a valid mobile number");
      return;
    }

    final number = numberController.text.trim();
    final code = dialCode ?? '+91';
    final phoneNumber = '$code$number';

    if (number.isEmpty) {
      Utils.showToast(context, "Please enter mobile number");
      return;
    }

    if (number.length < 7 || number.length > 15) {
      Utils.showToast(context, "Enter a valid mobile number");
      return;
    }

    try {
      Get.dialog(LoadingWidget(), barrierDismissible: false);

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          // Utils.showToast(Get.context!, "Auto login successful");
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.back();
          Utils.showToast(Get.context!, e.message ?? "OTP sending failed");
        },
        codeSent: (String id, int? resendToken) {
          Get.back();
          verificationId = id;
          Get.toNamed(
            AppRoutes.verifyOtp,
            arguments: [number, code, verificationId],
          );
        },
        codeAutoRetrievalTimeout: (String id) {
          log("Auto-retrieval timeout reached");
          verificationId = id;
          update();
        },
      );
    } catch (e) {
      Get.back();
      Utils.showToast(Get.context!, "OTP process failed: $e");
    }
  }
}
