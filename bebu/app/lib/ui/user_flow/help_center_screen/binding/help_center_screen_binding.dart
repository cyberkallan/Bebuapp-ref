import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/controller/help_center_screen_controller.dart';

class HelpCenterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterScreenController>(() => HelpCenterScreenController());
  }
}
