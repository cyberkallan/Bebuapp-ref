import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';

class CallCutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallCutController>(() => CallCutController());
  }
}
