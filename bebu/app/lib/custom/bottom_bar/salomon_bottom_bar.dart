import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class SalomonBottomBar extends StatelessWidget {
  /// A bottom bar that faithfully follows the design by Aurélien Salomon
  ///
  /// https://dribbble.com/shots/5925052-Google-Bottom-Bar-Navigation-Pattern/
  const SalomonBottomBar({
    super.key,
    required this.items,
    this.backgroundColor,
    this.currentIndex = 0,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedColorOpacity,
    this.itemShape = const StadiumBorder(),
    this.margin = const EdgeInsets.all(8),
    this.itemPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuint,
  });

  /// A list of tabs to display, ie `Home`, `Likes`, etc
  final List<SalomonBottomBarItem> items;

  /// The tab to display.
  final int currentIndex;

  /// Returns the index of the tab that was tapped.
  final Function(int)? onTap;

  /// The background color of the bar.
  final Color? backgroundColor;

  /// The color of the icon and text when the item is selected.
  final Color? selectedItemColor;

  /// The color of the icon and text when the item is not selected.
  final Color? unselectedItemColor;

  /// The opacity of color of the touchable background when the item is selected.
  final double? selectedColorOpacity;

  /// The border shape of each item.
  final ShapeBorder itemShape;

  /// A convenience field for the margin surrounding the entire widget.
  final EdgeInsets margin;

  /// The padding of each item.
  final EdgeInsets itemPadding;

  /// The transition duration
  final Duration duration;

  /// The transition curve
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(
        minimum: margin,
        child: Row(
          /// Using a different alignment when there are 2 items or less
          /// so it behaves the same as BottomNavigationBar.
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in items)
              TweenAnimationBuilder<double>(
                  tween: Tween(
                    end: items.indexOf(item) == currentIndex ? 1.0 : 0.0,
                  ),
                  curve: curve,
                  duration: duration,
                  builder: (context, t, _) {
                    final selectedColor = item.selectedColor ?? selectedItemColor ?? theme.primaryColor;
                    final unselectedColor = item.unselectedColor ?? unselectedItemColor ?? theme.iconTheme.color;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Color.lerp(
                            selectedColor.withValues(alpha: 0.0),
                            selectedColor.withValues(alpha: selectedColorOpacity ?? 0.1),
                            t,
                          ),
                          shape: const CircleBorder(), // 👈 Set shape to Circle
                          child: InkWell(
                            onTap: () => onTap?.call(items.indexOf(item)),
                            customBorder: const CircleBorder(), // 👈 Match shape here too
                            child: Padding(
                              padding: const EdgeInsets.all(10), // 👈 Adjust for circle spacing
                              child: IconTheme(
                                data: IconThemeData(
                                  color: Color.lerp(unselectedColor, selectedColor, t),
                                  size: 24,
                                ),
                                child: items.indexOf(item) == currentIndex ? item.activeIcon ?? item.icon : item.icon,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        DefaultTextStyle(
                          style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.unSelected),
                          child: item.title,
                        ),
                        const SizedBox(height: 4),
                      ],
                    );
                  }),
          ],
        ),
      ),
    );
  }
}

/// A tab to display in a [SalomonBottomBar]
class SalomonBottomBarItem {
  /// An icon to display.
  final Widget icon;

  /// An icon to display when this tab bar is active.
  final Widget? activeIcon;

  /// Text to display, ie `Home`

  /// A primary color to use for this tab.
  final Color? selectedColor;

  /// The color to display when this tab is not selected.
  final Color? unselectedColor;
  final Widget title;

  SalomonBottomBarItem({
    required this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.activeIcon,
    required this.title,
  });
}
