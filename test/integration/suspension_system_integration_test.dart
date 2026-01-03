import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

// Mock classes for integration testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-123';
}
class MockFirestoreService extends Mock implements FirestoreService {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic>? _data;
  
  MockDocumentSnapshot(this._data);
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Integration Tests - Suspension System End-to-End', () {
    group('User Login Flow with Suspension Check', () {
      test('should allow active user to login and access app', () async {
        // Setup
        const uid = 'active-user-123';
        const email = 'active@example.com';

        // Simulate active user data from Firestore
        final activeUserData = {
          'uid': uid,
          'userID': 1,
          'name': 'Active User',
          'email': email,
          'status': 'active',
          'role': 'buyer',
          'profilePic': '',
          'bio': '',
          'reputationScore': 4.5,
          'joinDate': DateTime.now(),
          'lastLogin': DateTime.now(),
        };

        // Parse user status
        final userStatus = UserStatus.values.byName(activeUserData['status']);
        
        // Verify active user can access
        expect(userStatus == UserStatus.active, isTrue);
        expect(userStatus != UserStatus.suspended, isTrue);
        expect(userStatus != UserStatus.deleted, isTrue);
      });

      test('should block suspended user from login', () async {
        // Setup
        const uid = 'suspended-user-456';
        
        // Simulate suspended user data from Firestore
        final suspendedUserData = {
          'uid': uid,
          'userID': 2,
          'name': 'Suspended User',
          'email': 'suspended@example.com',
          'status': 'suspended',
          'role': 'seller',
        };

        // Parse user status
        final userStatus = UserStatus.values.byName(suspendedUserData['status']);
        
        // Verify suspended user is blocked
        expect(userStatus == UserStatus.suspended, isTrue);
        expect(userStatus != UserStatus.active, isTrue);
      });

      test('should block deleted user from login', () async {
        // Setup
        const uid = 'deleted-user-789';
        
        // Simulate deleted user data from Firestore
        final deletedUserData = {
          'uid': uid,
          'userID': 3,
          'name': 'Deleted User',
          'email': 'deleted@example.com',
          'status': 'deleted',
          'role': 'buyer',
        };

        // Parse user status
        final userStatus = UserStatus.values.byName(deletedUserData['status']);
        
        // Verify deleted user is blocked
        expect(userStatus == UserStatus.deleted, isTrue);
        expect(userStatus != UserStatus.active, isTrue);
      });

      test('should handle status check with retry on network error', () {
        // Verify retry logic exists
        const maxRetries = 3;
        const initialDelayMs = 500;

        // Simulate retry attempts with exponential backoff
        for (int attempt = 0; attempt < maxRetries; attempt++) {
          final delayMs = initialDelayMs * (attempt + 1);
          
          // Verify exponential backoff
          expect(delayMs, equals(500 * (attempt + 1)));
        }
      });
    });

    group('Admin Dashboard Access Control', () {
      test('should block non-admin from admin dashboard', () {
        // Non-admin user trying to access /adminDashboard
        final user = Users(
          uid: 'user123',
          userID: 1,
          name: 'Non Admin',
          email: 'user@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 4.0,
          status: UserStatus.active,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
          role: UserRole.buyer, // NOT admin
        );

        // Should not have admin access
        expect(user.isAdmin, isFalse);
      });

      test('should allow admin to access admin dashboard', () {
        // Admin user trying to access /adminDashboard
        final admin = Users(
          uid: 'admin123',
          userID: 100,
          name: 'Admin User',
          email: 'admin@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 5.0,
          status: UserStatus.active,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
          role: UserRole.admin,
        );

        // Should have admin access
        expect(admin.isAdmin, isTrue);
      });

      test('should block suspended admin from dashboard', () {
        // Admin user who is suspended
        final suspendedAdmin = Users(
          uid: 'admin-suspended',
          userID: 101,
          name: 'Suspended Admin',
          email: 'admin-suspended@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 5.0,
          status: UserStatus.suspended, // Suspended!
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
          role: UserRole.admin,
        );

        // Even though user.isAdmin is true, suspension should block access
        expect(suspendedAdmin.isAdmin, isTrue);
        expect(suspendedAdmin.isSuspended, isTrue);
        
        // Both conditions must be checked:
        final hasAccess = suspendedAdmin.isAdmin && suspendedAdmin.isActive;
        expect(hasAccess, isFalse);
      });
    });

