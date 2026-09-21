import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/registration_screen/controller/registration_controller.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}
