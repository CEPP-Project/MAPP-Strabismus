import 'package:flutter/material.dart';
import 'package:strabismus/ui/mainmenu_screen.dart';

class SummaryScreen extends StatelessWidget {
  final dynamic result;

  const SummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Result Screen'),
      // ),
      body: Center(
        child: Text('Result: $result'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            );
          },
          child: const Text('Go back to Main menu'),
        ),
      ),
    );
  }
}