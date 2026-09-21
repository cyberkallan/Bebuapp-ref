import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/app_language_screen/controller/app_language_screen_controller.dart';

class AppLanguageScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppLanguageScreenController>(() => AppLanguageScreenController());
  }
}
