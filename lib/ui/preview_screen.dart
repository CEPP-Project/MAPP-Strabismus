import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'loading_screen.dart';

class PreviewScreen extends StatelessWidget {
  final List<XFile?> photos;

  const PreviewScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Screen'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return _buildBody(orientation);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            // Check if all photos are taken
            if (photos.every((photo) => photo != null)) {
              // Navigate to ResultScreen if all photos are taken
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoadingScreen(photos: photos)),
              );
            } else {
              // Show a pop-up if not all photos are taken
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
            }
          },
          child: const Text('Go to Summary Screen'),
        ),
      ),
    );
  }

  Widget _buildBody(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildPhotoWidgets(),
          ));
    } else {
      return Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildPhotoWidgets(),
          ));
    }
  }

  List<Widget> _buildPhotoWidgets() {
    List<Widget> widgets = [];
    for (int i = 0; i < photos.length; i++) {
      if (i == 0) {
        widgets.add(_buildPhotoWidget(photos[i], 'Left'));
      } else if (i == 1) {
        widgets.add(_buildPhotoWidget(photos[i], 'Middle'));
      } else if (i == 2) {
        widgets.add(_buildPhotoWidget(photos[i], 'Right'));
      }
    }
    return widgets;
  }

  Widget _buildPhotoWidget(XFile? photo, String buttonName) {
    return Column(
      children: [
        Text('$buttonName Photo'),
        const SizedBox(height: 2),
        if (photo != null)
          Image.file(
            File(photo.path),
            width: 200,
            height: 200,
          )
        else
          const Text('No photo captured'),
        const SizedBox(height: 4),
      ],
    );
  }
}
