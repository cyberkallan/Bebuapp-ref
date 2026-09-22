import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';

class HostHomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostHomeScreenController>(() => HostHomeScreenController());
  }
}
