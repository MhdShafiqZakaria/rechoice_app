import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/btn_google_sign_in.dart';
import 'package:rechoice_app/components/btn_sign_in.dart';
import 'package:rechoice_app/components/my_text_field.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';

class Register extends StatefulWidget {
  final Function()? onPressed;

  const Register({super.key, required this.onPressed});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  //sign user in method
  void createAccount() async {
    try {
      await authService.value.register(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'User cannot Register';
      });
    }
  }

  //google sign in method
  void googleSignIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.blue[500]!],
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

                      SizedBox(height: 20),

                      //text Create Account// Join ReChoice to buy and sell PreLoved items
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Join ReChoice to buy and sell PreLoved items',
                        textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),

                          //enter name textfield
                          Text(
                            'Enter Your Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Mytextfield(
                            controller: nameController,
                            hintText: 'Enter Your Full Name',
                            obscureText: false,
                            icon: Icons.person,
                          ),

                          SizedBox(height: 20),

                          //email textfield
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Mytextfield(
                            controller: emailController,
                            hintText: ' Enter your email',
                            obscureText: false,
                            icon: Icons.email,
                          ),

                          SizedBox(height: 20),

                          //password textfield
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Mytextfield(
                            controller: passwordController,
                            hintText: 'Create a  strong password',
                            obscureText: true,
                            icon: Icons.lock,
                          ),

                          SizedBox(height: 30),

                          //sign in button (firebase auth)
                          Btn(onTap: createAccount, text: 'Create Account'),

                          SizedBox(height: 10),

                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          SizedBox(height: 20),

                          //or
                          Row(
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

                          SizedBox(height: 20),

                          //google button (firebase auth)
                          BtnGoogleSignIn(onTap: googleSignIn),

                          SizedBox(height: 20),

                          // Already have an account? Sign In textbutton
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Already have an account?',
                                style: TextStyle(color: Colors.grey[700]),
                              ),

                              SizedBox(width: 3),

                              TextButton(
                                onPressed: widget.onPressed,
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 230),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
