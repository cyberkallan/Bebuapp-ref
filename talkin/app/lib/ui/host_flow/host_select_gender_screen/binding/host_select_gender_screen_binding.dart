import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_select_gender_screen/controller/host_select_gender_screen_controller.dart';

class HostSelectGenderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostSelectGenderScreenController>(() => HostSelectGenderScreenController());
  }
}
