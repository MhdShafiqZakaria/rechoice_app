import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rechoice_app/pages/admin/admin_dashboard.dart';
import 'package:rechoice_app/pages/admin/listing_moderation.dart';
import 'package:rechoice_app/pages/admin/report_analytics.dart';
import 'package:rechoice_app/pages/admin/user_management.dart';
import 'package:rechoice_app/pages/ai-features/chatbot.dart';
import 'package:rechoice_app/pages/auth/auth_gate.dart';
import 'package:rechoice_app/pages/auth/change_password.dart';
import 'package:rechoice_app/pages/auth/reset_password.dart';
import 'package:rechoice_app/pages/main-dashboard/catalog.dart';
import 'package:rechoice_app/pages/main-dashboard/dashboard.dart';
import 'package:rechoice_app/pages/main-dashboard/product.dart';
import 'package:rechoice_app/pages/main-dashboard/search_result.dart';
import 'package:rechoice_app/pages/payment/cart.dart';
import 'package:rechoice_app/pages/payment/payment.dart';
import 'package:rechoice_app/pages/users/add_new_products.dart';
import 'package:rechoice_app/pages/users/add_products.dart';
import 'package:rechoice_app/pages/users/user_profile_info.dart';
import 'package:rechoice_app/pages/users/user_reviews.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReChoice',
      debugShowCheckedModeBanner: false,
      //start the app from authGate page
      initialRoute: '/',

      //routes for navigation between pages
      routes: {
        '/': (context) => const AuthGate(),
        '/resetPW': (context) => const ResetPassword(),
        '/changePW': (context) => const ChangePassword(),
        '/dashboard': (context) => const Dashboard(),
        '/catalog': (context) => const CatalogsPage(),
        '/search': (context) => const SearchResultScreen(),
        '/product': (context) => const Product(),
        '/cart': (context) => const CartPage(),
        '/payment': (context) => const PaymentPage(),
        '/profile': (context) => const UserProfilePage(),
        '/addProd': (context) => const MyProductsPage(),
        '/addNewProd': (context) => const AddProductPage(),
        '/review': (context) => const UserReviewsPage(),
        '/adminDashboard': (context) => const AdminDashboardPage(),
        '/listingMod': (context) => const ListingModerationPage(),
        '/report': (context) => const ReportAnalyticsPage(),
        '/manageUser': (context) => const UserManagementPage(),
        '/chatbot': (context) => const Chatbot(),
      },
    );
  }
}
