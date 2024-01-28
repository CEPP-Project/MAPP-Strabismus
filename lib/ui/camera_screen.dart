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
  double camWidth = 0;
  double camHeight = 0;
  double menuSize = 150;
  double eyewidth = 0;
  double eyeheight =0;
  List<XFile?> capturedPhotos = List.filled(3, null);
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isPreviewVisible = true;
  int nowCamera = 0;
  List<bool> isPhotoCaptured = [false, false, false, false];

  void _onFlipCamera() async {
    // Ensure that the controller is initialized
    if (!_controller.value.isInitialized || !isPreviewVisible) {
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
    if (!_controller.value.isInitialized || !isPreviewVisible) {
      return;
    }
    // if (!isFlashOn) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Flash Required'),
    //         content: const Text('Please turn on the flash to capture a photo.'),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('OK'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   return;
    // }
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
    nowCamera = 0;
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
      camWidth = _controller.value.previewSize?.width ?? 0.0;
      camHeight = _controller.value.previewSize?.height ?? 0.0;

      // print(camWidth);
      // print(camHeight);
      isFlashOn = false;
      isPreviewVisible = true;
      isCameraReady = true;
    });
  }

  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (isFrontCamera || !isPreviewVisible) {
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

  void _toggleCamera() {
    if (isPreviewVisible) {
      if (isFlashOn) {
        _toggleFlash();
        setState(() {
          isFlashOn = false;
        });
      }
      _controller.dispose();
      setState(() {
        isPreviewVisible = false;
      });
    } else {
      _initializeCamera();
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
    eyewidth = (width-menuSize)/3;
    eyeheight = height/3;
    // print(width);
    // print(height);
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
          isPreviewVisible
              ? SizedBox(
                  height: height,
                  width: width - menuSize,
                  child: CameraPreview(_controller),
                )
              : SizedBox(
                  width: width - menuSize,
                  height: height,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Camera is disable.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          isPreviewVisible
              ? Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Positioned(
                          left: (width-menuSize)/4-eyewidth/2,
                          top: height/2-eyeheight/2,
                          child: Container(
                            width: eyewidth,
                            height: eyeheight,
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
                          left: 3*(width-menuSize)/4-eyewidth/2,
                          top: height/2-eyeheight/2,
                          child: Container(
                            width: eyewidth,
                            height: eyeheight,
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
                )
              : Container(),
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
                        padding: const EdgeInsets.all(0),
                        child: IconButton(
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            size: 30,
                            color: Colors.black,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_android,
                            size: 30,
                            color: Colors.black,
                          ),
                          onPressed: _onFlipCamera,
                        ),
                      ),
                      SizedBox(
                        width: menuSize,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: _toggleCamera,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(9),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                  isPreviewVisible ? 'Stop Cam' : 'Start Cam',
                                  style: const TextStyle(fontSize: 15)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                // Navigate to SummaryScreen on button press
                                if (isPhotoCaptured[0] == false ||
                                    isPhotoCaptured[1] == false ||
                                    isPhotoCaptured[2] == false) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Incomplete Photos',
                                            style: TextStyle(fontSize: 10)),
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
                        ),
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
          width: menuSize,
          height: height * 0.175,
          color: isPhotoCaptured[index] ? Colors.transparent : Colors.blueGrey,
          child: capturedPhotos[index] != null
              ? Image.file(
                  File(capturedPhotos[index]!.path),
                  width: menuSize,
                  height: height * 0.175,
                )
              : Container(
                  width: menuSize,
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
                      const SizedBox(height: 8),
                      Text(
                        index == 0
                            ? 'Roll the eyes left.'
                            : index == 1
                                ? 'Roll the eyes middle.'
                                : 'Roll the eyes right.',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
