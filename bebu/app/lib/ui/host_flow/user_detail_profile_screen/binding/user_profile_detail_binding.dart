import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/controller/user_profile_deatil_controller.dart';

class UserProfileDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileDetailController>(() => UserProfileDetailController());
  }
}
