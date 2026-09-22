import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_profile_screen/controller/host_profile_screen_controller.dart';

class HostProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostProfileScreenController>(() => HostProfileScreenController());
  }
}
