import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}
