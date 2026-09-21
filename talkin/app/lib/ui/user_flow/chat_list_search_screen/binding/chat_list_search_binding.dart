import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/chat_list_search_screen/controller/chat_list_search_controller.dart';

class ChatListSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListSearchController>(() => ChatListSearchController());
  }
}
