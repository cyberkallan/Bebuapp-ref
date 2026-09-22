import 'package:flutter/material.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/gifts/model/gift_model.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_blast.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_picture.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Chat bubble for a gift message (type 6). Shared by the user and host chat
/// screens: `mine` flips the alignment and the copy, `avatar` is drawn for
/// the other side, and tapping replays the celebration.
class GiftBubble extends StatelessWidget {
  const GiftBubble({super.key, required this.gift, required this.mine, required this.time, this.avatar, this.otherName = '', this.trailing});

  final GiftSnapshot gift;
  final bool mine;
  final String time;
  final Widget? avatar;
  final String otherName;
  final Widget? trailing; // delivery ticks for my messages

  @override
  Widget build(BuildContext context) {
    final accent = gift.accent;
    final card = PressScale(
      scale: 0.97,
      onTap: () {
        Sfx.lightTap();
        GiftBlast.show(context, image: gift.image, name: gift.name, accent: accent, coins: gift.coins, toName: otherName, incoming: !mine, fromName: otherName);
      },
      child: Container(
        width: 190,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: BebuTheme.isLight
                ? [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.06)]
                : [accent.withValues(alpha: 0.32), BebuTheme.surface2],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 6),
            bottomRight: Radius.circular(mine ? 6 : 20),
          ),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GiftPicture(image: gift.image, size: 86, accent: accent),
            const SizedBox(height: 10),
            Text(gift.name, textAlign: TextAlign.center, style: BebuTheme.title(size: 15)),
            const SizedBox(height: 2),
            Text(mine ? 'You sent a gift' : '${otherName.isEmpty ? 'They' : otherName.split(' ').first} sent you a gift', textAlign: TextAlign.center, style: BebuTheme.body(size: 11.5, color: BebuTheme.textMuted)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
              decoration: BoxDecoration(color: BebuTheme.bg.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Coin3D(size: 13),
                  const SizedBox(width: 5),
                  Text('${gift.coins}', style: BebuTheme.label(size: 12, color: BebuTheme.text)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final meta = Padding(
      padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time, style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[SizedBox(width: 30, height: 30, child: avatar), const SizedBox(width: 8)],
          Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [card, meta]),
        ],
      ),
    );
  }
}
