import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/api/delete_listener_api.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/api/notification_update_api.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/model/delete_listener_response_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HostSettingController extends GetxController {
  bool isShowNotification = Database.fetchListenerProfileModel?.data?.isNotificationEnabled ?? false;
  FetchListenerProfileModel? fetchListenerProfileModel;
  DeleteListenerResponseModel? deleteListenerResponseModel;

  /// notification switch
  void onSwitchNotification(bool currentValue) async {
    isShowNotification = currentValue;
    update();

    final notificationUpdateModel = await HostNotificationUpdateApi.callApi(
      listenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
    );

    if (notificationUpdateModel != null && notificationUpdateModel.status == true) {
      isShowNotification = currentValue;
    } else {
      isShowNotification = !currentValue;
    }
    fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
    Database.fetchListenerProfileModel = fetchListenerProfileModel;

    if (fetchListenerProfileModel?.status == false) {
      Utils.showLog(fetchListenerProfileModel?.message ?? "");
    }
    Database.fetchListenerProfileModel?.data?.isNotificationEnabled = isShowNotification;

    update();
  }

  /// user account delete
  Future<void> onDeleteAccount() async {
    Get.back(); // Close Dialog...

    Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

    deleteListenerResponseModel = await DeleteListenerApi.callApi();

    Get.back(); // Stop Loading...

    if (deleteListenerResponseModel?.status ?? false) {
      Database.onLogOut();
      Utils.showLog(deleteListenerResponseModel?.message ?? "User account deleted successfully.");
    }
  }
}
