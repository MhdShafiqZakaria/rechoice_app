import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/auth/btn_sign_in.dart';
import 'package:rechoice_app/components/auth/my_text_field.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/pages/admin/admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _adminSignIn() async {
    if (_isLoading) return;

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final userCredential = await authService.value.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Authentication failed');
      }

      //Check if user is admin in Firestore
      final isAdmin = await _firestoreService.isAdmin(uid);
      print('🔵 Is admin: $isAdmin');

      if (!isAdmin) {
        // Not an admin - sign them out
        await authService.value.logout();

        setState(() {
          _errorMessage = 'Access denied. Admin credentials required.';
          _isLoading = false;
        });
        return;
      }

      await _firestoreService.updateLastLogin(uid);

      // Step 4: Navigate to admin dashboard
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return const AdminDashboardPage();
            },
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print(' Firebase Auth Error: ${e.code}');

      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No account found with this email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email format.';
            break;
          case 'user-disabled':
            _errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many attempts. Try again later.';
            break;
          default:
            _errorMessage = e.message ?? 'Authentication failed.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _navigateToUserLogin() {
    Navigator.pushReplacementNamed(context, '/');
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
                  Colors.deepPurple[900]!,
                  Colors.deepPurple[700]!,
                  Colors.deepPurple[500]!,
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
                        // Rechoice logo
                        Image.asset(
                          'assets/images/logo.png',
                          height: 250,
                          width: 250,
                          color: Colors.white,
                        ),

                        SizedBox(height: 20),

                        // Admin Portal Text
                        Text(
                          'Welcome Administrator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Authorized personnel only',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // White container for textFields
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

                            // Admin email textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Email',
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
                              controller: _emailController,
                              hintText: 'Enter admin email',
                              obscureText: false,
                              icon: Icons.email,
                            ),

                            SizedBox(height: 20),

                            // Password textfield
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
                              controller: _passwordController,
                              hintText: 'Enter password',
                              obscureText: true,
                              icon: Icons.lock,
                            ),

                            SizedBox(height: 30),

                            // Sign in button
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.deepPurple,
                                    ),
                                  )
                                : Btn(
                                    onTap: _adminSignIn,
                                    text: 'Sign In as Admin',
                                  ),

                            SizedBox(height: 15),

                            // Error message
                            Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.redAccent),
                            ),

                            SizedBox(height: 20),

                            // Divider
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

                            // Back to user login
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Not an admin?',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),

                                  SizedBox(width: 3),

                                  TextButton(
                                    onPressed: _navigateToUserLogin,
                                    child: Text(
                                      'User Login',
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Security notice
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.deepPurple[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.deepPurple[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Admin access is restricted and monitored',
                                      style: TextStyle(
                                        color: Colors.deepPurple[700],
                                        fontSize: 12,
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
