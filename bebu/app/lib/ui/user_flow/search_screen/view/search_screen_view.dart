import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/recent_listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/search_screen/controller/search_screen_controller.dart';
import 'package:talk_in/ui/user_flow/search_screen/widget/search_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class SearchScreenView extends StatelessWidget {
  const SearchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchScreenController>(
      init: SearchScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.lightPurple,
          body: SafeArea(
            child: Column(
              children: [
                const SearchTopView().paddingOnly(top: 0, bottom: 15),
                Expanded(
                  child: controller.hasText
                      ? controller.displayedListeners.isEmpty
                          ? Center(
                              child: Image.asset(AppAsset.noListenerFound).paddingAll(80),
                            )
                          : ListView.builder(
                              itemCount: controller.displayedListeners.length,
                              itemBuilder: (context, index) {
                                final listener = controller.displayedListeners[index];
                                return Column(
                                  children: [
                                    RecentListeners(
                                      onTap: () async {
                                        // Step 1: Get existing search data list
                                        List<String> currentSearchHistory = Database.searchData;

                                        final listenerId = listener.id;

                                        if (listenerId != null && listenerId.isNotEmpty) {
                                          // Step 2: Avoid duplicates and update list
                                          currentSearchHistory.remove(listenerId);
                                          currentSearchHistory.insert(0, listenerId);

                                          // Step 3: Limit list size if needed
                                          if (currentSearchHistory.length > 10) {
                                            currentSearchHistory = currentSearchHistory.sublist(0, 10);
                                          }

                                          // Step 4: Store updated list
                                          await Database.onSetSearchDataStore(currentSearchHistory);

                                          //  Step 5: Print stored list to verify
                                          Utils.showLog("Search History Updated: ${Database.searchData}");
                                        }
                                        // Step 6: Navigate to profile
                                        Get.toNamed(
                                          AppRoutes.profileDetailScreenView,
                                          arguments: listener.id,
                                        );
                                      },
                                      callCount: listener.callCount.toString(),
                                      language: listener.language?[0].toString() ?? '',
                                      name: listener.name ?? '',
                                      age: listener.age.toString(),
                                      image: listener.image ?? '',
                                      status: listener.statusLabel ?? '',
                                    ),
                                    Divider(
                                      color: AppColors.lightGrey,
                                      height: 0,
                                    ).paddingSymmetric(vertical: 14),
                                  ],
                                );
                              },
                            )
                      : RecentListenersSearchView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
