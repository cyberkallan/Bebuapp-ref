import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/widget/bottom_bar_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  /// Tabs that were redesigned on the dark theme and draw their own bottom
  /// padding; the nav bar floats over them. Legacy tabs keep a reserved slot.
  static const _darkTabs = {0, 1, 2, 3};

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        final dark = _darkTabs.contains(logic.selectIndex);
        Utils.onChangeStatusBar(brightness: dark ? Brightness.light : Brightness.dark);
        return Scaffold(
          backgroundColor: dark ? BebuTheme.bg : AppColors.white,
          extendBody: dark,
          bottomNavigationBar: const BottomBarView(),
          body: AnimatedSwitcher(
            duration: BebuTheme.normal,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(logic.selectIndex),
              child: logic.pages[logic.selectIndex],
            ),
          ),
        );
      },
    );
  }
}
