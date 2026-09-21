import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class FakeAudioCallController extends GetxController {
  Timer? timer;
  late AudioPlayer _audioPlayer;
  DateTime? startTime;
  DateTime? endTime;
  String? finalDuration;
  Duration? duration;
  int? minutes;
  int? seconds;
  late List<dynamic> args;

  bool isMicMute = false;
  bool isSpeakerOn = true;
  bool manualSpeakerOverride = false;

  String? formattedTime;
  String? receiverName;
  String? receiverImage;
  String? audio;
  StreamSubscription<bool>? subsProximity;
  bool isProximitySupported = false;
  bool isObjectNear = false;

  @override
  void onInit() async {
    Utils.showLog("Fake audio call onInit");

    await Future.delayed(Duration(seconds: 1));
    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();

    if (isProximitySupported) {
      await ProximityScreenLock.setActive(true);

      subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
        isObjectNear = objectDetected;
        log("Proximity object detected: $isObjectNear");

        if (isObjectNear) {
          // sensor detect → always force OFF
          setSpeaker(false);
          update([Constant.idSpeakerOpen, Constant.idVideoCall]);
        }
        // if object is far, do nothing (user controls ON)
      });
    }

    _audioPlayer = AudioPlayer();

    args = Get.arguments as List<dynamic>;

    if (args.isNotEmpty) {
      receiverName = args[0];
      receiverImage = args[1];
      audio = args[2];
    }

    Utils.showLog("Fake audio call receiverName: $receiverName");
    Utils.showLog("Fake audio call receiverImage: $receiverImage");
    Utils.showLog("Fake audio call audio: $audio");

    playAudio();
    startTimer();
    super.onInit();
  }

  Future<void> playAudio() async {
    try {
      // Replace with test URL if needed
      final fallbackTestAudio = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

      String? rawUrl;
      if (audio != null && audio!.isNotEmpty) {
        rawUrl = Uri.encodeFull(Api.baseUrl + audio!.replaceAll('\\', '/'));
      }

      final audioUrl = rawUrl ?? fallbackTestAudio;

      // Set audio context for speaker output
      await _audioPlayer.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: isSpeakerOn,
          stayAwake: true,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.voiceCommunication,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: {AVAudioSessionOptions.defaultToSpeaker},
        ),
      ));

      // Log state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        log('Player state after speaker toggle: $state');
      });

      _audioPlayer.onPositionChanged.listen((position) {
        log('Current playback position: $position');
      });

      await _audioPlayer.setSource(UrlSource(audioUrl));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(isMicMute ? 0.0 : 1.0);
      await _audioPlayer.resume();

      log("Playing audio from: $audioUrl");
    } catch (e) {
      log("Audio play error: $e");
    }
  }

  @override
  void onClose() {
    stopTimer();
    _audioPlayer.stop();
    _audioPlayer.dispose();

    subsProximity?.cancel();
    ProximityScreenLock.setActive(false);

    super.onClose();
  }

  void startTimer() {
    startTime = DateTime.now();
    int elapsedSeconds = 0;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;

      final minutes = elapsedSeconds ~/ 60;
      final seconds = elapsedSeconds % 60;

      formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      update([Constant.idVideoCall]);
    });
  }

  void stopTimer() {
    endTime = DateTime.now();
    timer?.cancel();
    timer = null;

    duration = endTime?.difference(startTime!);
    minutes = duration?.inMinutes.remainder(60);
    seconds = duration?.inSeconds.remainder(60);
    finalDuration = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> setSpeaker(bool enable) async {
    isSpeakerOn = enable;

    await _audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: isSpeakerOn,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.voiceCommunication,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: {AVAudioSessionOptions.defaultToSpeaker},
      ),
    ));

    await _audioPlayer.setVolume(isMicMute ? 0.0 : 1.0);

    update([Constant.idVideoCall]);
    Utils.showLog("Speaker state changed: $isSpeakerOn");
  }

  void toggleSpeaker() {
    manualSpeakerOverride = true;
    setSpeaker(!isSpeakerOn);
  }

  void toggleMicMute() {
    isMicMute = !isMicMute;
    _audioPlayer.setVolume(isMicMute ? 0.0 : 1.0);
    update([Constant.idVideoCall]);
    Utils.showLog("Mic mute toggled: $isMicMute");
  }
}
