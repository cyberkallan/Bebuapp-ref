import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/controller/host_bottom_bar_controller.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/controller/host_calling_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/controller/host_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';
import 'package:talk_in/ui/host_flow/host_profile_screen/controller/host_profile_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_wallet_screen/controller/host_wallet_screen_controller.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';

class HostBottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostBottomBarController>(() => HostBottomBarController());
    Get.lazyPut<HostHomeScreenController>(() => HostHomeScreenController(), fenix: true);
    Get.lazyPut<HostCallingScreenController>(() => HostCallingScreenController(), fenix: true);
    Get.lazyPut<HostChatScreenController>(() => HostChatScreenController(), fenix: true);
    Get.lazyPut<HostWalletScreenController>(() => HostWalletScreenController());
    Get.lazyPut<HostProfileScreenController>(() => HostProfileScreenController(), fenix: true);
    Get.lazyPut<HostListenersDetailController>(() => HostListenersDetailController(), fenix: true);
    Get.lazyPut<HostVerificationController>(() => HostVerificationController(), fenix: true);
  }
}
