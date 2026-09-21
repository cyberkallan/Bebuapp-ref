import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/controller/fake_video_call_controller.dart';

class FakeVideoCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeVideoCallController>(() => FakeVideoCallController());
  }
}
