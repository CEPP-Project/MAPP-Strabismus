
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'summary_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class LoadingScreen extends StatefulWidget {
  final List<XFile?> photos;

  const LoadingScreen({super.key, required this.photos});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _processData(context);
  }
  @override
  void dispose(){
    super.dispose();
  }

  Future<void> _processData(BuildContext context) async {
    // Simulate API call with a delay
    // await Future.delayed(const Duration(seconds: 3));

    // Call API HERE !!!!
    try {
      var apiUrl = Uri.parse('https://mapp-api.redaxn.com/upload-images'); // real api
      // var apiUrl = Uri.parse('http://10.0.2.2:8000/upload-images'); // testing with emulate
      // var apiUrl = Uri.parse('http://192.168.x.x:8000/upload-images'); // testing with device on local network

      var request = http.MultipartRequest('POST', apiUrl);

      for (int i = 0; i < widget.photos.length; i++) {
        var file = File(widget.photos[i]!.path);
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();

        var multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: p.basename(file.path),
          contentType: MediaType.parse(getContentType(file.path)),
        );

        // print(p.basename(file.path));
        // print('File: ${file.path}, Content Type: ${multipartFile.contentType}');

        request.files.add(multipartFile);
      }

      var response = await request.send().timeout(const Duration(seconds: 30));
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${await response.stream.bytesToString()}');

      if (response.statusCode == 200) {
        // API call was successful, process the response as needed
        var responseBody = await response.stream.bytesToString();

        var result = json.decode(responseBody);
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SummaryScreen(result: result)));
        }
        
      } else {
        // API call failed, handle the error
        // print('Failed to upload images. Status code: ${response.statusCode}');
      }

    } catch(e) {
      // Handle other errors
      // print('Error uploading images: $e');
    }

    // You can pass any result to the next screen, such as processed data
    // var result = "Processed Data";
    // if(context.mounted){
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => SummaryScreen(result: result)));
    // }
  }

  String getContentType(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.jpeg':
      case '.jpg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Screen'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}