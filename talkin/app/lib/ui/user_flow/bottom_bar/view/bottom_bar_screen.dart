import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/widget/bottom_bar_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        // Every tab is themed and draws its own bottom padding; the nav bar floats over them.
        Utils.onChangeStatusBar(brightness: Brightness.light);
        return Scaffold(
          backgroundColor: BebuTheme.bg,
          extendBody: true,
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
