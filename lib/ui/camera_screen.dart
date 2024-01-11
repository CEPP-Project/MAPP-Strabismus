import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'loading_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double width = 0;
  double height = 0;
  List<XFile?> capturedPhotos = List.filled(3, null);
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  int nowCamera = 0;
  List<bool> isPhotoCaptured = [false, false, false, false];

  void _onFlipCamera() async {
    // Ensure that the controller is initialized
    if (!_controller.value.isInitialized) {
      return;
    }

    // Dispose of the current controller
    await _controller.dispose();

    // Flip the camera
    isFrontCamera = !isFrontCamera;
    nowCamera = 1 - nowCamera;
    CameraDescription newDescription = cameras[nowCamera];

    // Initialize a new controller
    _controller = CameraController(newDescription, ResolutionPreset.medium);
    await _controller.initialize();

    if (isFrontCamera) {
      // Clear flash if switch to front camera
      await _controller.setFlashMode(FlashMode.off);
      setState(() {
        isFlashOn = false;
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onCapturePhoto(int buttonIndex) async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (!isFlashOn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Flash Required'),
            content: const Text('Please turn on the flash to capture a photo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      final XFile photo = await _controller.takePicture();

      setState(() {
        capturedPhotos[buttonIndex] = photo;
        isPhotoCaptured[buttonIndex] = true;
      });
    } catch (e) {
      // print("Error capturing photo: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    isFrontCamera = cameras.isNotEmpty &&
        cameras[0].lensDirection == CameraLensDirection.front;
    nowCamera = 0;

    _controller = CameraController(cameras[0], ResolutionPreset.medium);

    await _controller.initialize();

    if (!mounted) {
      return;
    }

    await _controller.setFlashMode(FlashMode.off);

    setState(() {
      isCameraReady = true;
    });
  }

  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (isFrontCamera) {
      return;
    }

    if (_controller.value.flashMode == FlashMode.off) {
      await _controller.setFlashMode(FlashMode.torch);
      setState(() {
        isFlashOn = true;
      });
    } else {
      await _controller.setFlashMode(FlashMode.off);
      setState(() {
        isFlashOn = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    if (!isCameraReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Camera Screen'),
      // ),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  Positioned(
                    left: width * 0.10,
                    top: height * 0.4,
                    child: Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(30),
                          right: Radius.circular(30),
                        ),
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: width * 0.3,
                    top: height * 0.4,
                    child: Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(30),
                          right: Radius.circular(30),
                        ),
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  color: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPhotoWidget(0),
                      _buildPhotoWidget(1),
                      _buildPhotoWidget(2),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            size: 36,
                            color: Colors.black,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_android,
                            size: 36,
                            color: Colors.black,
                          ),
                          onPressed: _onFlipCamera,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to SummaryScreen on button press
                          if (isPhotoCaptured[0]==false||isPhotoCaptured[1]==false||isPhotoCaptured[2]==false) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Incomplete Photos'),
                                  content: const Text(
                                      'Please take photos for all perspective before proceeding.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (isFlashOn) {
                              _toggleFlash();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadingScreen(
                                        photos: capturedPhotos,
                                      )),
                            );
                          }
                        },
                        child: const Text('Finish'),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(int index) {
    return GestureDetector(
        onTap: () {
          _onCapturePhoto(index);
        },
        child: Container(
          width: width * 0.2,
          height: height * 0.175,
          color: isPhotoCaptured[index] ? Colors.transparent : Colors.blueGrey,
          child: capturedPhotos[index] != null
              ? Image.file(
                  File(capturedPhotos[index]!.path),
                  width: width * 0.2,
                  height: height * 0.175,
                )
              : Container(
                  width: width * 0.2,
                  height: height * 0.175,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        index == 0
                            ? 'Roll the eyes left.'
                            : index == 1
                                ? 'Roll the eyes middle.'
                                : 'Roll the eyes right.',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
