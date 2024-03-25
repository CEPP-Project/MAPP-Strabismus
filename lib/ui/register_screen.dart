import 'package:flutter/material.dart';
import 'package:strabismus/ui/login_screen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
            const SizedBox(height: 20.0),
            // Confirm Password Field
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Confirm Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
            ),
            // Have account? Login
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already Have Account? Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  String confirmPassword = _confirmPasswordController.text;
                  // Pass username and password to your registration function
                  _register(username, password, confirmPassword).then((result){
                    //register success
                    if(result==0){
                      _errorPopup('Register Success', 'Your registration is success.');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                    //password not match
                    else if(result==1){
                      _errorPopup('Password is not match!!!', 'Your password is not match.');
                    }
                    //already have this username
                    else if(result==2){
                      _errorPopup('Register Error!!!', 'Your username already taken.');
                    }
                    else if(result==3){
                      _errorPopup('Register Error!!!', 'Unknown error has occurred.');
                    }
                    else if(result==4){
                      _errorPopup('Register Error!!!', 'Missing username or password.');
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222930), // Background color
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18.0,color:Colors.white),
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

  Future<int> _register(String username, String password, String confirmPassword) async{
    // Implement your registration logic here
    if(username.isEmpty || password.isEmpty){
      return 4;
    }
    if(password!=confirmPassword){
      return 1;
    }
    try {
      var apiUrl = Uri.parse('https://mapp-api.redaxn.com/');
      var request = http.MultipartRequest('POST', apiUrl);
      var response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        //return register success
        return 0;
      }
      else{
        return 2;
      }
      // Call your API function here passing username and password
    }catch(e) {
      // Handle other errors
      // print('Error uploading images: $e');
      return 3;
    }
    // Call your registration API function here passing username, password, and confirmPassword
  }
}

