import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/controller/outgoing_call_controller.dart';

class OutgoingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutgoingCallController>(() => OutgoingCallController());
  }
}
