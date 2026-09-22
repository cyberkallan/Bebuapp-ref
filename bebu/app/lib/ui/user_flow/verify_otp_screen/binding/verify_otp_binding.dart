import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/controller/mobile_number_controller.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/controller/verify_otp_controller.dart';

class VerifyOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    Get.lazyPut<MobileNumberController>(() => MobileNumberController());
    Get.lazyPut<MainScreenController>(() => MainScreenController());
  }
}
