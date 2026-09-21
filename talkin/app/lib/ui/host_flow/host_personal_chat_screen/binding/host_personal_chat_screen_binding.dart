import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';

class HostPersonalChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostPersonalChatScreenController>(() => HostPersonalChatScreenController());
  }
}
