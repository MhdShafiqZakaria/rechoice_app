import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/auth/btn_sign_in.dart';
import 'package:rechoice_app/components/auth/my_text_field.dart';
import 'package:rechoice_app/models/services/authenticate.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onPressed;
  const LoginPage({super.key,  this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  //sign user in method
  void signUserIn() async {
    try {
      print('DEBUG LoginPage: Starting sign in');
      print('DEBUG LoginPage: Calling authService.login()');
      await authService.value.login(
        email: emailController.text,
        password: passwordController.text,
      );
      print('DEBUG LoginPage: Login successful, authStateChanges will handle navigation');
      // Don't close page here - let authStateChanges handle navigation
    } on FirebaseAuthException catch (e) {
      print('DEBUG LoginPage: FirebaseAuthException caught: ${e.code} - ${e.message}');
      
      if (mounted) {
        print('DEBUG LoginPage: Showing error SnackBar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Login failed"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        setState(() {
          errorMessage = e.message ?? "Login failed";
        });
      }
    } catch (e) {
      print('DEBUG LoginPage: Generic exception caught: $e, Type: ${e.runtimeType}');
      
      if (mounted) {
        print('DEBUG LoginPage: Showing generic error SnackBar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        setState(() {
          errorMessage = 'An unexpected error occurred';
        });
      }
    }
  }

  void popPage() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  //google sign in method
  // Future<void> googleSignIn() async {
  //   try {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Center(child: CircularProgressIndicator());
  //       },
  //     );
  //     final userCredential = await authService.value.signInWithGoogle();
  //     popPage();
  //     if (userCredential != null) {
  //       Navigator.pushReplacementNamed(context, '/dashboard');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     popPage();
  //     setState(() {
  //       errorMessage = e.message ?? 'This is not working';
  //     });
  //   } catch (e) {
  //     popPage();
  //     setState(() {
  //       errorMessage = 'An unexpected error occurred. Please try again.';
  //     });
  //   }
  // }

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
            child: SingleChildScrollView(
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

                        //text Welcome Back ! Sign in to continue
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Sign in to your account to continue',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  //white container for textFields
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
                            SizedBox(height: 40),

                            //email/phone number textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email/Phone Number',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            Mytextfield(
                              controller: emailController,
                              hintText: 'Enter your email or phone number',
                              obscureText: false,
                              icon: Icons.email,
                            ),

                            SizedBox(height: 20),

                            //password textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            Mytextfield(
                              controller: passwordController,
                              hintText: 'Enter your password',
                              obscureText: true,
                              icon: Icons.lock,
                            ),

                            SizedBox(height: 10),

                            //forgot password textbutton
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/resetPW');
                                    },
                                    child: Text(
                                      'Forgot Password?',
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

                            SizedBox(height: 10),

                            //signin button (firebase auth)
                            Btn(onTap: signUserIn, text: 'Sign In'),

                            SizedBox(height: 15),
                            Text(
                              errorMessage,
                              style: TextStyle(color: Colors.redAccent),
                            ),

                            SizedBox(height: 20),

                            //or
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            //google button (firebase auth)
                            // BtnGoogleSignIn(onTap:
                            // googleSignIn
                            // ),
                            SizedBox(height: 10),

                            // don't have an account? sign up textbutton
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Don\'t have an account?',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),

                                  SizedBox(width: 3),

                                  TextButton(
                                    onPressed: widget.onPressed,
                                    child: Text(
                                      'Sign Up',
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

                            //admin login toggle
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Admin Access',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
      ),
    );
  }
}
