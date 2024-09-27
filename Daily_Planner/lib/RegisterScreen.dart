import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _errorMessage = '';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_password != _confirmPassword) {
        setState(() {
          _errorMessage = 'Mật khẩu không khớp';
        });
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Đăng ký thành công
        print('UID: ${userCredential.user!.uid}');
        Navigator.pop(context); // Quay lại trang đăng nhập
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue, // Màu nền
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Đăng ký',
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
                              'Đăng ký tài khoản',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Chào mừng bạn đến với ứng dụng. Hãy điền thông tin của bạn để tạo tài khoản.',
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
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Nhập lại mật khẩu',
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
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập lại mật khẩu';
                                }
                                return null;
                              },
                              onChanged: (value) => _confirmPassword = value,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Màu nền
                                  foregroundColor: Colors.white, // Màu chữ
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                ),
                                child: const Text('Đăng ký'),
                              ),
                            ),
                            if (_errorMessage.isNotEmpty)
                              Text(_errorMessage, style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Điều hướng đến trang đăng nhập
                                  Navigator.pop(context); // Quay lại trang trước đó
                                },
                                child: Text(
                                  'Đã có tài khoản? Đăng nhập ngay',
                                  style: TextStyle(
                                    color: Colors.blue, // Màu sắc theo ý bạn
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
