import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  String errorMessage = '';

  //change Password Method
  void changePassword() async {
    try {
      await authService.value.resetPwFromCurrPw(
        currentPassword: passwordController.text,
        newPassword: newPasswordController.text,
        email: emailController.text,
      );
      showSnackBarSuccess();
    } catch (e) {
      showSnackBarFailure();
    }
  }

  //snackbar for success
  void showSnackBarSuccess() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Password changed successfully',
          style: TextStyle(color: Colors.black),
        ),
        showCloseIcon: true,
      ),
    );
  }

  //snackbar for failure
  void showSnackBarFailure() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Password changed failed',
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
                        'Change Your  Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Enter a new password below',
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

                          SizedBox(height: 10),

                          //current password textfield
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Password*',
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
                            controller: passwordController,
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
                              hintText: 'Enter Your Current Password',
                            ),
                          ),

                          SizedBox(height: 10),

                          //new password textfield
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter New Password',
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
                            controller: newPasswordController,
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
                              hintText: 'Confirm your password',
                            ),
                          ),

                          SizedBox(height: 20),

                          GestureDetector(
                            onTap: changePassword,
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
                                  'Reset Password',
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
