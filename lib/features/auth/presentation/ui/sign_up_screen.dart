import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 36,),

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

                  SizedBox(height: 36,),

                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      'Create an Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "Enter your username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            prefixIcon: Icon(Icons.person, color: Color(0xFF1976D2),)
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a username";
                            }
                            if (value.length < 6) {
                              return "Username must be at least 6 characters long";
                            }
                            if (value.length > 20) {
                              return "Username must be at most 20 characters long";
                            }
                            if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                              return "Only letters, numbers, '.' and '_' are allowed";
                            }
                            return null; // hợp lệ
                          },
                        ),

                        SizedBox(height: 24),

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
                                          await authViewModel.signUp(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                            _usernameController.text.trim()
                                          );

                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Account created successfully!"),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            await Future.delayed(const Duration(seconds: 2));
                                            Navigator.pushReplacementNamed(context, "/home");
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Sign up failed. Please try again."),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        } on FirebaseAuthException catch (e) {
                                          String message = switch (e.code) {
                                            "email-already-in-use" => "This email is already registered",
                                            "weak-password" => "Password should be at least 6 characters",
                                            "invalid-email" => "Invalid email format",
                                            _ => "Sign up failed. Please try again"
                                          };
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(message),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 3),
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
                                    child: const Center(
                                      child: Text(
                                        "Sign Up",
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

                        SizedBox(height: 25),

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
                              "Already have an account?",
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, "/signIn");
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero
                              ),
                              child: const Text(
                                "SIGN IN",
                                style: TextStyle(
                                    color: Color(0xFF1976D2)
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
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
      )
    );
  }
}