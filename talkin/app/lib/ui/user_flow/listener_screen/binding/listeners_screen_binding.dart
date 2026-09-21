import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';

class ListenersScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListenersScreenController>(() => ListenersScreenController());
  }
}
