import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    // Get.lazyPut<ProfileScreenController>(() => ProfileScreenController());
  }
}
