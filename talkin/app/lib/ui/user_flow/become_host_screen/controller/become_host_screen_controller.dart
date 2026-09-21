import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/api/listeners_request_check_api.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/model/listeners_request_check_model.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/api/get_faq_api.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class BecomeHostScreenController extends GetxController {
  FaqModel? faqModel;
  ListenersRequestCheckModel? listenersRequestCheckModel;
  List<Datum> faqList = [];
  bool isLoading = false;
  SettingApiModel? settingApiModel;
  int expandedIndex = -1;

  @override
  void onInit() {
    listenersRequestCheck();
    getFaqData();
    init();
    super.onInit();
  }

  init() async {
    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
  }

  /// get faq
  getFaqData() async {
    try {
      isLoading = true;
      update([Constant.idFAQListeners]); // notify UI
      var data = await GetFaqApi.callApi(category: "Listener");
      faqModel = data;
      faqList = data?.data ?? [];
    } catch (e) {
      log('Error fetching FAQ: $e');
    } finally {
      isLoading = false;
      update([Constant.idFAQListeners]); // notify UI
      // log('FAQ finally');
    }
  }

  /// listeners request check
  listenersRequestCheck() async {
    try {
      isLoading = true;
      update(); // notify UI
      listenersRequestCheckModel = await ListenersRequestCheckApi.callApi();
    } catch (e) {
      log('Error fetching FAQ: $e');
    } finally {
      isLoading = false;
      update(); // notify UI
      // log('Listeners Request check finally');
    }
  }

  // String? getFormattedDate(String? dateStr) {
  //   if (dateStr == null || dateStr.isEmpty) return '';
  //
  //   try {
  //     // Parse the date and time
  //     DateTime parsedDateTime = DateFormat("M/d/yyyy, h:mm:ss a").parse(dateStr);
  //
  //     // Format date and time separately
  //     String date = DateFormat('MM/dd/yyyy').format(parsedDateTime); // You can customize the format
  //     String time = DateFormat('hh:mm:ss a').format(parsedDateTime);
  //
  //     // Return formatted date and time as separate values (without "Date:" and "Time:")
  //     return "$date\n$time"; // No labels, just date and time
  //   } catch (e) {
  //     log('Error parsing date: $e');
  //     return ''; // In case of any error, return an empty string
  //   }
  // }

  Map<String, String> getFormattedDateParts(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return {"date": "", "time": ""};

    try {
      DateTime parsedDateTime = DateFormat("M/d/yyyy, h:mm:ss a").parse(dateStr);
      String date = DateFormat('MM/dd/yyyy').format(parsedDateTime);
      String time = DateFormat('hh:mm:ss a').format(parsedDateTime);

      return {"date": date, "time": time};
    } catch (e) {
      log('Error parsing date: $e');
      return {"date": "", "time": ""};
    }
  }

  void toggleExpanded(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1; // Collapse if already expanded
    } else {
      expandedIndex = index; // Expand new one
    }
    update([Constant.idFAQListeners]);
  }

  /// listener req sent screen refresh
  onRefresh() async {
    listenersRequestCheck();
    update();
  }
}
