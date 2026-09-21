import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';

class ChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatScreenController>(() => ChatScreenController());
  }
}
