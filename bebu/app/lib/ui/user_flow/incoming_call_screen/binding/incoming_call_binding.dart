import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/incoming_call_screen/controller/incoming_call_controller.dart';

class IncomingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomingCallController>(() => IncomingCallController());
  }
}
