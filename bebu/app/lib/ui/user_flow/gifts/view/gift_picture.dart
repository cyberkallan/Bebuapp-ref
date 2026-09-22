import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/utils/app_theme.dart';

/// The gift render (transparent PNG) at a given size. Bundled gifts live under
/// `/gifts/<key>.png` on the API host; admin uploads under `/storage/...`.
class GiftPicture extends StatelessWidget {
  const GiftPicture({super.key, required this.image, required this.size, this.shadow = true, this.accent});

  final String image;
  final double size;
  final bool shadow;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final url = listenerImageUrl(image);
    // ignore: invalid_use_of_visible_for_testing_member
    final override = ListenerPhoto.debugProviderOverride;
    Widget pic;
    if (url.isEmpty) {
      pic = Icon(Icons.card_giftcard_rounded, size: size * 0.7, color: accent ?? BebuTheme.pink);
    } else if (override != null) {
      pic = Image(image: override(url), width: size, height: size, fit: BoxFit.contain);
    } else {
      pic = CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        memCacheWidth: (size * 3).round(),
        fadeInDuration: BebuTheme.fast,
        placeholder: (_, __) => SizedBox(width: size, height: size),
        errorWidget: (_, __, ___) => Icon(Icons.card_giftcard_rounded, size: size * 0.7, color: accent ?? BebuTheme.pink),
      );
    }
    if (!shadow) return SizedBox(width: size, height: size, child: pic);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: (accent ?? BebuTheme.pink).withValues(alpha: 0.28), blurRadius: size * 0.35, offset: Offset(0, size * 0.08))],
        ),
        child: pic,
      ),
    );
  }
}
