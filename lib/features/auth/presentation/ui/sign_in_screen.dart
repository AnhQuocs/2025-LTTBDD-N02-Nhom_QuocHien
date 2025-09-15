import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PhysicalModel(
                                color: Colors.white,
                                elevation: 6,
                                shadowColor: Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Fin Track",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(3.0, 3.0),
                                      blurRadius: 3.0,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 36),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "example@gmail.com",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: Icon(Icons.email, color: Color(0xFF1976D2))
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return "Invalid email";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  hintText: "Enter your password",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFF1976D2)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Color(0xFF1976D2),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  )
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }
                                if (value.length < 6) {
                                  return "The password must be at least 6 characters long";
                                }
                                return null;
                              },
                              obscureText: _isPasswordVisible ? false : true,
                              obscuringCharacter: "•",
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {

                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFF1976D2),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                child: Builder(
                                  builder: (BuildContext context) {
                                    return Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.blue, Colors.purple],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();

                                            try {
                                              await authViewModel.signIn(
                                                _emailController.text.trim(),
                                                _passwordController.text.trim(),
                                              );

                                              final user = FirebaseAuth.instance.currentUser;
                                              if (user != null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Login successful!"),
                                                    backgroundColor: Colors.green,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                await Future.delayed(Duration(seconds: 2));
                                                Navigator.pushReplacementNamed(context, "/dashboard");
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Login failed. Please try again."),
                                                    backgroundColor: Colors.red,
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              }
                                            } on FirebaseAuthException catch (e) {
                                              String message = switch (e.code) {
                                                "user-not-found" => "Email not found. Please register first",
                                                "wrong-password" => "Incorrect password. Please try again",
                                                "invalid-credential" => "Invalid credentials. Please check your email and password",
                                                _ => "Login failed. Please try again"
                                              };
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(seconds: 3),
                                                ),
                                              );
                                            } finally {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 45),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    backgroundColor: Color(0xFF0080FF)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 4),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/ic_facebook.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 36),
                                    Text(
                                      "Continue with Facebook",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    backgroundColor: Colors.white
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/ic_google.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 56),
                                    Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 36),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, "/signUp");
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero
                                  ),
                                  child: const Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                        color: Color(0xFF1976D2)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ]
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}