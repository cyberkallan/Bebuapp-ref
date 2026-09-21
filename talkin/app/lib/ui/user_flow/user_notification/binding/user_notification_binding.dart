import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';

class UserNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserNotificationController>(() => UserNotificationController());
  }
}
