import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_app_language_screen/controller/host_app_language_screen_controller.dart';

class HostAppLanguageScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostAppLanguageScreenController>(() => HostAppLanguageScreenController());
  }
}
