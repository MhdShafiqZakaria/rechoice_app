import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final emailController = TextEditingController();
  String errorMessage = '';

  //Reset Password Method
  void resetPassword() async {
    try {
      await authService.value.resetPassword(email: emailController.text);
      showSnackBar();
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'This is not working';
      });
    }
  }

  //snackbar for confirmation
  void showSnackBar() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'Please check your email',
          style: TextStyle(color: Colors.black),
        ),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[700]!,
                  Colors.blue[500]!,
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: <Widget>[
                      //LOGO ReChoice
                      Image.asset(
                        'assets/images/logo.png',
                        height: 250,
                        width: 250,
                        color: Colors.white,
                      ),

                      //text Reset Password
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Enter your email to receive a reset link',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                //white container
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 30),

                          //email textfield
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Enter Your Email',
                            ),
                          ),

                          SizedBox(height: 20),

                          GestureDetector(
                            onTap: resetPassword,
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  colors: [
                                    Colors.blue[800]!,
                                    Colors.blue[400]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.redAccent),
                          ),

                          // Remember your password? Sign In
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Remember your password?',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),

                                SizedBox(width: 3),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/');
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        230,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
