import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/top_listeners_view_all/controller/top_listeners_view_all_controller.dart';

class TopListenersViewAllBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopListenersViewAllController>(() => TopListenersViewAllController());
  }
}
