import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/custom/motion/ringing_call_button.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Resolves the relative `storage/...` paths the API returns.
String listenerImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('http')) return image;
  return '${Api.baseUrl}${image.replaceAll('\\', '/')}';
}

/// Full-bleed photo with the shared dark scrim; falls back to a placeholder.
class ListenerPhoto extends StatelessWidget {
  const ListenerPhoto({super.key, required this.image, this.fit = BoxFit.cover, this.scrim = true, this.cacheWidth});

  final String? image;
  final BoxFit fit;
  final bool scrim;

  /// Decode width in physical pixels. Grid thumbnails pass a small value so
  /// a 3000px upload is not decoded at full size for a 180px tile.
  final int? cacheWidth;

  /// Lets widget tests substitute local images for network ones.
  @visibleForTesting
  static ImageProvider Function(String url)? debugProviderOverride;

  @override
  Widget build(BuildContext context) {
    final url = listenerImageUrl(image);
    final override = debugProviderOverride;
    final photo = url.isEmpty
        ? Image.asset(AppAsset.listenerPlaceHolder, fit: fit)
        : override != null
            ? Image(image: override(url), fit: fit)
            : CachedNetworkImage(
                imageUrl: url,
                fit: fit,
                memCacheWidth: cacheWidth,
                fadeInDuration: const Duration(milliseconds: 260),
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: BebuTheme.surface2,
                  highlightColor: BebuTheme.surface3,
                  child: Container(color: BebuTheme.surface2),
                ),
                errorWidget: (_, __, ___) => Image.asset(AppAsset.listenerPlaceHolder, fit: fit),
              );
    if (!scrim) return photo;
    return Stack(
      fit: StackFit.expand,
      children: [
        photo,
        const DecoratedBox(decoration: BoxDecoration(gradient: BebuTheme.photoScrim)),
      ],
    );
  }
}

/// Tall photo card used in the Explore grid.
class ListenerGridCard extends StatelessWidget {
  const ListenerGridCard({
    super.key,
    required this.name,
    required this.age,
    required this.image,
    required this.statusLabel,
    required this.onTap,
    required this.onAction,
    this.heroTag,
    this.subtitle,
    this.actionIcon = Icons.call_rounded,
  });

  final String name;
  final int? age;
  final String? image;
  final String? statusLabel;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final Object? heroTag;
  final String? subtitle;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final live = statusLabel == 'Available';
    final dpr = MediaQuery.devicePixelRatioOf(context);
    Widget photo = ListenerPhoto(image: image, cacheWidth: (220 * dpr).round());
    if (heroTag != null) photo = Hero(tag: heroTag!, child: photo);

    return PressScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            photo,
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: BebuTheme.statusColor(statusLabel),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x66000000), width: 1.5),
                  boxShadow: live ? [BoxShadow(color: BebuTheme.green.withValues(alpha: 0.7), blurRadius: 8)] : null,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          age == null ? name : '$name, $age',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BebuTheme.title(size: 17),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11.5)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RingingCallButton(
                    icon: actionIcon,
                    size: 40,
                    iconSize: 18,
                    ringing: live && actionIcon == Icons.call_rounded,
                    color: live ? BebuTheme.green.withValues(alpha: 0.28) : const Color(0x40FFFFFF),
                    onTap: onAction,
                    semanticLabel: actionIcon == Icons.call_rounded ? 'Call $name' : 'Message $name',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round action button (skip / call / video) with gradient or flat styles.
class ActionOrb extends StatelessWidget {
  const ActionOrb({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 60,
    this.gradient,
    this.color,
    this.iconColor = BebuTheme.text,
    this.iconSize = 26,
    this.glow,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Gradient? gradient;
  final Color? color;
  final Color iconColor;
  final double iconSize;
  final Color? glow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressScale(
        scale: 0.9,
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            color: gradient == null ? (color ?? BebuTheme.surface2) : null,
            border: gradient == null ? Border.all(color: BebuTheme.borderStrong) : null,
            boxShadow: glow == null ? null : [BoxShadow(color: glow!.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
