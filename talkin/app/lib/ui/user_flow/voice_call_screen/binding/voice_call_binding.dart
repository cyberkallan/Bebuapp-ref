import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';

class VoiceCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoiceCallController>(() => VoiceCallController());
  }
}
