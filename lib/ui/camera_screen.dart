import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  void _onFlipCamera() async {
    // Ensure that the controller is initialized
    if (!_controller.value.isInitialized) {
      return;
    }

    // Dispose of the current controller
    await _controller.dispose();

    // Flip the camera
    isFrontCamera = !isFrontCamera;
    CameraDescription newDescription =
    isFrontCamera ? cameras[1] : cameras[0]; // Assuming front camera is at index 1

    // Initialize a new controller
    _controller = CameraController(newDescription, ResolutionPreset.medium);
    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }
  List<XFile?> capturedPhotos = List.filled(3, null);

  Future<void> _onCapturePhoto(int buttonIndex) async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if(!isFlashOn){
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
    }
    try {
      final XFile photo = await _controller.takePicture();

      setState(() {
        capturedPhotos[buttonIndex - 1] = photo;
      });
    } catch (e) {
     // print("Error capturing photo: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(cameras[0], ResolutionPreset.medium);

    await _controller.initialize();

    if (!mounted) {
      return;
    }

    setState(() {
      isCameraReady = true;
    });
  }

  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) {
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
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
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
                    top: 20,
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
                    top: 20,
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
            alignment: Alignment.topRight,
            child: Padding(
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onCapturePhoto(1),
                  child: const Text('left'),
                ),
                ElevatedButton(
                  onPressed: () => _onCapturePhoto(2),
                  child: const Text('middle'),
                ),
                ElevatedButton(
                  onPressed: () => _onCapturePhoto(3),
                  child: const Text('right'),
                ),
                ElevatedButton(
                  onPressed: _onFlipCamera, // Call the flip camera function
                  child: const Text('Flip Camera'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to SummaryScreen on button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreviewScreen(
                        photos: capturedPhotos,
                      )),
                    );
                  },
                  child: const Text('Preview'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
