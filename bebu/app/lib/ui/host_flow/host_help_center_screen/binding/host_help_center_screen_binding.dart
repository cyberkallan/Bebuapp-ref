import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/controller/host_help_center_screen_controller.dart';

class HostHelpCenterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostHelpCenterScreenController>(() => HostHelpCenterScreenController());
  }
}
