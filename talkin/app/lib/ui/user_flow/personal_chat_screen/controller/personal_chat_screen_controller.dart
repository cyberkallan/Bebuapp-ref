import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/api/personal_chat_api.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/api/send_image_audio_api.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/send_image_audio_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

/// Extra socket field: a client id echoed back by the server so the
/// optimistic bubble can be matched exactly (text and audio alike).
const String kLocalIdParam = 'localId';

class PersonalChatScreenController extends GetxController {
  String? chatTopicId;
  String? receiverId;
  String? receiverName;
  String? receiverStatusLabel;
  String? receiverImage;
  String? ratePrivateAudioCall;
  String? ratePrivateVideoCall;
  String? fakeAudioUrl;
  List<dynamic>? fakeVideoUrl;
  bool? isFake;
  bool? availableForPrivateVideoCall;
  bool? availableForPrivateAudioCall;
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false;
  bool loadFailed = false;
  PersonalChatModel? personalChatModel;
  List<PersonalChat> oldChat = [];
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedImage;
  final ScrollController scrollController = ScrollController();
  SendImageAudioModel? sendImageAudioModel;
  AudioRecorder audioRecorder = AudioRecorder();
  bool isRecordingAudio = false;
  bool isPaginationLoading = false;
  bool isBackProfile = true;
  String? chatRoomId;
  bool isLoadingAudio = false;
  bool isLoadingImage = false;
  bool isMsgSeen = false;

  bool isSendingAudioFile = false;

  /// True while the finger has slid far enough left to cancel the recording.
  bool recordCancelArmed = false;

  /// 0..1 microphone level for the recording indicator.
  double recordLevel = 0;

  String currentPlayAudioId = "";
  Timer? timer;
  int countTime = 0;

  /// Whether the composer has text (drives mic ↔ send swap).
  bool get hasText => messageController.text.trim().isNotEmpty;

  static const Duration _ackTimeout = Duration(seconds: 12);
  static const Duration _minRecording = Duration(milliseconds: 900);
  static const int _maxRecordingSeconds = 300;

  final Map<String, Timer> _ackTimers = {};
  StreamSubscription<Amplitude>? _ampSub;
  DateTime? _recordStartedAt;
  String? _recordPath;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(onPagination);
    messageController.addListener(() => update([Constant.idSendMsg]));

    List args = Get.arguments ?? [];

