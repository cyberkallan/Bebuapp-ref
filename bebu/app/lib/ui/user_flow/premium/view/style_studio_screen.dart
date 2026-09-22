import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/premium/controller/style_studio_controller.dart';
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/ui/user_flow/premium/style/style_looks.dart';
import 'package:talk_in/ui/user_flow/premium/view/pro_widgets.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/pro.dart';
import 'package:talk_in/utils/utils.dart';

String _fmt(num n) => NumberFormat.decimalPattern().format(n);

/// Style Studio: a live phone preview on top, the catalog below, one action
/// bar. Wallpapers and chat themes preview as a chat; fonts preview as a chat
/// set in that font; call screens preview as a call.
class StyleStudioScreen extends StatefulWidget {
  const StyleStudioScreen({super.key});

  @override
  State<StyleStudioScreen> createState() => _StyleStudioScreenState();
}

class _StyleStudioScreenState extends State<StyleStudioScreen> {
  final StyleStudioController c = StyleStudioController.to;

  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.6,
        child: SafeArea(
          bottom: false,
          child: GetBuilder<StyleStudioController>(
            id: StyleStudioController.idStudio,
            init: c,
            builder: (c) {
              final cat = c.catalog;
              return Column(
                children: [
                  _Header(balance: cat?.coins ?? int.tryParse(Database.userCoin)),
                  if (cat == null && c.loading)
                    const Expanded(child: _StudioShimmer())
                  else if (cat == null)
                    Expanded(child: _ErrorState(message: c.error ?? 'Could not load the Style Studio.', onRetry: c.load))
                  else if (!cat.enabled)
                    const Expanded(child: _Off())
                  else ...[
                    _Tabs(tab: c.tab, onChanged: c.setTab),
                    Expanded(
                      child: RefreshIndicator(
                        color: BebuTheme.pink,
                        backgroundColor: BebuTheme.surface,
                        onRefresh: c.load,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          children: [
                            _PreviewPanel(c: c),
                            const SizedBox(height: 14),
                            _CatalogHeader(c: c),
                            const SizedBox(height: 10),
                            _Grid(c: c),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<StyleStudioController>(
        id: StyleStudioController.idStudio,
        builder: (c) => c.catalog == null || !c.catalog!.enabled ? const SizedBox.shrink() : _ActionBar(c: c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          Text('Style Studio', style: BebuTheme.title(size: 18)),
          const SizedBox(width: 8),
          if (Pro.isActive) const ProPill(dense: true),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [const Coin3D(size: 18), const SizedBox(width: 6), Text(_fmt(balance ?? 0), style: BebuTheme.label(size: 13.5))]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onChanged});
  final StyleType tab;
  final ValueChanged<StyleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final t in StyleType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BebuChip(label: t.label, icon: t.icon, selected: tab == t, onTap: () => onChanged(t)),
            ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.c});
  final StyleStudioController c;

  @override
  Widget build(BuildContext context) {
    final item = c.previewed;
    final applied = c.appliedKey(c.tab);
    final isApplied = (item?.key ?? '') == applied;
    final label = c.previewingDefault ? 'Default' : (item?.name ?? 'Default');
    return ClipRRect(
      borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
      child: Container(
        height: 300,
        decoration: BoxDecoration(color: BebuTheme.surface, border: Border.all(color: BebuTheme.border)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: BebuTheme.normal,
              switchInCurve: Curves.easeOutCubic,
              child: KeyedSubtree(
                key: ValueKey('${c.tab}-${item?.key}-${c.previewingDefault}'),
                child: c.tab == StyleType.callTheme ? _CallPreview(item: item) : _ChatPreview(item: item, type: c.tab, c: c),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999)),
                    child: Text(label, style: BebuTheme.label(size: 12, color: Colors.white)),
                  ),
                  if (isApplied && !c.previewingDefault) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: BebuTheme.green.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_rounded, size: 12, color: Colors.black), const SizedBox(width: 3), Text('Applied', style: BebuTheme.label(size: 11, color: Colors.black))]),
                    ),
                  ],
                ],
              ),
            ),
            if (item != null && item.tagline.isNotEmpty)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999)),
                  child: Text(item.tagline, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 11, color: Colors.white.withValues(alpha: 0.85), weight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mini chat in the look being previewed. Fonts swap the family; wallpapers
/// swap the background; chat themes swap everything.
class _ChatPreview extends StatelessWidget {
  const _ChatPreview({required this.item, required this.type, required this.c});
  final StyleItem? item;
  final StyleType type;
  final StyleStudioController c;

  @override
  Widget build(BuildContext context) {
    // Start from what is applied, then override the slot being previewed.
    final appliedTheme = c.byKey(c.appliedKey(StyleType.chatTheme));
    final appliedWp = c.byKey(c.appliedKey(StyleType.wallpaper));
    final appliedFont = c.byKey(c.appliedKey(StyleType.font));
    StyleItem? theme = appliedTheme, wp = appliedWp, font = appliedFont;
    if (type == StyleType.chatTheme) theme = c.previewingDefault ? null : (item ?? appliedTheme);
    if (type == StyleType.wallpaper) wp = c.previewingDefault ? null : (item ?? appliedWp);
    if (type == StyleType.font) font = c.previewingDefault ? null : (item ?? appliedFont);

    final wpUrl = wp != null ? Pro.assetUrl(wp.image) : (theme != null ? ChatLook.wallpaperUrlForKey((theme.data['wallpaper'] ?? '').toString()) : '');
    final look = theme == null ? ChatLook.stock(wallpaperUrl: wpUrl) : ChatLook.fromData(theme.data, wallpaperUrl: wpUrl, name: theme.name);
    final family = font?.data['family']?.toString() ?? 'Inter';
    TextStyle f(double size, Color color, [FontWeight w = FontWeight.w400]) => BebuTheme.font(fontSize: size, color: color, fontWeight: w, family: family);

    Widget bubble(String text, {required bool mine, int delay = 0}) => FadeSlideIn(
          delayMs: delay,
          offset: 10,
          child: Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: const BoxConstraints(maxWidth: 210),
              decoration: BoxDecoration(
                gradient: mine ? look.mineGradient : null,
                color: mine ? null : look.theirs,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
              ),
              child: Text(text, style: f(13, mine ? look.text : look.theirsText)),
            ),
          ),
        );

    final sample = (font?.data['sample'] ?? '').toString();
    return ChatCanvas(
      look: look,
      dim: 0.3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 48, 14, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            bubble(sample.isNotEmpty ? sample : 'Hey! How was your day? 😊', mine: false),
            bubble('Long one. Talking to you fixes it ✨', mine: true, delay: 60),
            bubble(type == StyleType.font ? 'Set in $family' : 'Call later? 📞', mine: false, delay: 120),
            const SizedBox(height: 10),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: look.composer.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: look.light ? 0 : 0.08))),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 18, color: look.onBgMuted),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Message', style: f(13, look.light ? const Color(0x9917151E) : Colors.white.withValues(alpha: 0.55)))),
                  Container(width: 28, height: 28, decoration: BoxDecoration(gradient: look.mineGradient, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallPreview extends StatelessWidget {
  const _CallPreview({required this.item});
  final StyleItem? item;

  @override
  Widget build(BuildContext context) {
    final look = item == null ? CallLook.stock() : CallLook.fromData(item!.data, name: item!.name);
    final photo = Database.loginUserProfilePic;
    return Stack(
      fit: StackFit.expand,
      children: [
        CallBackdrop(
          look: look,
          photo: photo.isEmpty
              ? null
              : ImageFiltered(
                  imageFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
                  child: CachedNetworkImage(imageUrl: Pro.assetUrl(photo), fit: BoxFit.cover, memCacheWidth: 400, errorWidget: (_, __, ___) => const SizedBox.shrink()),
                ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 26),
            CallRing(
              look: look,
              size: 92,
              child: photo.isEmpty ? Container(color: BebuTheme.surface2, child: const Icon(Icons.person_rounded, color: Colors.white54, size: 40)) : CachedNetworkImage(imageUrl: Pro.assetUrl(photo), fit: BoxFit.cover, memCacheWidth: 200),
            ),
            const SizedBox(height: 10),
            Text('Ananya', style: BebuTheme.title(size: 16, color: Colors.white)),
            Text('04:21', style: BebuTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 14),
            _MiniControls(look: look),
          ],
        ),
      ],
    );
  }
}

class _MiniControls extends StatelessWidget {
  const _MiniControls({required this.look});
  final CallLook look;

  @override
  Widget build(BuildContext context) {
    final glass = look.controls == 'glass';
    final gold = look.controls == 'gold';
    Color bg = glass ? Colors.white.withValues(alpha: 0.14) : (gold ? BebuTheme.gold.withValues(alpha: 0.22) : look.accent.withValues(alpha: 0.2));
    Color border = glass ? Colors.white.withValues(alpha: 0.2) : (gold ? BebuTheme.gold.withValues(alpha: 0.6) : look.accent.withValues(alpha: 0.7));
    Widget b(IconData i, {bool end = false}) => Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(color: end ? BebuTheme.red : bg, shape: BoxShape.circle, border: end ? null : Border.all(color: border)),
          child: Icon(i, size: 16, color: Colors.white),
        );
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [b(Icons.mic_off_rounded), b(Icons.volume_up_rounded), b(Icons.card_giftcard_rounded), b(Icons.call_end_rounded, end: true)]);
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.c});
  final StyleStudioController c;

  @override
  Widget build(BuildContext context) {
    final items = c.items;
    final free = items.where((i) => i.includedInPro).length;
    final owned = items.where((i) => i.owned || !i.locked).length;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.tab.label, style: BebuTheme.title(size: 17)),
              Text(
                c.pro ? '$owned of ${items.length} yours · $free included with ${Pro.name}' : '$free free with ${Pro.name} · others unlock with coins',
                style: BebuTheme.body(size: 12),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => c.select(null),
          icon: Icon(Icons.restart_alt_rounded, size: 16, color: BebuTheme.textMuted),
          label: Text('Default', style: BebuTheme.label(size: 12, color: BebuTheme.textMuted)),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.c});
  final StyleStudioController c;

  @override
  Widget build(BuildContext context) {
    final items = c.items;
    if (items.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Text('Nothing here yet — check back soon.', textAlign: TextAlign.center, style: BebuTheme.body()));
    }
    final tall = c.tab == StyleType.wallpaper || c.tab == StyleType.callTheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: tall ? 3 : 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: tall ? 0.62 : 1.35),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        final selectedKey = c.preview.containsKey(c.tab) ? c.preview[c.tab] : c.appliedKey(c.tab);
        return FadeSlideIn(
          delayMs: (i % 9) * 30,
          child: _Tile(item: it, selected: it.key == selectedKey, applied: it.key == c.appliedKey(c.tab), celebrate: c.justUnlocked == it.key, onTap: () => c.select(it)),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.selected, required this.applied, required this.celebrate, required this.onTap});
  final StyleItem item;
  final bool selected;
  final bool applied;
  final bool celebrate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = BebuTheme.radiusMd;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          border: Border.all(color: selected ? BebuTheme.pink : BebuTheme.border, width: selected ? 2 : 1),
          boxShadow: selected ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _TileArt(item: item),
              if (item.locked)
                DecoratedBox(decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.32))),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 12, color: Colors.white)),
                    const SizedBox(height: 4),
                    _PriceChip(item: item),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: applied
                    ? Container(width: 22, height: 22, decoration: BoxDecoration(color: BebuTheme.green, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 14, color: Colors.black))
                    : item.locked
                        ? Container(width: 22, height: 22, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle), child: Icon(item.proOnly && !Pro.isActive ? Icons.workspace_premium_rounded : Icons.lock_rounded, size: 12, color: item.proOnly && !Pro.isActive ? BebuTheme.gold : Colors.white))
                        : const SizedBox.shrink(),
              ),
              if (celebrate) const Positioned.fill(child: _UnlockShine()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile artwork per type: wallpaper thumb, font sample, bubble swatch, call swatch.
class _TileArt extends StatelessWidget {
  const _TileArt({required this.item});
  final StyleItem item;

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case StyleType.wallpaper:
        return CachedNetworkImage(
          imageUrl: Pro.assetUrl(item.thumb.isEmpty ? item.image : item.thumb),
          fit: BoxFit.cover,
          memCacheWidth: 360,
          placeholder: (_, __) => Container(color: BebuTheme.surface2),
          errorWidget: (_, __, ___) => Container(color: BebuTheme.surface2, child: Icon(Icons.broken_image_rounded, color: BebuTheme.textFaint)),
        );
      case StyleType.font:
        final fam = item.data['family']?.toString();
        return Container(
          color: BebuTheme.surface2,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 36),
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text('Aa', style: BebuTheme.font(fontSize: 44, color: BebuTheme.text, fontWeight: FontWeight.w600, family: fam)),
          ),
        );
      case StyleType.chatTheme:
        final look = ChatLook.fromData(item.data);
        return Container(
          decoration: BoxDecoration(gradient: look.bgGradient),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: Container(width: 64, height: 14, decoration: BoxDecoration(color: look.theirs, borderRadius: BorderRadius.circular(7)))),
              const SizedBox(height: 5),
              Align(alignment: Alignment.centerRight, child: Container(width: 84, height: 14, decoration: BoxDecoration(gradient: look.mineGradient, borderRadius: BorderRadius.circular(7)))),
              const SizedBox(height: 5),
              Align(alignment: Alignment.centerLeft, child: Container(width: 48, height: 14, decoration: BoxDecoration(color: look.theirs, borderRadius: BorderRadius.circular(7)))),
            ],
          ),
        );
      case StyleType.callTheme:
        final look = CallLook.fromData(item.data);
        return Stack(
          fit: StackFit.expand,
          children: [
            CallBackdrop(look: look, animate: false),
            Align(
              alignment: const Alignment(0, -0.35),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: look.ringGradient, boxShadow: [BoxShadow(color: look.accent.withValues(alpha: 0.5), blurRadius: 14)]),
                child: Padding(padding: const EdgeInsets.all(3), child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF17151E)), child: const Icon(Icons.person_rounded, size: 20, color: Colors.white70))),
              ),
            ),
          ],
        );
    }
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.item});
  final StyleItem item;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bg;
    final Color fg;
    IconData? icon;
    if (!item.locked || item.owned) {
      label = 'Yours';
      bg = Colors.white.withValues(alpha: 0.18);
      fg = Colors.white;
      icon = Icons.check_rounded;
    } else if (item.includedInPro) {
      label = Pro.isActive ? 'Free with ${Pro.name}' : 'Free for Pro';
      bg = BebuTheme.gold.withValues(alpha: 0.9);
      fg = const Color(0xFF3B2A05);
      icon = Icons.workspace_premium_rounded;
    } else {
      label = _fmt(item.price);
      bg = Colors.black.withValues(alpha: 0.5);
      fg = Colors.white;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 11, color: fg) else const Coin3D(size: 11),
          const SizedBox(width: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 10.5, color: fg, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _UnlockShine extends StatelessWidget {
  const _UnlockShine();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOut,
      builder: (_, t, __) => IgnorePointer(
        child: Opacity(
          opacity: 1 - t,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment(-1 + 3 * t - 1, -1), end: Alignment(-1 + 3 * t, 1), colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.65), Colors.white.withValues(alpha: 0)]),
              border: Border.all(color: BebuTheme.gold, width: 2),
              borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.c});
  final StyleStudioController c;

  @override
  Widget build(BuildContext context) {
    final item = c.previewed;
    final applied = c.appliedKey(c.tab);
    final bottom = MediaQuery.paddingOf(context).bottom;
    String label;
    IconData? icon;
    Gradient gradient = BebuTheme.pinkGradient;
    Color glow = BebuTheme.pink;
    bool enabled = true;
    if (c.previewingDefault) {
      label = applied.isEmpty ? 'Default is applied' : 'Reset to default';
      icon = Icons.restart_alt_rounded;
      gradient = BebuTheme.violetGradient;
      glow = BebuTheme.violet;
      enabled = applied.isNotEmpty;
    } else if (item == null) {
      label = 'Pick a style';
      enabled = false;
    } else if (!item.locked) {
      final isApplied = item.key == applied;
      label = isApplied ? 'Applied' : 'Apply ${item.name}';
      icon = isApplied ? Icons.check_rounded : Icons.auto_awesome_rounded;
      enabled = !isApplied;
    } else if (item.proOnly && !c.pro) {
      label = 'Go ${Pro.name} to unlock';
      icon = Icons.workspace_premium_rounded;
      gradient = BebuTheme.goldGradient;
      glow = BebuTheme.gold;
    } else if (item.price == 0) {
      label = 'Claim free with ${Pro.name}';
      icon = Icons.workspace_premium_rounded;
      gradient = BebuTheme.goldGradient;
      glow = BebuTheme.gold;
    } else {
      label = 'Unlock & apply · ${_fmt(item.price)} coins';
      icon = Icons.lock_open_rounded;
    }
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
      decoration: BoxDecoration(color: BebuTheme.bg.withValues(alpha: 0.96), border: Border(top: BorderSide(color: BebuTheme.border))),
      child: GradientButton(
        label: c.busy ? 'Working…' : label,
        icon: c.busy ? null : icon,
        gradient: gradient,
        glow: glow,
        height: 56,
        loading: c.busy,
        onTap: enabled && !c.busy ? () => c.primaryAction(context) : null,
      ),
    );
  }
}

class _Off extends StatelessWidget {
  const _Off();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette_outlined, size: 48, color: BebuTheme.textFaint),
            const SizedBox(height: 14),
            Text('Style Studio is closed for now', style: BebuTheme.title(size: 18), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Anything you already unlocked stays yours.', style: BebuTheme.body(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: BebuTheme.textFaint),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: BebuTheme.body()),
            const SizedBox(height: 16),
            GhostButton(label: 'Try again', height: 46, expanded: false, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _StudioShimmer extends StatelessWidget {
  const _StudioShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double? w}) => Container(width: w, height: h, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(18)));
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Row(children: [for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(right: 8), child: box(36, w: 92))]),
          const SizedBox(height: 14),
          box(300),
          const SizedBox(height: 16),
          box(18, w: 140),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: box(170)), const SizedBox(width: 10), Expanded(child: box(170)), const SizedBox(width: 10), Expanded(child: box(170))]),
        ],
      ),
    );
  }
}
