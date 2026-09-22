import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:video_player/video_player.dart';

class FakeVideoCallController extends GetxController {
  CameraController? cameraController;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  String hostName = "";
  String hostImage = "";
  String videoUrl = "";
  String channel = "";
  String hostId = "";
  String callId = "";
  String callMode = "";
  bool isBackProfile = false;

  Timer? timer;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  int? minutes;
  int? seconds;
  String? finalDuration;
  String? formattedTime = "00:00";
  Widget? localView;
  int? localViewID;

  bool isMute = false;
  bool isVideoOn = true;
  bool isRotedCamera = false;
  var randomNumber = 90.obs;

  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  @override
  void onInit() {
    List<dynamic> args = Get.arguments ?? [];
    if (args.isNotEmpty && args[0] != null) {
      videoUrl = args[0]!;
      isBackProfile = args[1]!;

      Utils.showLog("is back profile in fake video call $isBackProfile");
      Utils.showLog(" fake video call video url  $videoUrl");
    }
    onRequestPermissions();
    generateRandomNumber();
    1.seconds.delay();
    initializeVideoPlayer();

    1.seconds.delay();
    startTimer();

    super.onInit();
  }

  @override
  void onClose() {
    Utils.showLog("Enter in host video call controller close");
    stopTimer();
    onDisposeVideoPlayer();
    onDisposeCamera();
    super.dispose();
  }

  void generateRandomNumber() {
    final random = Random();
    randomNumber.value = random.nextInt(191) + 10; // Random between 10 and 200
  }

  Future<void> onRequestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    if (camera.isGranted && microphone.isGranted) {
      onInitializeCamera();
    } else {
      Utils.showToast(Get.context!, "Please allow permission !!");
    }
  }

  Future<void> onInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.last; // Use the first available camera
      cameraController = CameraController(camera, ResolutionPreset.medium);
      await cameraController!.initialize();

      update([Constant.onInitializeCamera]);
    } catch (e) {
      Utils.showLog("Error initializing camera: $e");
    }
  }

  Future<void> onDisposeCamera() async {
    Utils.showLog("Enter in host video call controller dispose camera");

    cameraController?.dispose();
    cameraController = null;
    Utils.showLog("Camera Controller Dispose Success");
  }

  Future<void> onSwitchCamera() async {
    Get.dialog(barrierDismissible: false, const PopScope(canPop: false, child: LoadingWidget())); // Start Loading...

    cameraLensDirection = cameraLensDirection == CameraLensDirection.back ? CameraLensDirection.front : CameraLensDirection.back;
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((camera) => camera.lensDirection == cameraLensDirection);
    cameraController = CameraController(camera, ResolutionPreset.high);
    await cameraController!.initialize();

    update([Constant.onInitializeCamera]);
    Get.back(); // Stop Loading...
  }

  void startTimer() {
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final duration = DateTime.now().difference(startTime ?? DateTime.now());
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      if (seconds == 0) {
        Utils.showLog('Start timer :: $formattedTime');
      }

      update([Constant.idOnVideoCall]);
    });
  }

  void stopTimer() {
    Utils.showLog("Enter in host video call controller stop timer");

    endTime = DateTime.now();
    timer?.cancel();
    timer = null;

    duration = endTime?.difference(startTime!);
    minutes = duration?.inMinutes.remainder(60);
    seconds = duration?.inSeconds.remainder(60);
    finalDuration = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    Utils.showLog('Call Duration :: $duration');
    Utils.showLog('Final Duration :: $finalDuration');
  }

  void muteMic() {
    isMute = !isMute;
    update([Constant.idMuteMic, Constant.idOnVideoCall]);
  }

  Future<void> toggleCamera() async {
    isRotedCamera = !isRotedCamera;

    cameraLensDirection = cameraLensDirection == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;

    try {
      final cameras = await availableCameras();
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == cameraLensDirection,
      );

      await cameraController?.dispose();

      cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
      );

      await cameraController!.initialize();

      update([Constant.onInitializeCamera, Constant.idToggleCamera, Constant.idOnVideoCall]);
    } catch (e) {
      Utils.showLog("Camera switch error: $e");
    }
  }

  void toggleVideo() {
    isVideoOn = !isVideoOn;
    update([Constant.onInitializeCamera, Constant.idToggleVideo, Constant.idOnVideoCall]);
  }

  Future<void> initializeVideoPlayer() async {
    try {
      Utils.showLog("Video Url =>'${Api.baseUrl + videoUrl}'");
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(Api.baseUrl + videoUrl));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          looping: true,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
          maxScale: 1,
        );
        videoPlayerController?.play();
        update([Constant.initializeVideoPlayer]);
      }
    } catch (e) {
      onDisposeVideoPlayer();
      Utils.showLog("Reels Video Initialization Failed !!! => $e");
    }
  }

  void onDisposeVideoPlayer() {
    Utils.showLog("Enter in host video call controller dispose video player");

    try {
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
    } catch (e) {
      Utils.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }
}
