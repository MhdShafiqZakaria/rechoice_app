import 'package:flutter/material.dart';
import 'package:rechoice_app/components/my_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      //LOGO ReChoice
                      Image.asset(
                        'assets/images/logo.png',
                        height: 250,
                        width: 250,
                      ),

                      SizedBox(height: 10),

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
                Expanded(
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
                          Row(
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

                          SizedBox(height: 10),

                          Mytextfield(
                            controller: emailController,
                            hintText: 'Enter your email or phone number',
                            obscureText: false,
                          ),

                          SizedBox(height: 20),

                          //password textfield
                          Row(
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

                          SizedBox(height: 10),

                          Mytextfield(
                            controller: passwordController,
                            hintText: 'Enter your password',
                            obscureText: true,
                          ),

                          //forgot password textbutton

                          //signin button

                          //or continue with

                          //google button

                          // don't have an account? sign up textbutton

                          //user or admin login toggle
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
