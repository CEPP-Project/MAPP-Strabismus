import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strabismus/ui/camera_screen.dart';
import 'package:strabismus/ui/mainmenu_screen.dart';
import 'package:http/http.dart' as http;
import 'package:strabismus/ui/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Picture on the Top Middle
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'lib/resource/logo.png', // Path to your logo picture
                height: 100.0,
                width: 100.0,
              ),
            ),
            // Username Field
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            // Password Field
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
            ),
            // No account? Register
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'No account? Register',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                // login send username password to api for token
                onPressed: () {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  _login(username, password).then((result){
                    if(result==0){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                      );
                    }
                    else if(result==1){
                      _errorPopup('Authentication Error!!!', 'Username or Password is wrong.');
                    }
                    else if(result==2){
                      _errorPopup('Authentication Error!!!', 'Missing Username or Password.');
                    }
                    else if(result==3){
                      _errorPopup('Authentication Error!!!', 'Unknown error has occurred.');
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222930), // Background color
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18.0,color: Colors.white,),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            // Continue as Guest
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: TextButton(
                onPressed: () {
                  // Continue as guest no authentication
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF222930), // Background color
                ),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(fontSize: 18.0,color: Colors.white,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future _errorPopup(String title,String detail){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(title,
              style: const TextStyle(fontSize: 20)),
          content:  Text(
              detail),
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

  Future<int> _login(String username, String password) async{
    // Implement your API call here using username and password
    if(username.isEmpty||password.isEmpty){
      return 2;
    }
    try {
      final response = await http.post(
          Uri.parse('https://mapp-api.redaxn.com/auth/login'),
          headers: {'Content-Type':'application/json'},
          body: jsonEncode({'username':username, 'password': password})
      );
      // print("response status code: ${response.statusCode}");
      // print("response body: ${response.body}");
      if (response.statusCode == 200) {
        //assign token then return login success
        final token = jsonDecode(response.body)['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return 0;
      }
      else{
        return 1;
      }
      // Call your API function here passing username and password
    }catch(e) {
      // Handle other errors
     // print('Error : $e');
      return 3;
    }
  }
}