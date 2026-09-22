import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/controller/host_calling_screen_controller.dart';

class HostCallingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostCallingScreenController>(() => HostCallingScreenController());
  }
}
