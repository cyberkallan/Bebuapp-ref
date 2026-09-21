import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/update_random_call_status_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/update_random_call_status_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart' show EnumLocale;
import 'package:talk_in/utils/utils.dart';

class HostHomeScreenController extends GetxController {
  // bool isChatPermission = Database.fetchListenerProfileModel?.data?.isAvailableForChat ?? false;
  bool isAvailableForPrivateAudioCall = Database.fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall ?? false;
  bool isAvailableForPrivateVideoCall = Database.fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall ?? false;
  bool isAvailableForRandomAudioCall = Database.fetchListenerProfileModel?.data?.isAvailableForRandomAudioCall ?? false;
  bool isAvailableForRandomVideoCall = Database.fetchListenerProfileModel?.data?.isAvailableForRandomVideoCall ?? false;
  bool isToastVisible = false;
  UpdateRandomCallStatusModel? updateRandomCallStatusModel;
  final List<String> imageList = [
    AppAsset.homeCallPerson,
    AppAsset.homeCallPerson,
    AppAsset.homeCallPerson,
  ];
  bool isCoinLoading = false;
  int currentIndex = 0;
  FetchListenerProfileModel? fetchListenerProfileModel;
  ListenerCoinModel? listenerCoinModel;
  @override
  void onInit() {
    hostCoin();
    // init();
    super.onInit();
  }

  init() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);
    log("Listener Coin => ${listenerCoinModel?.coin}");
  }

  /// refresh
  onRefresh() async {
    fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
    Database.fetchListenerProfileModel = fetchListenerProfileModel;

    // if (fetchListenerProfileModel != null) {
    //   isAvailableForRandomVideoCall = fetchListenerProfileModel?.data?.isAvailableForRandomVideoCall ?? false;
    // }
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);
    log("Listener Coin => ${listenerCoinModel?.coin}");

    update();
  }

  /// get host coin
  hostCoin() async {
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());

    update([Constant.idGetCoinPlan]);
  }

  /// random call switch permission
  void permissionSwitch(bool currentValue, String status) async {
    log("status=============================$status");

    // Instant UI update
    if (status == "isAvailableForPrivateVideoCall") {
      isAvailableForPrivateVideoCall = currentValue;
    } else if (status == "isAvailableForPrivateAudioCall") {
      isAvailableForPrivateAudioCall = currentValue;
    } else if (status == "isAvailableForRandomVideoCall") {
      isAvailableForRandomVideoCall = currentValue;
    }

    log("isPermission = currentValue=============================$isAvailableForPrivateAudioCall");
    update();

    /// API call to update permission
    final response = await UpdateRandomCallStatusApi.callApi(
      status: status.toString(),
      listenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
    );
    updateRandomCallStatusModel = response;
    // Utils.showToast(Get.context!, updateRandomCallStatusModel?.message ?? "");

    if (response != null && response.status == true) {
      // Success, keep toggled value
      if (status == "isAvailableForPrivateVideoCall") {
        isAvailableForPrivateVideoCall = currentValue;
        if (currentValue == true) {
          Utils.showToast(Get.context!, EnumLocale.txtListenerAvailableForPrivateVideoCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtListenerDisableForPrivateVideoCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        }
      } else if (status == "isAvailableForPrivateAudioCall") {
        isAvailableForPrivateAudioCall = currentValue;

        if (currentValue == true) {
          Utils.showToast(Get.context!, EnumLocale.txtListenerAvailableForPrivateAudioCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtListenerDisableForPrivateAudioCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        }
      } else if (status == "isAvailableForRandomVideoCall") {
        isAvailableForRandomVideoCall = currentValue;

        if (currentValue == true) {
          Utils.showToast(Get.context!, EnumLocale.txtListenerAvailableForRandomVideoCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtListenerDisableForRandomVideoCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        }
      } else if (status == "isAvailableForRandomAudioCall") {
        isAvailableForRandomAudioCall = currentValue;

        if (currentValue == true) {
          Utils.showToast(Get.context!, EnumLocale.txtListenerAvailableForRandomAudioCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtListenerDisableForRandomAudioCall.name.tr, toastLength: Toast.LENGTH_SHORT);
        }
      }
    } else {
      // Failure, revert to previous value
      // isPermission = !currentValue;
      if (status == "isAvailableForPrivateVideoCall") {
        isAvailableForPrivateVideoCall = !currentValue;
      } else if (status == "isAvailableForPrivateAudioCall") {
        isAvailableForPrivateAudioCall = !currentValue;
      } else if (status == "isAvailableForRandomVideoCall") {
        isAvailableForRandomVideoCall = !currentValue;
      } else if (status == "isAvailableForRandomAudioCall") {
        isAvailableForRandomAudioCall = !currentValue;
      }
    }
    fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
    Database.fetchListenerProfileModel = fetchListenerProfileModel;
    if (fetchListenerProfileModel?.status == false) {
      Utils.showLog(fetchListenerProfileModel?.message ?? "");
    }
    fetchListenerProfileModel?.data?.isAvailableForRandomVideoCall = isAvailableForRandomVideoCall;
    fetchListenerProfileModel?.data?.isAvailableForRandomAudioCall = isAvailableForRandomAudioCall;
    fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall = isAvailableForPrivateVideoCall;
    fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall = isAvailableForPrivateAudioCall;

    update();
  }

  /// slider change
  void onPageChanged(int index, CarouselPageChangedReason reason) {
    currentIndex = index;
    update();
  }
}
