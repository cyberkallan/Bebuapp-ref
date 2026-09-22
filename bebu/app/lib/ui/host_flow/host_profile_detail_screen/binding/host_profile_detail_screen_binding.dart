import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_profile_detail_screen/controller/host_profile_detail_screen_controller.dart';

class HostProfileDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostProfileDetailScreenController>(() => HostProfileDetailScreenController());
  }
}
