import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/controller/fill_profile_screen_controller.dart';

class FillProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FillProfileScreenController>(() => FillProfileScreenController());
  }
}
