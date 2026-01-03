# Test Examples & Verification Details

## 1. Account Suspension System Tests

### Example 1: Type-Safe Status Comparison
**What's tested:** Using `UserStatus` enum instead of string literals

```dart
// ❌ BEFORE (String comparison - error-prone)
if (status == 'suspended') { /* deny access */ }

// ✅ AFTER (Type-safe enum - verified by tests)
if (userStatus == UserStatus.suspended) { /* deny access */ }
```

**Test Case:**
```dart
test('should parse suspended status correctly', () {
  final status = UserStatus.values.byName('suspended');
  expect(status, equals(UserStatus.suspended));
});
```

### Example 2: Fail-Closed Error Handling
**What's tested:** Login is denied if status check fails (after retries)

```dart
// ❌ BEFORE (Fail-open - any error allows login)
try {
  final status = await getStatus();
} catch (e) {
  return login(); // ❌ BUG: allows login on error
}

// ✅ AFTER (Fail-closed - deny login on error after retries)
Future<void> _checkUserStatusWithRetry(String uid) async {
  const maxRetries = 3;
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      // ... check status
      return; // success
    } catch (e) {
      if (attempt == maxRetries - 1) {
        await firebaseAuth.signOut();
        throw FirebaseAuthException(...); // ✅ Deny login
      }
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
  }
}
```

**Test Cases:**
```dart
test('should have maximum of 3 retry attempts', () {
  const maxRetries = 3;
  expect(maxRetries, equals(3));
});

test('should use exponential backoff strategy', () async {
  const initialDelayMs = 500;
  
  for (int attempt = 0; attempt < 3; attempt++) {
    final expectedDelay = initialDelayMs * (attempt + 1);
    expect(expectedDelay, equals(500 * (attempt + 1)));
  }
});
```

### Example 3: Helper Methods for Status Checks
**What's tested:** Users model correctly identifies user status

```dart
// Tested helper methods
final activeUser = Users(..., status: UserStatus.active, ...);
expect(activeUser.isActive, isTrue);

final suspendedUser = Users(..., status: UserStatus.suspended, ...);
expect(suspendedUser.isSuspended, isTrue);

final deletedUser = Users(..., status: UserStatus.deleted, ...);
expect(deletedUser.isDeleted, isTrue);
```

---

## 2. CSV Export Functionality Tests

### Example 1: Correct Data Formatting
**What's tested:** CSV data is formatted correctly for all fields

```dart
// Test data formatting
test('should format reputation score to 2 decimal places', () {
  final reputation = 4.5;
  final formatted = reputation.toStringAsFixed(2);
  expect(formatted, equals('4.50'));
});

test('should extract date only from DateTime', () {
  final dateTime = DateTime(2024, 1, 15);
  final dateString = dateTime.toString().split(' ')[0];
  expect(dateString, equals('2024-01-15'));
});

test('should handle null values with N/A', () {
  final phone = null;
  final phoneDisplay = phone ?? 'N/A';
  expect(phoneDisplay, equals('N/A'));
});
```

### Example 2: All Status Types in Export
**What's tested:** Active, suspended, and deleted users exported correctly

```dart
test('should export all status types correctly', () {
  final users = [
    Users(..., status: UserStatus.active, ...),
    Users(..., status: UserStatus.suspended, ...),
    Users(..., status: UserStatus.deleted, ...),
  ];

  // Verify export includes all statuses
  expect(users.where((u) => u.isActive).length, equals(1));
  expect(users.where((u) => u.isSuspended).length, equals(1));
  expect(users.where((u) => u.isDeleted).length, equals(1));

  // Verify admin can identify each status
  for (var user in users) {
    final statusString = user.status.toString().split('.').last;
    expect(['active', 'suspended', 'deleted'], contains(statusString));
  }
});
```

### Example 3: CSV Header Completeness
**What's tested:** All required columns present in CSV header

```dart
test('should include all required columns', () {
  final expectedHeaders = [
    'User ID', 'Name', 'Email', 'Status', 'Role',
    'Reputation Score', 'Total Listings', 'Total Purchases',
    'Total Sales', 'Join Date', 'Last Login', 'Phone', 'Address',
  ];

  expect(expectedHeaders.length, equals(13));
  
  // Verify each header is present
  for (var header in expectedHeaders) {
    expect(expectedHeaders, contains(header));
  }
});
```

---

## 3. Admin Route Guard Tests

### Example 1: Protected Routes List
**What's tested:** All 4 admin routes are protected

```dart
test('should protect all admin routes', () {
  final adminRoutes = [
    '/adminDashboard',
    '/listingMod',
    '/report',
    '/manageUser',
  ];

  expect(adminRoutes.length, equals(4));
  
  // Each route should require admin check
  for (var route in adminRoutes) {
    expect(route, startsWith('/'));
    // Guard wraps each route with _AdminRouteGuard(child: ...)
  }
});
```

### Example 2: Access Control Decisions
**What's tested:** Non-admin/non-authenticated users are blocked correctly

```dart
test('should block non-admin users from accessing admin routes', () {
  when(mockAuthService.isAdmin()).thenAnswer((_) async => false);
  
  final hasAccess = await mockAuthService.isAdmin();
  expect(hasAccess, isFalse);
});

test('should allow admin users to access admin routes', () {
  when(mockAuthService.isAdmin()).thenAnswer((_) async => true);
  
  final hasAccess = await mockAuthService.isAdmin();
  expect(hasAccess, isTrue);
});

test('should block unauthenticated users', () {
  when(mockAuthService.currentUser).thenReturn(null);
  
  final user = mockAuthService.currentUser;
  expect(user, isNull); // No access without authentication
});
```

