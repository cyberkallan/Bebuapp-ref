import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/controller/host_request_sent_successfully_controller.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';

class HostRequestSentSuccessfullyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostRequestSentSuccessfullyController>(() => HostRequestSentSuccessfullyController());
    Get.lazyPut<BecomeHostScreenController>(() => BecomeHostScreenController());
    Get.lazyPut<HostVerificationController>(() => HostVerificationController());
  }
}
