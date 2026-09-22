import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_review_screen/controller/all_review_controller.dart';

class AllReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllReviewController>(() => AllReviewController());
  }
}
