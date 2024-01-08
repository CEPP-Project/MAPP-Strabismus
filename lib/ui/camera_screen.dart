import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> items = ["left", "middle", "right", ""];
  double scrollItemHeight = 25.0;
  int selectedIndex = 0;

  List<XFile?> capturedPhotos = List.filled(3, null);
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  int nowCamera = 0;
  List<bool> isPhotoCaptured = [false, false, false,false];

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
        capturedPhotos[buttonIndex - 1] = photo;
        isPhotoCaptured[buttonIndex - 1] = true;
      });
    } catch (e) {
      // print("Error capturing photo: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scrollController.addListener(_scrollListener);
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

  void _scrollListener() {
    double center = _scrollController.offset +
        _scrollController.position.viewportDimension / 2 -
        35;
    int middleIndex = (center / scrollItemHeight).round();

    setState(() {
      selectedIndex = middleIndex;
    });

    // Do something with the middleIndex, like updating the UI or performing an action
    //print("Middle Index: $middleIndex");
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              width: 250,
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 40,
                    child: Container(
                      width: 100,
                      height: 60,
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
                    right: 0,
                    top: 40,
                    child: Container(
                      width: 100,
                      height: 60,
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            size: 36,
                            color: Colors.black,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: _buildCaptureButton(),
                      ),
                      SizedBox(
                        height: 60.0,
                        width: 80,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: items.length,
                          itemExtent: scrollItemHeight,
                          itemBuilder: (context, index) {
                            return Center(
                              child: Text(
                                items[index],
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: isPhotoCaptured[index]
                                      ? Colors.green
                                      : index == selectedIndex
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
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
                          if (isFlashOn) {
                            _toggleFlash();
                          }
                          // Navigate to SummaryScreen on button press
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PreviewScreen(
                                      photos: capturedPhotos,
                                    )),
                          );
                        },
                        child: const Text('Finish'),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return SizedBox(
      width: 100,
      height: 100,
      child: InkWell(
        onTap: () {
          _onCapturePhoto(selectedIndex + 1);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}
