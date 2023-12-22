import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'summary_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;

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
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement functionality for the left button
                  },
                  child: const Text('left'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement functionality for the middle button
                  },
                  child: const Text('middle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement functionality for the right button
                  },
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
                      MaterialPageRoute(builder: (context) => const SummaryScreen()),
                    );
                  },
                  child: const Text('Summary'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
