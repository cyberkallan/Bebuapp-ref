import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/user_notification/api/notification_clear_api.dart';
import 'package:talk_in/ui/user_flow/user_notification/api/user_notification_api.dart';
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_clear_model.dart';
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationController extends GetxController {
  bool isLoading = false;
  UserNotificationModel? userNotificationModel;
  NotificationClearModel? notificationClearModel;
  List<Notification> notificationList = [];

  @override
  void onInit() {
    getNotificationUser();
    super.onInit();
  }

  /// get user notification
  Future<void> getNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      userNotificationModel = await UserNotificationApi.callApi();
      notificationList.clear();
      notificationList.addAll(userNotificationModel?.notification ?? []);
    } catch (e) {
      Utils.showToast(Get.context!, "Failed to fetch notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// clear user notification
  Future<void> clearNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      notificationClearModel = await NotificationClearApi.callApi();

      if (notificationClearModel?.status == true) {
        notificationList.clear(); // Clear UI list immediately
        update([Constant.idUserNotification]);

        await getNotificationUser(); // Ensure this completes after clear

        Utils.showToast(
          Get.context!,
          notificationClearModel?.message ?? "Notification history cleared.",
        );
      } else {
        Utils.showToast(
          Get.context!,
          notificationClearModel?.message ?? "Notification history not found.",
        );
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Failed to clear notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// refresh
  Future<void> onRefresh() async {
    await getNotificationUser();
  }
}