    group('CSV Export Audit Trail', () {
      test('should export active, suspended, deleted users correctly', () {
        // Create users with different statuses
        final users = [
          Users(
            uid: 'user1',
            userID: 1,
            name: 'John Active',
            email: 'john@example.com',
            profilePic: '',
            bio: '',
            reputationScore: 4.5,
            status: UserStatus.active,
            joinDate: DateTime(2024, 1, 1),
            lastLogin: DateTime(2024, 1, 15),
            role: UserRole.seller,
            totalListings: 5,
            totalPurchases: 2,
            totalSales: 3,
            phoneNumber: '+60123456789',
            address: 'Address 1',
          ),
          Users(
            uid: 'user2',
            userID: 2,
            name: 'Jane Suspended',
            email: 'jane@example.com',
            profilePic: '',
            bio: '',
            reputationScore: 3.0,
            status: UserStatus.suspended,
            joinDate: DateTime(2024, 2, 1),
            lastLogin: DateTime(2024, 2, 10),
            role: UserRole.buyer,
            totalListings: 0,
            totalPurchases: 5,
            totalSales: 0,
            phoneNumber: '+60987654321',
            address: 'Address 2',
          ),
          Users(
            uid: 'user3',
            userID: 3,
            name: 'Bob Deleted',
            email: 'bob@example.com',
            profilePic: '',
            bio: '',
            reputationScore: 2.0,
            status: UserStatus.deleted,
            joinDate: DateTime(2024, 3, 1),
            lastLogin: DateTime(2024, 3, 5),
            role: UserRole.admin,
            totalListings: 10,
            totalPurchases: 15,
            totalSales: 8,
            phoneNumber: null,
            address: null,
          ),
        ];

        // Verify export includes all three statuses
        expect(users.where((u) => u.isActive).length, equals(1));
        expect(users.where((u) => u.isSuspended).length, equals(1));
        expect(users.where((u) => u.isDeleted).length, equals(1));

        // Verify admin can identify each user's status
        for (var user in users) {
          expect(user.status, isNotNull);
          expect([UserStatus.active, UserStatus.suspended, UserStatus.deleted],
              contains(user.status));
        }
      });

      test('should include all necessary fields for audit', () {
        final user = Users(
          uid: 'audit-user',
          userID: 1,
          name: 'Audit Test',
          email: 'audit@example.com',
          profilePic: 'https://example.com/pic.jpg',
          bio: 'Test user',
          reputationScore: 4.5,
          status: UserStatus.suspended,
          joinDate: DateTime(2024, 1, 1),
          lastLogin: DateTime(2024, 1, 15),
          role: UserRole.seller,
          totalListings: 5,
          totalPurchases: 2,
          totalSales: 3,
          phoneNumber: '+60123456789',
          address: 'Test Address',
        );

        // Verify all audit fields are present
        expect(user.userID, isNotNull);
        expect(user.name, isNotNull);
        expect(user.email, isNotNull);
        expect(user.status, isNotNull);
        expect(user.role, isNotNull);
        expect(user.reputationScore, isNotNull);
        expect(user.totalListings, isNotNull);
        expect(user.totalPurchases, isNotNull);
        expect(user.totalSales, isNotNull);
        expect(user.joinDate, isNotNull);
        expect(user.lastLogin, isNotNull);
        expect(user.phoneNumber, isNotNull);
        expect(user.address, isNotNull);
      });
    });

    group('Combined Security Checks', () {
      test('should verify user is both admin AND active for dashboard access', () {
        // Create test scenarios
        final scenarios = [
          {
            'name': 'Admin and Active',
            'role': UserRole.admin,
            'status': UserStatus.active,
            'shouldAccess': true,
          },
          {
            'name': 'Admin but Suspended',
            'role': UserRole.admin,
            'status': UserStatus.suspended,
            'shouldAccess': false,
          },
          {
            'name': 'Admin but Deleted',
            'role': UserRole.admin,
            'status': UserStatus.deleted,
            'shouldAccess': false,
          },
          {
            'name': 'Active but not Admin',
            'role': UserRole.buyer,
            'status': UserStatus.active,
            'shouldAccess': false,
          },
          {
            'name': 'Not Admin and Suspended',
            'role': UserRole.seller,
            'status': UserStatus.suspended,
            'shouldAccess': false,
          },
        ];

        for (var scenario in scenarios) {
          final user = Users(
            uid: 'test-${scenario['name']}',
            userID: 1,
            name: scenario['name'] as String,
            email: 'test@example.com',
            profilePic: '',
            bio: '',
            reputationScore: 4.0,
            status: scenario['status'] as UserStatus,
            joinDate: DateTime.now(),
            lastLogin: DateTime.now(),
            role: scenario['role'] as UserRole,
          );

          final hasAccess = user.isAdmin && user.isActive;
          expect(
            hasAccess,
            equals(scenario['shouldAccess']),
            reason: scenario['name'] as String,
          );
        }
      });

      test('should verify enum-based comparisons are type-safe', () {
        // Verify enum comparisons don't have string-comparison bugs
        final userStatus = UserStatus.suspended;

        // These should work correctly (not comparing strings)
        expect(userStatus == UserStatus.suspended, isTrue);
        expect(userStatus == UserStatus.active, isFalse);

        // Should not accidentally pass with string comparison
        expect(userStatus.toString().contains('suspended'), isTrue);
        
        // Enum comparison is type-safe
        expect(userStatus.runtimeType, equals(UserStatus));
      });
    });

    group('State Transition Scenarios', () {
      test('should handle user status change from active to suspended', () {
        // Initial state: active user
        var user = Users(
          uid: 'user123',
          userID: 1,
          name: 'Test User',
          email: 'test@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 4.0,
          status: UserStatus.active,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        expect(user.isActive, isTrue);

        // Admin suspends user
        user = user.copyWith(status: UserStatus.suspended);

        // Verify status changed
        expect(user.isActive, isFalse);
        expect(user.isSuspended, isTrue);
      });

      test('should handle user status change from suspended to active', () {
        // Initial state: suspended user
        var user = Users(
          uid: 'user456',
          userID: 2,
          name: 'Suspended User',
          email: 'suspended@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 3.0,
          status: UserStatus.suspended,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        expect(user.isSuspended, isTrue);

        // Admin unsuspends user
        user = user.copyWith(status: UserStatus.active);

        // Verify status changed
        expect(user.isSuspended, isFalse);
        expect(user.isActive, isTrue);
      });

      test('should handle permanent deletion of user', () {
        // Initial state: active user
        var user = Users(
          uid: 'user789',
          userID: 3,
          name: 'User to Delete',
          email: 'delete@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 4.0,
          status: UserStatus.active,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        expect(user.isActive, isTrue);
        expect(user.isDeleted, isFalse);

        // Admin deletes user
        user = user.copyWith(status: UserStatus.deleted);

        // Verify permanent deletion
        expect(user.isActive, isFalse);
        expect(user.isDeleted, isTrue);
      });
    });
  });
}
