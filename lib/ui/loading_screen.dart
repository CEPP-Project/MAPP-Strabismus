
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'summary_screen.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }
  @override
  void dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _processData(BuildContext context) async {
    // Simulate API call with a delay
    await Future.delayed(const Duration(seconds: 3));

    // Call API HERE !!!!


    // You can pass any result to the next screen, such as processed data
    var result = "Processed Data";
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SummaryScreen(result: result)));
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