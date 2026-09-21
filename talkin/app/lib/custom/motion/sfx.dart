import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Tiny UI sound + haptic layer. Every call is a no-op when the admin has
/// turned sound effects off, and never throws (a failed sound must not break
/// the interaction it decorates).
class Sfx {
  Sfx._();

  static AudioPlayer? _player;

  static AudioPlayer get _p {
    final existing = _player;
    if (existing != null) return existing;
    final p = AudioPlayer(playerId: 'bebu-sfx')
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency);
    // Mix with other audio (e.g. a chat voice note) instead of pausing it.
    p.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient, options: const {AVAudioSessionOptions.mixWithOthers}),
    ));
    _player = p;
    return p;
  }

  static Future<void> _play(String asset, {double volume = 0.6}) async {
    if (!BebuTheme.soundEffects) return;
    try {
      await _p.stop();
      await _p.play(AssetSource(asset), volume: volume);
    } catch (e) {
      Utils.showLog('Sfx failed ($asset): $e');
    }
  }

  /// Host card chosen for a call: medium tap, then a soft two-note chime.
  static Future<void> select() {
    HapticFeedback.mediumImpact();
    return _play('audio/select.mp3', volume: 0.55);
  }

  /// Light confirmation tick with no sound.
  static void tick() => HapticFeedback.selectionClick();

  /// Item equipped / popped onto the stage: light tap + short pop.
  static Future<void> pop() {
    HapticFeedback.lightImpact();
    return _play('audio/pop.mp3', volume: 0.5);
  }

  /// Premium item unlocked: heavy tap + rising four-note chime.
  static Future<void> unlock() {
    HapticFeedback.heavyImpact();
    return _play('audio/unlock.mp3', volume: 0.65);
  }

  /// Something was refused (locked, not enough coins): vibrate only.
  static void deny() => HapticFeedback.vibrate();
}
