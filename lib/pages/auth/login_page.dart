import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/btn_google_sign_in.dart';
import 'package:rechoice_app/components/btn_sign_in.dart';
import 'package:rechoice_app/components/my_text_field.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';

class LoginPage extends StatefulWidget {
  final Function()? onPressed;
  const LoginPage({super.key, required this.onPressed});

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
      await authService.value.login(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "This is not working";
      });
    }
  }

  //google sign in method
  void googleSignIn() {}

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
                            BtnGoogleSignIn(onTap: googleSignIn),

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

                            //user or admin login toggle
                            Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,

                                children: [
                                  Text(
                                    'User',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