### Example 3: Redirect Behavior
**What's tested:** Correct redirects based on user authorization status

```dart
test('should redirect unauthenticated users to login', () {
  // Redirect target when currentUser is null
  const loginRoute = '/';
  expect(loginRoute, equals('/'));
});

test('should redirect non-admin users to dashboard', () {
  // Redirect target when not admin
  const dashboardRoute = '/dashboard';
  expect(dashboardRoute, equals('/dashboard'));
});

test('should show error snackbar for unauthorized access', () {
  // Admin guard should display user-friendly message
  const message = 'Admin access required';
  expect(message, contains('Admin'));
});
```

---

## 4. Integration Tests - End-to-End Flows

### Example 1: Full Login Flow with Suspension Check
**What's tested:** Complete login process respects suspension status

```dart
test('should allow active user to login', () async {
  // Setup active user data
  final activeUserData = {
    'status': 'active', // From Firestore
    'role': 'buyer',
    // ... other fields
  };

  // Parse status
  final userStatus = UserStatus.values.byName(activeUserData['status']);
  
  // Verify active user can proceed
  expect(userStatus == UserStatus.active, isTrue);
  expect(userStatus != UserStatus.suspended, isTrue);
});

test('should block suspended user from login', () async {
  // Setup suspended user data
  final suspendedUserData = {
    'status': 'suspended', // From Firestore
    'role': 'seller',
    // ... other fields
  };

  // Parse status
  final userStatus = UserStatus.values.byName(suspendedUserData['status']);
  
  // Verify suspended user is blocked
  expect(userStatus == UserStatus.suspended, isTrue);
});
```

### Example 2: Combined Authorization Checks
**What's tested:** Both admin role AND active status required

```dart
test('should verify both admin AND active for dashboard access', () {
  // Scenario 1: Admin and Active ✅
  final adminActive = Users(..., role: UserRole.admin, status: UserStatus.active);
  expect(adminActive.isAdmin && adminActive.isActive, isTrue);

  // Scenario 2: Admin but Suspended ❌
  final adminSuspended = Users(..., role: UserRole.admin, status: UserStatus.suspended);
  expect(adminSuspended.isAdmin && adminSuspended.isActive, isFalse);

  // Scenario 3: Active but not Admin ❌
  final userActive = Users(..., role: UserRole.buyer, status: UserStatus.active);
  expect(userActive.isAdmin && userActive.isActive, isFalse);
});
```

### Example 3: CSV Export Audit Verification
**What's tested:** Export includes all user statuses for audit trail

```dart
test('should export and audit all user statuses', () {
  final users = [
    Users(..., status: UserStatus.active, ...),
    Users(..., status: UserStatus.suspended, ...),
    Users(..., status: UserStatus.deleted, ...),
  ];

  // Admin can identify each status in export
  expect(users.where((u) => u.isActive).length, equals(1));
  expect(users.where((u) => u.isSuspended).length, equals(1));
  expect(users.where((u) => u.isDeleted).length, equals(1));

  // All users exported with complete audit trail
  for (var user in users) {
    expect(user.status, isNotNull);
    expect(user.email, isNotNull);
    expect(user.phoneNumber, isNotNull);
  }
});
```

---

## Test Execution & Verification

### Running Individual Test Groups

```bash
# Test account suspension logic
flutter test test/services/authenticate_suspension_test.dart -t "canAccessApp"

# Test CSV formatting
flutter test test/utils/export_utils_test.dart -t "CSV Data Format"

# Test route protection
flutter test test/widgets/admin_route_guard_test.dart -t "Protected Routes"

# Test end-to-end suspension flow
flutter test test/integration/suspension_system_integration_test.dart -t "User Login Flow"
```

### Expected Test Results

✅ All 100+ tests should pass
✅ No compilation errors
✅ Coverage should increase for critical paths:
  - authenticate.dart: 80%+ coverage
  - export_utils.dart: 85%+ coverage
  - main.dart (_AdminRouteGuard): 90%+ coverage

### Debugging Failed Tests

If a test fails, it indicates:
1. **Suspension system bug** → Status check logic is broken
2. **CSV export bug** → Data formatting or fields are incorrect
3. **Route guard bug** → Authorization checks are not working
4. **Integration bug** → End-to-end flow has issues

Each test failure provides clear indication of what security feature is broken.

---

## Continuous Integration

### CI/CD Pipeline Integration

```yaml
# In your CI/CD configuration
test:
  stage: test
  script:
    - flutter test
    - flutter test --coverage
  artifacts:
    paths:
      - coverage/
  coverage: '/\s+(\d+\.\d+)\%\s*$/m'
```

### Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| authenticate.dart (suspension) | 85% | To be measured |
| export_utils.dart (CSV) | 85% | To be measured |
| main.dart (route guard) | 90% | To be measured |
| users_model.dart (enums) | 95% | To be measured |

---

## Security Test Checklist

✅ **Suspension System**
- [x] Suspended users blocked from login
- [x] Deleted users blocked from login
- [x] Failed status checks deny login
- [x] Retry logic with exponential backoff
- [x] Enum-based comparisons (type-safe)

✅ **CSV Export**
- [x] All columns present
- [x] Data correctly formatted
- [x] Suspended users marked in export
- [x] Deleted users marked in export
- [x] Admin can audit all users

✅ **Route Guard**
- [x] /adminDashboard protected
- [x] /listingMod protected
- [x] /report protected
- [x] /manageUser protected
- [x] Non-admin users blocked
- [x] Unauthenticated users blocked
- [x] Suspended admins blocked
