import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_chat_list_search_screen/controller/host_chat_list_search_controller.dart';

class HostChatListSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostChatListSearchController>(() => HostChatListSearchController());
  }
}
