import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';

class MyProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyProfileScreenController>(() => MyProfileScreenController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
    Get.lazyPut<BecomeHostScreenController>(() => BecomeHostScreenController());
  }
}
