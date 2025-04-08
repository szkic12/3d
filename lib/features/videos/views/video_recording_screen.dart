// import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok/constants/sizes.dart';
import 'package:tiktok/constants/gaps.dart';

import 'package:tiktok/features/videos/views/video_preview_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";

  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _isSelfieMode = false;
  bool _prepareDispose = false;
  // late final bool _noCamera = !Platform.isIOS; // iOS device
  late final bool _noCamera = kDebugMode && Platform.isIOS; // Simulator

  late final AnimationController _buttonAnimationController =
      AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 200),
  );

  late final Animation<double> _buttonAnimation =
      Tween(begin: 1.0, end: 1.2).animate(_buttonAnimationController);

  late final AnimationController _progressAnimationControlloer =
      AnimationController(
    vsync: this,
    duration: Duration(seconds: 3), // 10
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  late FlashMode _flashMode;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    initPermissions();

    // if (!_noCamera) {
    //   initPermissions();
    // } else {
    //   setState(() {
    //     _hasPermission = true;
    //   });
    // }

    WidgetsBinding.instance.addObserver(this);

    _progressAnimationControlloer.addListener(() {
      setState(() {});
    });
    _progressAnimationControlloer.addStatusListener((status) {
      // listene status (when the animation finished)
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });
  }

  @override
  void dispose() {
    _progressAnimationControlloer.dispose();
    _buttonAnimationController.dispose();
    if (!_noCamera) _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_noCamera) return;
    if (!_hasPermission) return;
    if (!_cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _prepareDispose = true;
      setState(() {});
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _prepareDispose = false;
      initCamera();
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    _cameraController = CameraController(
      cameras[_isSelfieMode ? 1 : 0],
      ResolutionPreset.high,
      // enableAudio: false, // emulator bug
    );

    await _cameraController.initialize();
    await _cameraController.prepareForVideoRecording(); // only for iOS

    _flashMode = _cameraController.value.flashMode;

    if (!mounted) return;
    setState(() {});
  }

  Future<void> initPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    final cameraDenied =
        cameraPermission.isDenied || cameraPermission.isPermanentlyDenied;

    final microphoneDenied = microphonePermission.isDenied ||
        microphonePermission.isPermanentlyDenied;

    if (!cameraDenied && !microphoneDenied) {
      _hasPermission = true;
      if (!_noCamera) {
        await initCamera(); // !!
      }
      setState(() {});
    }
  }

  Future<void> _toggleSelfieMode() async {
    _isSelfieMode = !_isSelfieMode;
    await initCamera();
    setState(() {});
  }

  Future<void> _setFlashMode(FlashMode newFlashMode) async {
    await _cameraController.setFlashMode(newFlashMode);
    _flashMode = newFlashMode;
    setState(() {});
  }

  Future<void> _startRecording(TapDownDetails _) async {
    if (_noCamera || _cameraController.value.isRecordingVideo) return;

    await _cameraController.startVideoRecording();

    _buttonAnimationController.forward();
    _progressAnimationControlloer.forward();
  }

  Future<void> _stopRecording() async {
    if (_noCamera || !_cameraController.value.isRecordingVideo) return;

    _buttonAnimationController.reverse();
    _progressAnimationControlloer.reset();

    final video = await _cameraController.stopVideoRecording(); // Future<XFile>

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          video: video,
          isPicked: false,
        ),
      ),
    );
  }

  Future<void> _onPickVideoPressed() async {
    final video = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return;
    // print("Video Name: ${video.name}"); // .jpg
    // print("Video Path: ${video.path}"); // .jpg

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          video: video,
          isPicked: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: !_hasPermission
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Initializing...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.size20,
                    ),
                  ),
                  Gaps.v20,
                  CircularProgressIndicator.adaptive(),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (!_prepareDispose && !_noCamera)
                    CameraPreview(
                      _cameraController,
                    ),
                  Positioned(
                    top: Sizes.size40,
                    left: Sizes.size20,
                    child: CloseButton(
                      color: Colors.white,
                    ),
                  ),
                  if (!_noCamera)
                    Positioned(
                      top: Sizes.size40,
                      right: Sizes.size12,
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: _toggleSelfieMode,
                            icon: Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            onPressed: () => _setFlashMode(FlashMode.off),
                            icon: Icon(
                              Icons.flash_off_rounded,
                              color: _flashMode == FlashMode.off
                                  ? Colors.amber.shade200
                                  : Colors.white,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            onPressed: () => _setFlashMode(FlashMode.always),
                            icon: Icon(
                              Icons.flash_on_rounded,
                              color: _flashMode == FlashMode.always
                                  ? Colors.amber.shade200
                                  : Colors.white,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            onPressed: () => _setFlashMode(FlashMode.auto),
                            icon: Icon(
                              Icons.flash_auto_rounded,
                              color: _flashMode == FlashMode.auto
                                  ? Colors.amber.shade200
                                  : Colors.white,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            onPressed: () => _setFlashMode(
                                FlashMode.torch), // 손전등 모드, 후면(0)에서만 작동
                            icon: Icon(
                              Icons.flashlight_on_rounded,
                              color: _flashMode == FlashMode.torch
                                  ? Colors.amber.shade200
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: Sizes.size40,
                    child: Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTapDown: _startRecording,
                          onTapUp: (details) => _stopRecording(),
                          child: ScaleTransition(
                            scale: _buttonAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 86.0,
                                  height: 86.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.red.shade400,
                                    strokeWidth: Sizes.size4,
                                    value: _progressAnimationControlloer.value,
                                  ),
                                ),
                                Container(
                                  width: 76.0,
                                  height: 76.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: _onPickVideoPressed,
                              icon: FaIcon(
                                FontAwesomeIcons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
