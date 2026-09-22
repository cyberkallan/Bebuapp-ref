import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// Tiny UI sound + haptic layer. Every call is a no-op when the admin has
/// turned the matching effect off, and never throws (a failed sound must not
/// break the interaction it decorates).
///
/// Three gates:
/// - `BebuTheme.soundEffects` (admin) — UI chimes: select / pop / unlock.
/// - `BebuTheme.chatSounds` (admin) and `Database.chatTones` (user, Settings →
///   Conversation tones) — WhatsApp-style chat tones.
/// - `BebuTheme.haptics` (admin) — every vibration.
class Sfx {
  Sfx._();

  static AudioPlayer? _player;
  static AudioPlayer? _chatPlayer;

  static AudioPlayer? _make(String id) {
    try {
      final p = AudioPlayer(playerId: id)
        ..setReleaseMode(ReleaseMode.stop)
        ..setPlayerMode(PlayerMode.lowLatency);
      // Mix with other audio (e.g. a chat voice note) instead of pausing it.
      // iOS only allows mixWithOthers with the playback / playAndRecord /
      // multiRoute categories.
      p.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: const {AVAudioSessionOptions.mixWithOthers}),
      ));
      return p;
    } catch (e) {
      Utils.showLog('Sfx player unavailable: $e');
      return null;
    }
  }

  static AudioPlayer? get _p => _player ??= _make('bebu-sfx');

  // Chat tones use their own player so a "received" tone never cuts a
  // "sent" tone short when both land within a few hundred milliseconds.
  static AudioPlayer? get _c => _chatPlayer ??= _make('bebu-chat-sfx');

  static Future<void> _play(AudioPlayer? p, String asset, {double volume = 0.6}) async {
    if (p == null) return;
    try {
      await p.stop();
      await p.play(AssetSource(asset), volume: volume);
    } catch (e) {
      Utils.showLog('Sfx failed ($asset): $e');
    }
  }

  static bool get _ui => BebuTheme.soundEffects;
  static bool get _chat => BebuTheme.chatSounds && Database.chatTones;

  // ---- haptics -----------------------------------------------------------

  static void _h(Future<void> Function() f) {
    if (!BebuTheme.haptics) return;
    f().catchError((_) {});
  }

  /// Light confirmation tick with no sound.
  static void tick() => _h(HapticFeedback.selectionClick);

  static void lightTap() => _h(HapticFeedback.lightImpact);

  static void mediumTap() => _h(HapticFeedback.mediumImpact);

  /// Something was refused (locked, not enough coins): vibrate only.
  static void deny() => _h(HapticFeedback.vibrate);

  // ---- UI chimes ---------------------------------------------------------

  /// Host card chosen for a call: medium tap, then a soft two-note chime.
  static Future<void> select() {
    mediumTap();
    return _ui ? _play(_p, 'audio/select.mp3', volume: 0.55) : Future.value();
  }

  /// Item equipped / popped onto the stage: light tap + short pop.
  static Future<void> pop() {
    lightTap();
    return _ui ? _play(_p, 'audio/pop.mp3', volume: 0.5) : Future.value();
  }

  /// Premium item unlocked: heavy tap + rising four-note chime.
  static Future<void> unlock() {
    _h(HapticFeedback.heavyImpact);
    return _ui ? _play(_p, 'audio/unlock.mp3', volume: 0.65) : Future.value();
  }

  /// Random match found: heavy tap + the rising chime.
  static Future<void> matchFound() {
    _h(HapticFeedback.heavyImpact);
    return _ui ? _play(_p, 'audio/unlock.mp3', volume: 0.5) : Future.value();
  }

  // ---- chat tones (WhatsApp-style) ---------------------------------------

  /// My message left the phone: light tap + short rising "swoosh".
  static Future<void> messageSent() {
    lightTap();
    return _chat ? _play(_c, 'audio/msg_sent.mp3', volume: 0.45) : Future.value();
  }

  /// A message arrived in the open conversation: soft pop-ding.
  static Future<void> messageReceived() {
    lightTap();
    return _chat ? _play(_c, 'audio/msg_in.mp3', volume: 0.5) : Future.value();
  }

  /// Voice recording started: medium tap + crisp tick.
  static Future<void> recordStart() {
    mediumTap();
    return _chat ? _play(_c, 'audio/rec_start.mp3', volume: 0.5) : Future.value();
  }

  /// Voice note released and sent: same as a sent message.
  static Future<void> recordSent() => messageSent();

  /// Recording slid away / too short: vibrate + low "dud".
  static Future<void> recordCancel() {
    deny();
    return _chat ? _play(_c, 'audio/rec_cancel.mp3', volume: 0.45) : Future.value();
  }
}