    if (args.length >= 9) {
      receiverId = args[0]?.toString();
      receiverName = args[1]?.toString();
      receiverStatusLabel = args[2]?.toString();
      receiverImage = args[3]?.toString();
      ratePrivateAudioCall = args[4]?.toString();
      ratePrivateVideoCall = args[5]?.toString();
      isFake = args[6] is bool ? args[6] : args[6].toString().toLowerCase() == 'true';
      if (args[7] is String) {
        try {
          fakeVideoUrl = jsonDecode(args[7]) as List<dynamic>;
        } catch (_) {
          fakeVideoUrl = [];
        }
      } else if (args[7] is List) {
        fakeVideoUrl = args[7];
      } else {
        fakeVideoUrl = [];
      }
      availableForPrivateVideoCall = args[8] is bool ? args[8] : args[8].toString().toLowerCase() == 'true';
      availableForPrivateAudioCall = args.length > 9 ? (args[9] is bool ? args[9] : args[9].toString().toLowerCase() == 'true') : false;
    }
    init();
    // A message typed the moment the screen opens must not be lost because
    // the socket dropped while the app was in the background.
    SocketService.ensureConnected();
    Utils.showLog("Receiver ID: $receiverId  name: $receiverName  fake: $isFake");
  }

  @override
  void onClose() {
    for (final t in _ackTimers.values) {
      t.cancel();
    }
    _ackTimers.clear();
    timer?.cancel();
    _ampSub?.cancel();
    if (isRecordingAudio) {
      audioRecorder.stop().then((p) {
        if (p != null) File(p).delete().catchError((_) => File(p));
      }).catchError((_) => null);
    }
    audioRecorder.dispose();
    super.onClose();
  }

  Future<void> init() async {
    if (receiverId != "") {
      chatRoomId = null;

      isLoading = true;
      loadFailed = false;
      update([Constant.idGetOldChat]);

      oldChat.clear();
      PersonalChatApi.startPagination = 1;

      await getOldChats();

      isLoading = false;
      loadFailed = chatTopicId == null;
      update([Constant.idGetOldChat]);
    }
  }

  /// get all chats
  Future<void> getOldChats() async {
    update([Constant.idGetOldChat]);

    personalChatModel = await PersonalChatApi.callApi(
      receiverId: receiverId.toString(),
    );
    final fetched = personalChatModel?.chat ?? [];
    // Pagination can overlap with messages that arrived live; skip dupes.
    final known = oldChat.map((c) => c.id).whereType<String>().toSet();
    oldChat.addAll(fetched.where((c) => c.id == null || !known.contains(c.id)));

    chatTopicId = personalChatModel?.chatTopicId ?? chatTopicId;

    update([Constant.idGetOldChat]);

    if (chatRoomId == null) {
      chatRoomId = personalChatModel?.chatTopicId;
      if (oldChat.isNotEmpty) {
        SocketEmit.onMessageSeen({
          SocketParams.messageId: oldChat.last.id ?? '',
          SocketParams.senderId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
        });
        onScrollDown();
      }
    }
  }

  String formatTimeFromDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsedDate = DateFormat('M/d/yyyy, hh:mm:ss a').parse(rawDate);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      final d = DateTime.tryParse(rawDate);
      return d == null ? '' : DateFormat('hh:mm a').format(d.toLocal());
    }
  }

  Future<void> onPagination() async {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels == scrollController.position.minScrollExtent && !isPaginationLoading && !isLoading) {
      isPaginationLoading = true;
      update([Constant.idPagination]);
      await getOldChats();
      isPaginationLoading = false;
      update([Constant.idPagination]);
    }
  }

  // ---------------------------------------------------------------- sending

  String get _senderRole => Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener';
  String get _receiverRole => Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user';
  String _now() => DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now());

  Map<String, dynamic> _payload({
    required int messageType,
    required String localId,
    String message = '',
    String image = '',
    String audio = '',
  }) =>
      {
        SocketParams.senderRole: _senderRole,
        SocketParams.receiverRole: _receiverRole,
        SocketParams.chatTopicId: chatTopicId ?? '',
        SocketParams.senderId: Database.loginUserId,
        SocketParams.receiverId: receiverId,
        SocketParams.message: message,
        SocketParams.date: _now(),
        SocketParams.messageType: messageType,
        if (image.isNotEmpty) SocketParams.image: image,
        if (audio.isNotEmpty) SocketParams.audio: audio,
        SocketParams.name: Database.fetchLoginUserProfileModel?.user?.fullName,
        SocketParams.profilePic: Database.fetchLoginUserProfileModel?.user?.profilePic,
        SocketParams.ratePrivateVideoCall: '',
        SocketParams.ratePrivateAudioCall: '',
        SocketParams.isFake: isFake,
        SocketParams.video: fakeVideoUrl,
        kLocalIdParam: localId,
      };

  /// Make sure we have a chat topic before emitting: without it the server
  /// silently drops the message ("Chat topic not found").
  Future<bool> _ensureTopic() async {
    if (chatTopicId != null && chatTopicId!.isNotEmpty) return true;
    PersonalChatApi.startPagination = 1;
    oldChat.clear();
    await getOldChats();
    return chatTopicId != null && chatTopicId!.isNotEmpty;
  }

  void _armAck(String localId) {
    _ackTimers[localId]?.cancel();
    _ackTimers[localId] = Timer(_ackTimeout, () {
      final i = oldChat.indexWhere((m) => m.localId == localId);
      if (i != -1 && oldChat[i].pending) {
        oldChat[i].pending = false;
        oldChat[i].failed = true;
        update([Constant.idGetOldChat]);
        Sfx.deny();
      }
    });
  }

  /// send message
  Future<void> sendMessage() async {
    String message = sanitizeUserInput(messageController.text);

    if (message.isEmpty) return;

    if (message.length > 1000) {
      Utils.showToast(Get.context!, "Message too long. Max 1000 characters.");
      return;
    }

    messageController.clear();
    update([Constant.idSendMsg]);

    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimistic = PersonalChat(
      id: localId,
      localId: localId,
      message: message,
      date: _now(),
      messageType: 1,
      senderId: Database.loginUserId,
      pending: true,
    );
    oldChat.insert(0, optimistic);
    update([Constant.idGetOldChat]);
    onScrollDown();
    Sfx.messageSent();

    if (!await _ensureTopic()) {
      optimistic.pending = false;
      optimistic.failed = true;
      update([Constant.idGetOldChat]);
      Utils.showToast(Get.context!, "Couldn't reach the chat server. Tap the message to retry.");
      return;
    }

    SocketEmit.sendMessage(_payload(messageType: 1, localId: localId, message: message));
    _armAck(localId);
  }

  /// Tap on a failed bubble: send it again with the same local id.
  Future<void> retry(PersonalChat msg) async {
    if (!msg.failed || msg.localId == null) return;
    msg.failed = false;
    msg.pending = true;
    update([Constant.idGetOldChat]);
    Sfx.tick();

    if (!await _ensureTopic()) {
      msg.pending = false;
      msg.failed = true;
      update([Constant.idGetOldChat]);
      return;
    }
    switch (msg.messageType) {
      case 2:
        SocketEmit.sendMessage(_payload(messageType: 2, localId: msg.localId!, message: msg.message ?? '', image: msg.image ?? ''));
      case 3:
        SocketEmit.sendMessage(_payload(messageType: 3, localId: msg.localId!, message: msg.message ?? '', audio: msg.audio ?? ''));
      default:
        SocketEmit.sendMessage(_payload(messageType: 1, localId: msg.localId!, message: msg.message ?? ''));
    }
    _armAck(msg.localId!);
  }

  /// Called by [SocketListen] for every `messageDispatched` in this topic.
  /// Reconciles my optimistic bubble (by `localId`, else by content) or
  /// inserts the other person's message with a tone.
  void onSocketMessage(Map<String, dynamic> data, String? messageId) {
    final incoming = PersonalChat.fromJson(data);
    incoming.id = (messageId != null && messageId.isNotEmpty) ? messageId : incoming.id;
    final mine = incoming.senderId == Database.loginUserId;

    if (mine) {
      int i = incoming.localId == null ? -1 : oldChat.indexWhere((m) => m.localId == incoming.localId);
      if (i == -1) {
        i = oldChat.indexWhere((m) =>
            m.pending &&
            m.senderId == Database.loginUserId &&
            m.messageType == incoming.messageType &&
            (m.messageType == 1 ? m.message == incoming.message : true));
      }
      if (i != -1) {
        final local = oldChat[i];
        _ackTimers.remove(local.localId)?.cancel();
        local.id = incoming.id ?? local.id;
        local.pending = false;
        local.failed = false;
        local.date = incoming.date ?? local.date;
        if (incoming.audio != null && incoming.audio!.isNotEmpty) local.audio = incoming.audio;
        if (incoming.image != null && incoming.image!.isNotEmpty) local.image = incoming.image;
        isLoadingAudio = false;
        update([Constant.idGetOldChat]);
        return;
      }
      // Sent from another device / already reconciled: avoid duplicates.
      if (incoming.id != null && oldChat.any((m) => m.id == incoming.id)) return;
      oldChat.insert(0, incoming);
      update([Constant.idGetOldChat]);
      return;
    }

    if (incoming.id != null && oldChat.any((m) => m.id == incoming.id)) return;
    oldChat.insert(0, incoming);
    update([Constant.idGetOldChat]);
    onScrollDown();
    Sfx.messageReceived();
  }

  /// Keep every language and emoji; only drop tags and control characters.
  String sanitizeUserInput(String input) {
    var out = input.replaceAll(RegExp(r'<[^>]*>'), '');
    out = out.replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '');
    out = out.replaceAll(RegExp(r'[<>]'), '');
    return out.trim();
  }

  /// script validation
  bool containsDangerousScript(String input) {
    final scriptTagRegex = RegExp(r'<\s*script[^>]*>', caseSensitive: false);
    return scriptTagRegex.hasMatch(input);
  }

  // ---------------------------------------------------------------- image

  /// send image event
  Future<void> sendImageMessage() async {
    if (pickedImage == null || receiverId == null) {
      Utils.showToast(Get.context!, "No image selected or receiver ID is missing");
      return;
    }
    if (!await _ensureTopic()) {
      Utils.showToast(Get.context!, "Couldn't reach the chat server. Please try again.");
      return;
    }

    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimistic = PersonalChat(
      id: localId,
      localId: localId,
      messageType: 2,
      message: "📸 Image",
      image: pickedImage!.path,
      date: _now(),
      senderId: Database.loginUserId,
      pending: true,
    );
    oldChat.insert(0, optimistic);
    isLoadingImage = true;
    update([Constant.idGetOldChat]);
    onScrollDown();
    Sfx.lightTap();

    try {
      final res = await SendImageAudioApi.callApi(
        messageType: 2,
        chatTopicId: chatTopicId ?? '',
        receiverId: receiverId ?? '',
        imagePath: pickedImage!.path,
      );
      pickedImage = null;
      isLoadingImage = false;

      if (res != null && res.chat != null && res.status == true) {
        optimistic.image = res.chat?.image ?? optimistic.image;
        optimistic.message = res.chat?.message ?? optimistic.message;
        SocketEmit.sendMessage(_payload(messageType: 2, localId: localId, message: optimistic.message ?? '', image: optimistic.image ?? ''));
        _armAck(localId);
        Sfx.messageSent();
        update([Constant.idGetOldChat]);
      } else {
        optimistic.pending = false;
        optimistic.failed = true;
        update([Constant.idGetOldChat]);
        Utils.showToast(Get.context!, res?.message ?? "Failed to send image.");
      }
    } catch (e) {
      isLoadingImage = false;
      optimistic.pending = false;
      optimistic.failed = true;
      update([Constant.idGetOldChat]);
      log("Error in sendImageMessage: $e");
    }
  }

  /// pick image camera
  Future<bool> pickImageFromCamera() async {
    pickedImage = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
    update();
    return pickedImage != null;
  }

  /// pick image gallery
  Future<bool> pickImageFromGallery() async {
    pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    update();
    return pickedImage != null;
  }

  /// show dialog image picker
  Future<void> showImagePickerDialog() async {
    Get.defaultDialog(
      backgroundColor: AppColors.white,
      title: EnumLocale.changeYourImage.name.tr,
      titlePadding: const EdgeInsets.only(top: 30),
      titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appColor),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              thickness: 1,
              color: Colors.grey.shade100,
            ),
          ),
          GestureDetector(
              onTap: () async {
                Get.back();
                bool didPick = await pickImageFromCamera();
                if (didPick) await sendImageMessage();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image(
                        color: AppColors.appColor,
                        image: AssetImage(AppAsset.cameraFlipIcon),
                        height: 20,
                      ),
                    ),
                    Text(
                      EnumLocale.txtTakeAphoto.name.tr,
                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                    )
                  ],
                ),
              )),
          GestureDetector(
              onTap: () async {
                Get.back();
                bool didPick = await pickImageFromGallery();
                if (didPick) await sendImageMessage();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image(
                        color: AppColors.appColor,
                        image: AssetImage(AppAsset.chatImageIcon),
                        height: 20,
                      ),
                    ),
                    Text(
                      EnumLocale.txtChooseFromYourFile.name.tr,
                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- voice

  /// Long-press began on the mic. Asks for the permission if needed and
  /// starts recording as soon as it is granted (the old flow only asked and
  /// never started, so the first attempt always did nothing).
  Future<void> onLongPressStartMic() async {
    if (isRecordingAudio || isSendingAudioFile) return;
    FocusManager.instance.primaryFocus?.unfocus();

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (status.isPermanentlyDenied) {
      Utils.showToast(Get.context!, "Microphone is blocked. Enable it in Settings to send voice notes.");
      Sfx.deny();
      await openAppSettings();
      return;
    }
    if (!status.isGranted) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseAllowPermission.name.tr);
      Sfx.deny();
      return;
    }
    if (!await audioRecorder.hasPermission()) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseAllowPermission.name.tr);
      return;
    }
    await onStartAudioRecording();
  }

  Future<void> onStartAudioRecording() async {
    try {
      Utils.showLog("Audio Recording Start");
      final dir = await getTemporaryDirectory();
      _recordPath = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 44100, numChannels: 1),
        path: _recordPath!,
      );

      _recordStartedAt = DateTime.now();
      isRecordingAudio = true;
      recordCancelArmed = false;
      recordLevel = 0;
      countTime = 0;
      update([Constant.idChangeAudioRecordingEvent]);
      Sfx.recordStart();

      _ampSub?.cancel();
      _ampSub = audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 90)).listen((a) {
        // dBFS roughly -60..0 → 0..1
        final v = ((a.current + 50) / 50).clamp(0.0, 1.0);
        recordLevel = recordLevel * 0.55 + v * 0.45;
        update([Constant.idRecordLevel]);
      });

      onChangeTimer();
    } catch (e) {
      isRecordingAudio = false;
      update([Constant.idChangeAudioRecordingEvent]);
      Utils.showLog("Audio Recording Start Failed => $e");
      Utils.showToast(Get.context!, "Couldn't start recording.");
    }
  }

  /// Finger moved while holding: sliding left past the threshold arms cancel.
  void onLongPressMove(Offset offsetFromOrigin) {
    if (!isRecordingAudio) return;
    final armed = offsetFromOrigin.dx < -90;
    if (armed != recordCancelArmed) {
      recordCancelArmed = armed;
      Sfx.tick();
      update([Constant.idChangeAudioRecordingEvent]);
    }
  }

  Future<void> onLongPressEndMic() async {
    if (!isRecordingAudio) return;
    if (recordCancelArmed) {
      await cancelRecording();
      return;
    }
    final held = DateTime.now().difference(_recordStartedAt ?? DateTime.now());
    if (held < _minRecording) {
      await cancelRecording(tooShort: true);
      return;
    }
    await onStopAudioRecording();
  }

  Future<void> cancelRecording({bool tooShort = false}) async {
    try {
      final p = await audioRecorder.stop();
      if (p != null) File(p).delete().catchError((_) => File(p));
    } catch (_) {}
    _ampSub?.cancel();
    isRecordingAudio = false;
    recordCancelArmed = false;
    recordLevel = 0;
    onChangeTimer();
    update([Constant.idChangeAudioRecordingEvent]);
    Sfx.recordCancel();
    if (tooShort) Utils.showToast(Get.context!, "Hold to record, release to send.");
  }

  Future<void> onStopAudioRecording() async {
    String? audioPath;
    try {
      Utils.showLog("Audio Recording Stop");
      isSendingAudioFile = true;
      _ampSub?.cancel();

      audioPath = await audioRecorder.stop();

      isRecordingAudio = false;
      recordCancelArmed = false;
      recordLevel = 0;
      update([Constant.idChangeAudioRecordingEvent]);
      onChangeTimer();

      Utils.showLog("Recording Audio Path => $audioPath");
      if (audioPath == null || !File(audioPath).existsSync()) {
        isSendingAudioFile = false;
        updateAudioUI();
        Utils.showToast(Get.context!, "Recording failed. Please try again.");
        return;
      }
      if (!await _ensureTopic()) {
        isSendingAudioFile = false;
        updateAudioUI();
        Utils.showToast(Get.context!, "Couldn't reach the chat server. Please try again.");
        return;
      }

      final localId = DateTime.now().millisecondsSinceEpoch.toString();
      final optimistic = PersonalChat(
        id: localId,
        localId: localId,
        messageType: 3,
        message: "🎤 Audio",
        date: _now(),
        createdAt: DateTime.now(),
        senderId: Database.loginUserId,
        audio: audioPath,
        pending: true,
      );
      oldChat.insert(0, optimistic);
      isLoadingAudio = true;
      update([Constant.idGetOldChat]);
      onScrollDown();
      Sfx.recordSent();

      sendImageAudioModel = await SendImageAudioApi.callApi(
        chatTopicId: chatTopicId ?? '',
        receiverId: receiverId.toString(),
        messageType: 3,
        filePath: audioPath,
      );

      final serverAudio = sendImageAudioModel?.chat?.audio;
      if (sendImageAudioModel?.status == true && serverAudio != null && serverAudio.isNotEmpty) {
        optimistic.audio = serverAudio;
        optimistic.message = sendImageAudioModel?.chat?.message ?? optimistic.message;
        update([Constant.idGetOldChat]);
        SocketEmit.sendMessage(_payload(messageType: 3, localId: localId, message: optimistic.message ?? '', audio: serverAudio));
        _armAck(localId);
      } else {
        optimistic.pending = false;
        optimistic.failed = true;
        isLoadingAudio = false;
        update([Constant.idGetOldChat]);
        Utils.showToast(Get.context!, sendImageAudioModel?.message ?? "Couldn't upload the voice note.");
      }
      isSendingAudioFile = false;
      updateAudioUI();
    } catch (e) {
      isSendingAudioFile = false;
      isRecordingAudio = false;
      isLoadingAudio = false;
      update([Constant.idChangeAudioRecordingEvent, Constant.idGetOldChat]);
      Utils.showLog("Audio Recording Stop Failed => $e");
    }
  }

  Future<void> updateAudioUI() async {
    await Future.delayed(const Duration(milliseconds: 100));
    update([Constant.idChangeAudioRecordingEvent]);
  }

  Future<void> onChangeTimer() async {
    timer?.cancel();
    if (isRecordingAudio) {
      countTime = 0;
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (t) {
          if (!isRecordingAudio) {
            countTime = 0;
            t.cancel();
            update([Constant.idChangeAudioRecordingEvent]);
            return;
          }
          countTime++;
          update([Constant.idChangeAudioRecordingEvent]);
          if (countTime >= _maxRecordingSeconds) onStopAudioRecording();
        },
      );
    } else {
      countTime = 0;
      update([Constant.idChangeAudioRecordingEvent]);
    }
  }

  Future<void> onScrollDown() async {
    try {
      await 10.milliseconds.delay();
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.fastOutSlowIn,
      );
      await 220.milliseconds.delay();
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      Utils.showLog("Scroll Down Failed => $e");
    }
  }

  String formatTime() {
    try {
      return DateFormat('hh:mm a').format(DateTime.now());
    } catch (e) {
      Utils.showLog("Error in format time :: $e");
      return "";
    }
  }
}
