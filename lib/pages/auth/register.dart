import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/btn_google_sign_in.dart';
import 'package:rechoice_app/components/btn_sign_in.dart';
import 'package:rechoice_app/components/my_text_field.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Register extends StatefulWidget {
  final Function()? onPressed;

  const Register({super.key, required this.onPressed});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  //sign user in method
  void createAccount() async {
    try {
      // 1. Create user
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'username':
        '${firstNameController.text.trim()}${lastNameController.text.trim()}',
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'bio': '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. IMPORTANT: Sign out after successful signup
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 4. Show success dialog → redirect to Login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text(
            'Your account has been created. Please log in to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                widget.onPressed?.call(); // switch to Login page
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Registration failed';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong: $e';
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 25.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // Text(
                                      //   'First Name',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10),

                                Flexible(
                                  child: Mytextfield(
                                    controller: firstNameController,
                                    hintText: 'First Name',
                                    obscureText: false,
                                    icon: Icons.person,
                                  ),
                                ),

                                SizedBox(width: 10),

                                //Last Name textfield
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 25.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   'Last Name',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10),

                                Flexible(
                                  child: Mytextfield(
                                    controller: lastNameController,
                                    hintText: 'Last Name',
                                    obscureText: false,
                                    icon: Icons.person,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            //phone number textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //phone number textfield
                                  Text(
                                    'Phone Number',
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
                              controller: phoneController,
                              hintText: 'Enter your phone number',
                              obscureText: false,
                              icon: Icons.phone,
                            ),

                            SizedBox(height: 10),

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

                            Mytextfield(
                              controller: emailController,
                              hintText: ' Enter your email',
                              obscureText: false,
                              icon: Icons.email,
                            ),

                            SizedBox(height: 10),

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
                              hintText: 'Create a  strong password',
                              obscureText: true,
                              icon: Icons.lock,
                            ),

                            //terms and serves text
                            // Padding(
                            //   padding: EdgeInsets.all(5.0),
                            //   child: Text(
                            //     'I agree to the Terms of Service and Privacy Policy',
                            //     style: TextStyle(
                            //       color: Colors.grey[700],
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20),

                            //sign in button (firebase auth)
                            Btn(onTap: createAccount, text: 'Create Account'),

                            SizedBox(height: 10),
                            
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

                            // Already have an account? Sign In textbutton
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
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
      ),
    );
  }
}
