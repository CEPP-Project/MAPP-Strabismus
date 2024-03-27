import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strabismus/ui/login_screen.dart';
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
        color: Colors.grey,
        child: _returnButton(context)
      ),
    );
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Widget _returnButton(BuildContext context) {
    _getToken().then((result) {
      if (result.isNotEmpty) {
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            );
          },
          child: const Text('Go back to Main menu'),
        );
      } else {
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text('Go back to Login'),
        );
      }
    });
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: const Text('Go back to Login'),
    );
  }
}
