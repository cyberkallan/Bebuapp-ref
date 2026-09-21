import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/controller/host_chat_screen_controller.dart';

class HostChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostChatScreenController>(() => HostChatScreenController());
  }
}
