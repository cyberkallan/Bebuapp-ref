import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart';

class HostSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostSettingController>(() => HostSettingController());
  }
}
