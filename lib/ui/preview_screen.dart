import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'summary_screen.dart';

class PreviewScreen extends StatelessWidget {
  final List<XFile?> photos;

  const PreviewScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Screen'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPhotoWidget(photos[0], 'Button 1'),
          _buildPhotoWidget(photos[1], 'Button 2'),
          _buildPhotoWidget(photos[2], 'Button 3'),
          const SizedBox(height: 16),
          ElevatedButton(

            onPressed: () {
              // Navigate to ResultScreen on button press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SummaryScreen()),
              );
            },
            child: const Text('Go to Result Screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(XFile? photo, String buttonName) {
    return Column(
      children: [
        Text('$buttonName Photo:'),
        const SizedBox(height: 8),
        if (photo != null)
          Image.file(
            File(photo.path),
            width: 200,
            height: 200,
          )
        else
          const Text('No photo captured'),
        const SizedBox(height: 16),
      ],
    );
  }
}
