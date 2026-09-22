import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';

class BottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomBarController>(() => BottomBarController());
    Get.lazyPut<HomeScreenController>(() => HomeScreenController(), fenix: true);
    Get.lazyPut<EditProfileController>(() => EditProfileController(), fenix: true);
    Get.lazyPut<ListenersScreenController>(() => ListenersScreenController(), fenix: true);
    Get.lazyPut<AllListenersController>(() => AllListenersController());
    Get.lazyPut<RandomCallController>(() => RandomCallController(), fenix: true);
    Get.lazyPut<ChatScreenController>(() => ChatScreenController(), fenix: true);
    Get.lazyPut<CallingScreenController>(() => CallingScreenController(), fenix: true);
  }
}
