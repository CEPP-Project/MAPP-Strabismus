import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'loading_screen.dart';

class PreviewScreen extends StatefulWidget {
  final List<XFile?> photos;

  const PreviewScreen({super.key, required this.photos});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  double width=0;
  double height=0;

  @override
  Widget build(BuildContext context) {
    width= MediaQuery.of(context).size.width;
    height= MediaQuery.of(context).size.height;
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
            if (widget.photos.every((photo) => photo != null)) {
              // Navigate to ResultScreen if all photos are taken
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoadingScreen(photos: widget.photos)),
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
            children: _buildPhotoWidgets(orientation),
          ));
    } else {
      return Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildPhotoWidgets(orientation),
          ));
    }
  }

  List<Widget> _buildPhotoWidgets(Orientation orientation) {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.photos.length; i++) {
      if (i == 0) {
        widgets.add(_buildPhotoWidget(widget.photos[i], 'Left', orientation));
      } else if (i == 1) {
        widgets.add(_buildPhotoWidget(widget.photos[i], 'Middle', orientation));
      } else if (i == 2) {
        widgets.add(_buildPhotoWidget(widget.photos[i], 'Right', orientation));
      }
    }
    return widgets;
  }

  Widget _buildPhotoWidget(XFile? photo, String buttonName,Orientation orientation) {
    return Column(
      children: [
        Text('$buttonName Photo'),
        const SizedBox(height: 2),
        if (photo != null && orientation == Orientation.portrait)
          Image.file(
            File(photo.path),
            width: width*0.5,
            height: height*0.2,
          )
        else if(photo != null && orientation == Orientation.landscape)
          Image.file(
            File(photo.path),
            width: width*0.2,
            height: height*0.5,
          )

        else
          const Text('No photo captured'),
        const SizedBox(height: 4),
      ],
    );
  }
}
