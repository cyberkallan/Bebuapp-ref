import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

/// Floating frosted pill navigation, like the reference design.
///
/// The active item is a white circle that slides between slots; inactive
/// items are quiet glyphs. Sits above page content (`extendBody: true`).
class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, EnumLocale.txtHome.name.tr),
      _NavItem(Icons.explore_rounded, Icons.explore_outlined, EnumLocale.txtListener.name.tr),
      _NavItem(Icons.shuffle_rounded, Icons.shuffle_rounded, EnumLocale.txtRandomCall.name.tr),
      _NavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, EnumLocale.txtChat.name.tr),
      _NavItem(Icons.call_rounded, Icons.call_outlined, EnumLocale.txtCalling.name.tr),
    ];

    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: height,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BebuTheme.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BebuTheme.border),
                    boxShadow: [BoxShadow(color: Color(BebuTheme.isLight ? 0x22000000 : 0x66000000), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final slot = c.maxWidth / items.length;
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: BebuTheme.normal,
                            curve: Curves.easeOutBack,
                            left: logic.selectIndex * slot,
                            top: 0,
                            bottom: 0,
                            width: slot,
                            child: Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: BebuTheme.text,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: BebuTheme.text.withValues(alpha: 0.25), blurRadius: 18)],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < items.length; i++)
                                Expanded(
                                  child: Semantics(
                                    button: true,
                                    selected: i == logic.selectIndex,
                                    label: items[i].label,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => logic.onClick(i),
                                      child: Center(
                                        child: AnimatedScale(
                                          scale: i == logic.selectIndex ? 1.08 : 1,
                                          duration: BebuTheme.normal,
                                          curve: Curves.easeOutBack,
                                          child: AnimatedSwitcher(
                                            duration: BebuTheme.fast,
                                            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                                            child: Icon(
                                              i == logic.selectIndex ? items[i].active : items[i].inactive,
                                              key: ValueKey('$i-${i == logic.selectIndex}'),
                                              size: 23,
                                              color: i == logic.selectIndex ? BebuTheme.bg : BebuTheme.textFaint,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem(this.active, this.inactive, this.label);
  final IconData active;
  final IconData inactive;
  final String label;
}
