import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';

class BecomeHostScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BecomeHostScreenController>(() => BecomeHostScreenController());
    // Get.lazyPut<SellerEditProfileController>(() => SellerEditProfileController());
  }
}
