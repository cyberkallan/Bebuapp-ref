import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/api/get_faq_api.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:talk_in/utils/constant.dart';

class HelpCenterScreenController extends GetxController {
  FaqModel? faqModel;
  List<Datum> faqList = [];
  bool isLoading = false;

  /// Index of currently expanded tile. `-1` means none is expanded.
  int expandedIndex = -1;

  @override
  void onInit() {
    getFaqData();
    super.onInit();
  }

  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1; // Collapse if same tile tapped
    } else {
      expandedIndex = index; // Expand this and collapse others
    }
    update([Constant.idFAQListeners]);
  }

  /// get faq data
  getFaqData() async {
    try {
      isLoading = true;
      update([Constant.idFAQListeners]);
      var data = await GetFaqApi.callApi(category: "User");
      faqModel = data;
      faqList = data?.data ?? [];
    } catch (e) {
      log('Error fetching FAQ: $e');
    } finally {
      isLoading = false;
      update([Constant.idFAQListeners]);
    }
  }
}
