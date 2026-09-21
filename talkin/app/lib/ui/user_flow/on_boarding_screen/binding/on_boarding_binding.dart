import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/controller/on_boarding_controller.dart';

class OnBoardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardingController>(() => OnBoardingController());
  }
}
