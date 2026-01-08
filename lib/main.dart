import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/services/category_service.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/item_service.dart';
import 'package:rechoice_app/models/services/local_storage_service.dart';
import 'package:rechoice_app/models/viewmodels/auth_view_model.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';
import 'package:rechoice_app/models/viewmodels/category_view_model.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';
import 'package:rechoice_app/models/viewmodels/wishlist_view_model.dart';
import 'package:rechoice_app/pages/admin/admin_dashboard.dart';
import 'package:rechoice_app/pages/admin/listing_moderation.dart';
import 'package:rechoice_app/pages/admin/report_analytics.dart';
import 'package:rechoice_app/pages/admin/user_management.dart';
import 'package:rechoice_app/pages/ai-features/chatbot.dart';
import 'package:rechoice_app/pages/auth/auth_gate.dart';
import 'package:rechoice_app/pages/auth/loading_page.dart';
import 'package:rechoice_app/pages/auth/login_admin.dart';
import 'package:rechoice_app/pages/auth/login_page.dart';
import 'package:rechoice_app/pages/auth/register.dart';
import 'package:rechoice_app/pages/auth/reset_password.dart';
import 'package:rechoice_app/pages/main-dashboard/catalog.dart';
import 'package:rechoice_app/pages/main-dashboard/dashboard.dart';
import 'package:rechoice_app/pages/main-dashboard/in_app_chat.dart';
import 'package:rechoice_app/pages/main-dashboard/product.dart';
import 'package:rechoice_app/pages/main-dashboard/search_result.dart';
import 'package:rechoice_app/pages/main-dashboard/wishlist.dart';
import 'package:rechoice_app/pages/payment/cart.dart';
import 'package:rechoice_app/pages/payment/payment.dart';
import 'package:rechoice_app/pages/users/user_profile.dart';
import 'package:rechoice_app/pages/users/user_reviews.dart';
import 'package:rechoice_app/utils/navigation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Force logout in debug mode to ensure clean state on each dev run
  if (kDebugMode) {
    await FirebaseAuth.instance.signOut();
  }

  final loadStorageService = LocalStorageService();
  await loadStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService: authService.value),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              UsersViewModel(firestoreService: FirestoreService()),
        ),
        Provider.value(value: loadStorageService),
        ChangeNotifierProvider(
          create: (context) => ItemsViewModel(
            ItemService(FirestoreService(), LocalStorageService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(CategoryService(FirestoreService())),
        ),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProxyProvider<WishlistViewModel, CartViewModel>(
          create: (context) => CartViewModel(
            wishlistViewModel: Provider.of<WishlistViewModel>(
              context,
              listen: false,
            ),
          ),
          update: (context, wishlist, cart) => cart!,
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ReChoice',
      debugShowCheckedModeBanner: false,
      //start the app from authGate page
      initialRoute: '/',

      //routes for navigation between pages
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => LoginPage(),
        '/register': (context) => Register(),
        '/admin': (context) => const AdminLoginPage(),
        '/resetPW': (context) => const ResetPassword(),
        '/dashboard': (context) => const Dashboard(),
        '/catalog': (context) => const CatalogsPage(),
        '/search': (context) => SearchResult(searchResults: []),
        '/product': (context) => const Product(),
        '/cart': (context) => const CartPage(),
        '/payment': (context) => const PaymentPage(),
        '/wishlist': (context) => const WishlistPage(),
        '/profile2': (context) => const UserProfile(),
        '/review': (context) => const UserReviewsPage(),
        '/adminDashboard': (context) =>
            _AdminRouteGuard(child: const AdminDashboardPage()),
        '/listingMod': (context) =>
            _AdminRouteGuard(child: const ListingModerationPage()),
        '/report': (context) =>
            _AdminRouteGuard(child: const ReportAnalyticsPage()),
        '/manageUser': (context) =>
            _AdminRouteGuard(child: const UserManagementPage()),
        '/chatbot': (context) => const Chatbot(),
        '/inAppChat': (context) => const InAppChat(),
      },
    );
  }
}

class _AdminRouteGuard extends StatelessWidget {
  final Widget child;

  const _AdminRouteGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        }

        if (snapshot.data != true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied: Admin only'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const SizedBox();
        }

        return child;
      },
    );
  }

  Future<bool> _checkAdmin() async {
    final auth = AuthService();
    if (auth.currentUser == null) return false;
    try {
      return await auth.isAdmin();
    } catch (_) {
      return false;
    }
  }
}
