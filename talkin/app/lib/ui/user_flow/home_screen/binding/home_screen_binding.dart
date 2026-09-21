import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
    // Get.lazyPut<VideoCallController>(() => VideoCallController());
    // Get.lazyPut<SearchScreenController>(() => SearchScreenController());
  }
}
