import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/auth/btn_google_sign_in.dart';
import 'package:rechoice_app/components/auth/btn_sign_in.dart';
import 'package:rechoice_app/components/auth/my_text_field.dart';
import 'package:rechoice_app/models/viewmodels/auth_view_model.dart';

class Register extends StatefulWidget {
  final VoidCallback? onPressed;

  const Register({super.key, this.onPressed});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //sign user in method
  void _createAccount(BuildContext context) async {
    // validate inputs
    if (nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Name cannot be empty')));
      }

      return;
    }

    final authVM = context.read<AuthViewModel>();
    try {
      await authVM.register(
        name: nameController.text.trim(),
        email: emailController.text,
        password: passwordController.text.trim(),
      );

      if (authVM.errorMessage == null) {}
    } catch (error) {
      // Handle errors (e.g., registration failed)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account creation failed: ${error.toString()}')),
      );
    }
  }



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
                      child: Consumer<AuthViewModel>(
                        builder: (context, authVM, child) {
                          return Column(
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

                              //sign in button (firebase auth) or show loading screen
                              authVM.isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Btn(
                                      onTap: () => _createAccount(context),
                                      text: 'Create Account',
                                    ),

                              SizedBox(height: 10),

                              //error message
                              if (authVM.errorMessage != null)
                                Text(
                                  authVM.errorMessage!,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
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
                              SizedBox(height: 20),
                            ],
                          );
                        },
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
