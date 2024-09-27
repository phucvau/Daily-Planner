import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'TaskListScreen.dart'; // Ensure this is the correct path
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Successful login, can access UID
        String uid = userCredential.user!.uid;
        print('UID: $uid');

        // Navigate to the task list screen and pass UID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TaskListScreen(uid: uid)), // Pass UID here
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        print('Error during login: $e'); // Log error for debugging
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue, // Background color
      ),
      home: Scaffold(
        appBar: AppBar(

          title: const Text(
            'Đăng nhập',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                height: 720,
                color: Colors.blue,
                padding: const EdgeInsets.all(0.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Planner',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Chào mừng bạn đến với ứng dụng lập kế hoạch Daily Planner, hy vọng bạn sẽ có trải nghiệm tốt khi sử dụng ứng dụng.',
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Gmail',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: CupertinoColors.extraLightBackgroundGray,
                                border: const OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                return null;
                              },
                              onChanged: (value) => _email = value,
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Mật khẩu',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: CupertinoColors.extraLightBackgroundGray,
                                border: const OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                              onChanged: (value) => _password = value,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Add forgot password action here
                                  print('Forgot Password pressed');
                                },
                                child: const Text(
                                  'Quên Mật Khẩu?',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: _login, // Call _login when pressed
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Background color
                                  foregroundColor: Colors.white, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                ),
                                child: const Text('Đăng nhập'),
                              ),
                            ),
                            if (_errorMessage.isNotEmpty)
                              Text(_errorMessage, style: TextStyle(color: Colors.blue)),
                            const SizedBox(height: 10),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Điều hướng đến trang đăng ký
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()), // Thay RegisterPage bằng trang đăng ký của bạn
                                  );
                                },
                                child: Text(
                                  'Chưa có tài khoản? Đăng kí ngay',
                                  style: TextStyle(
                                    color: Colors.blue, // Màu sắc theo ý bạn
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Add Google sign-up action here
                                  },
                                  icon: Image.asset('assets/images/ggicon.png'),
                                  iconSize: 40,
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: () {
                                    // Add Facebook sign-up action here
                                  },
                                  icon: Image.asset('assets/images/fbicon.png'),
                                  iconSize: 40,
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: () {
                                    // Add phone sign-up action here
                                  },
                                  icon: Image.asset('assets/images/phoneicon.png'),
                                  iconSize: 40,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
