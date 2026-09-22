import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/controller/avatar_studio_controller.dart';

class AvatarStudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AvatarStudioController());
  }
}
