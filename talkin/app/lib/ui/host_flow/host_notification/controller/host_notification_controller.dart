import 'dart:developer';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_notification/api/host_notification_api.dart';
import 'package:talk_in/ui/host_flow/host_notification/api/host_notification_clear_api.dart';
import 'package:talk_in/ui/host_flow/host_notification/model/host_notification_clear_model.dart';
import 'package:talk_in/ui/host_flow/host_notification/model/host_notification_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class HostNotificationController extends GetxController {
  bool isLoading = false;
  HostNotificationModel? hostNotificationModel;
  HostNotificationClearModel? hostNotificationClearModel;
  List<Notification> hostNotificationList = [];

  @override
  void onInit() {
    getNotificationListener();
    super.onInit();
  }

  /// get notification listener
  Future<void> getNotificationListener() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      hostNotificationList.clear();

      hostNotificationModel = await HostNotificationApi.callApi();
      final fetchedList = hostNotificationModel?.notification ?? [];

      hostNotificationList.addAll(fetchedList);

      log("Fetched notifications: ${fetchedList.length}");
    } catch (e) {
      log("Error fetching notifications: $e");
      Utils.showToast(Get.context!, "Failed to fetch notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// clear notification listener
  Future<void> clearNotificationListener() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      hostNotificationClearModel = await HostNotificationClearApi.callApi();

      if (hostNotificationClearModel?.status == true) {
        hostNotificationList.clear(); // Clear UI immediately
        update([Constant.idUserNotification]);

        await getNotificationListener(); // Wait for fresh data

        Utils.showToast(
          Get.context!,
          hostNotificationClearModel?.message ?? "Notification history cleared.",
        );
      } else {
        Utils.showToast(
          Get.context!,
          hostNotificationClearModel?.message ?? "Notification history not found.",
        );
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Error clearing notifications.");
      log("Clear error: $e");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// refresh
  Future<void> onRefresh() async {
    await getNotificationListener();
  }
}
