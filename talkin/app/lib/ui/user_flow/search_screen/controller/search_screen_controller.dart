import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/database.dart';

class SearchScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  bool hasText = false;
  bool isLoading = false;
  TopListenersModel? topListenersModel;
  List<TopListeners>? allListener;
  List<TopListeners> displayedListeners = [];

  @override
  void onInit() {
    super.onInit();
    AllListenersApi.startPagination = 0;

    searchController.addListener(() {
      hasText = searchController.text.isNotEmpty;
      if (hasText) {
        filterListeners(searchController.text); // Trigger filtering on text change
      } else {
        displayedListeners.clear(); // Clear listeners if search is empty
      }
      update(); // Ensure UI updates
    });
    allListeners(); // Fetch all listeners initially
  }

  // Clear the search input and reset the listener list
  void clearText() {
    searchController.clear();
    hasText = false;
    displayedListeners.clear(); // Clear displayed listeners
    update(); // Trigger UI update
  }

  // Fetch all listeners and store them
  allListeners() async {
    try {
      isLoading = true;
      update(); // Trigger UI update to show loader
      var data = await AllListenersApi.callApi(searchString: "All");
      topListenersModel = data;
      allListener = data?.data ?? [];
      log('All listeners fetched: ${allListener?.length}');

      filterListeners(searchController.text); // Apply filter immediately after loading data
    } catch (e) {
      log('Error fetching All Listeners api: $e');
    } finally {
      isLoading = false;
      update(); // Trigger UI update to hide loader
    }
  }

  void filterListeners(String query) {
    if (allListener == null) return;

    log('Filtering for: $query'); // 🔍 Debug log
    displayedListeners =
        allListener!.where((listener) => listener.name != null && listener.name!.toLowerCase().contains(query.toLowerCase())).toList();

    log('Found ${displayedListeners.length} result(s)');
    update(); // 🟢 UI refresh
  }

  List<TopListeners> get recentSearchedListeners {
    final recentIds = Database.searchData;

    if (allListener == null || recentIds.isEmpty) return [];

    return recentIds
        .map((id) {
          return allListener!.firstWhere(
            (listener) => listener.id == id,
            orElse: () => TopListeners(), // Make sure TopListeners has a default constructor
          );
        })
        .where((listener) => listener.id != null && listener.id!.isNotEmpty)
        .toList();
  }
}
