import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/gifts/api/gift_api.dart';
import 'package:talk_in/ui/user_flow/gifts/model/gift_model.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_blast.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_sheet.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

/// Who is receiving the gift and from where in the app it is being sent.
class GiftTarget {
  const GiftTarget({required this.listenerId, required this.listenerName, this.listenerImage = '', this.chatTopicId, this.context = 'chat', this.callId});

  final String listenerId;
  final String listenerName;
  final String listenerImage;
  final String? chatTopicId;
  final String context; // chat | call
  final String? callId;
}

/// App-wide gift state: the admin catalog (fetched once per session, refreshed
/// on demand) and the send flow, which owns the wallet update and the
/// full-screen animation so every entry point behaves the same.
class GiftController extends GetxController {
  static const idCatalog = 'giftCatalog';

  GiftCatalog catalog = GiftCatalog.off;
  bool loaded = false;
  bool loading = false;
  bool sending = false;
  DateTime? _loadedAt;

  static GiftController get to => Get.isRegistered<GiftController>() ? Get.find<GiftController>() : Get.put(GiftController(), permanent: true);

  bool get enabled => catalog.enabled && catalog.gifts.isNotEmpty;
  bool get showInChat => enabled && catalog.showInChat;
  bool get showInCall => enabled && catalog.showInCall;
  List<GiftItem> get gifts => catalog.gifts;

  int get balance => int.tryParse(Database.userCoin) ?? 0;

  /// Fetches the catalog; cheap to call often (throttled to once a minute
  /// unless [force]).
  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (!force && _loadedAt != null && DateTime.now().difference(_loadedAt!) < const Duration(minutes: 1)) return;
    loading = true;
    final result = await GiftApi.list();
    loading = false;
    if (result != null) {
      catalog = result;
      loaded = true;
      _loadedAt = DateTime.now();
    }
    update([idCatalog]);
  }

  GiftItem? byId(String id) => gifts.firstWhereOrNull((g) => g.id == id);

  /// Opens the picker; on a successful send, plays the cinematic overlay,
  /// updates the wallet and hands the chat message to [onSent].
  Future<void> open(BuildContext context, GiftTarget target, {void Function(GiftItem gift, GiftSendResult result)? onSent}) async {
    if (!loaded) await load(force: true);
    if (!enabled) return;
    if (!context.mounted) return;
    await GiftSheet.show(context, target: target, onSent: onSent);
  }

  /// Charges the wallet and returns the server result. The sheet calls this
  /// and decides what to show.
  Future<GiftSendResult> send(GiftItem gift, GiftTarget target) async {
    if (sending) return const GiftSendResult(ok: false, message: 'Hold on, still sending the last one…');
    sending = true;
    final result = await GiftApi.send(giftId: gift.id, listenerId: target.listenerId, chatTopicId: target.chatTopicId, context: target.context, callId: target.callId);
    sending = false;
    if (result.balance != null) _setBalance(result.balance!);
    return result;
  }

  void _setBalance(int coins) {
    Database.onSetUserCoin(coins.toString());
    if (Get.isRegistered<HomeScreenController>()) Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
    update([idCatalog]);
  }

  /// Full-screen celebration above whatever is on screen (chat, call…).
  void celebrate(BuildContext context, GiftItem gift, {required String toName, bool incoming = false, String fromName = ''}) {
    GiftBlast.show(context, image: gift.image, name: gift.name, accent: gift.accent, coins: gift.coins, toName: toName, incoming: incoming, fromName: fromName);
  }

  /// Host side: a gift landed for me (socket `giftReceived`).
  void celebrateIncoming(BuildContext context, GiftSnapshot gift, {required String fromName}) {
    GiftBlast.show(context, image: gift.image, name: gift.name, accent: gift.accent, coins: gift.coins, toName: '', incoming: true, fromName: fromName);
  }
}
