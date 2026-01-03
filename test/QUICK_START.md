# Quick Start Guide - Running Tests

## 📋 Quick Commands

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
# Account suspension system tests
flutter test test/services/authenticate_suspension_test.dart

# CSV export tests
flutter test test/utils/export_utils_test.dart

# Admin route guard tests
flutter test test/widgets/admin_route_guard_test.dart

# Integration tests
flutter test test/integration/suspension_system_integration_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📊 Test Files Overview

| File | Tests | Feature | Critical? |
|------|-------|---------|-----------|
| `authenticate_suspension_test.dart` | 20+ | Account suspension & login | ✅ YES |
| `export_utils_test.dart` | 20+ | CSV export & data integrity | ✅ YES |
| `admin_route_guard_test.dart` | 25+ | Route protection & authorization | ✅ YES |
| `suspension_system_integration_test.dart` | 30+ | End-to-end flows | ✅ YES |
| **TOTAL** | **100+** | All critical features | **✅ YES** |

---

## 🔒 Security Features Tested

### ✅ Account Suspension System
- Suspended users blocked from login
- Deleted users blocked from login
- Network errors handled with retries
- Type-safe enum comparisons

### ✅ CSV Export Functionality
- All 13 columns present
- Data correctly formatted
- Suspended/deleted users identifiable
- Audit trail complete

### ✅ Admin Route Guard
- 4 admin routes protected
- Non-admin users blocked
- Unauthenticated users redirected
- Firestore status verified

---

## 📚 Documentation Files

### In `test/` directory:
1. **TEST_COVERAGE.md** - Overview of all tests and what they verify
2. **TEST_EXAMPLES.md** - Detailed code examples showing before/after
3. **TEST_STRUCTURE.md** - File organization and structure details
4. **TEST_STRUCTURE.md** - This file

### In root directory:
- **TEST_IMPLEMENTATION_SUMMARY.md** - High-level summary of implementation

---

## 🎯 What Each Test File Verifies

### authenticate_suspension_test.dart
**Tests the login and suspension system**

Key test groups:
- ✅ `canAccessApp()` - Checks if user can access app
- ✅ `_parseUserStatus()` - Verifies enum parsing
- ✅ `Status Check with Retry` - Tests retry logic with exponential backoff
- ✅ `UserStatus Enum` - Verifies enum properties
- ✅ `Users Model - Helper Methods` - Tests isActive, isSuspended, isDeleted
- ✅ `Users Model - Serialization` - Tests JSON conversion with status

### export_utils_test.dart
**Tests the CSV export functionality**

Key test groups:
- ✅ `CSV Header` - Verifies all 13 columns present
- ✅ `CSV Data Format` - Tests formatting (decimals, dates, nulls)
- ✅ `User Status in Export` - Verifies status exported correctly
- ✅ `User Role in Export` - Verifies role exported correctly
- ✅ `CSV Generation Logic` - Tests handling of multiple users
- ✅ `Data Integrity` - Ensures no data loss
- ✅ `File Path Generation` - Tests filename uniqueness
- ✅ `Error Handling` - Tests exception handling

### admin_route_guard_test.dart
**Tests the admin route protection**

Key test groups:
- ✅ `Route Access Control` - Verifies admin/non-admin access
- ✅ `Protected Routes` - Confirms all 4 routes protected
- ✅ `Redirect Behavior` - Tests redirects to login/dashboard
- ✅ `Guard State Management` - Tests _isChecking and _hasAccess
- ✅ `Error Handling` - Tests error recovery
- ✅ `Admin Status Verification` - Tests Firestore check
- ✅ `Security Properties` - Tests against attacks
- ✅ `User Experience` - Tests UI feedback
- ✅ `Stateful Widget Lifecycle` - Tests initialization

### suspension_system_integration_test.dart
**Tests end-to-end flows combining features**

Key test groups:
- ✅ `User Login Flow with Suspension Check` - Full login process
- ✅ `Admin Dashboard Access Control` - Admin-only access
- ✅ `CSV Export Audit Trail` - Export identifies all statuses
- ✅ `Combined Security Checks` - Both admin AND active required
- ✅ `State Transition Scenarios` - Status changes reflected

---

## 🚀 What's Tested

### Critical Security Scenarios
1. ✅ Suspended users cannot login
2. ✅ Deleted users cannot login
3. ✅ Network errors result in login denial (not allowance)
4. ✅ Non-admin users blocked from /adminDashboard
5. ✅ Non-admin users blocked from /listingMod
6. ✅ Non-admin users blocked from /report
7. ✅ Non-admin users blocked from /manageUser
8. ✅ Unauthenticated users redirected to login
9. ✅ Suspended admins cannot access admin routes
10. ✅ CSV export includes all user statuses

### Data Integrity
1. ✅ CSV has all 13 required columns
2. ✅ Reputation scores formatted to 2 decimals
3. ✅ Dates extracted without time component
4. ✅ Null values displayed as "N/A"
5. ✅ User order preserved in export
6. ✅ Sensitive data included for audit

### Type Safety
1. ✅ UserStatus enum used instead of strings
2. ✅ Enum parsing handles invalid values gracefully
3. ✅ Helper methods (isActive, isSuspended) work correctly
4. ✅ Serialization/deserialization maintains type safety

---

## 🔍 How to Interpret Test Results

### When All Tests Pass ✅
```
All 100+ tests pass → All critical features working correctly
```

### When Tests Fail ❌
Check which test group failed:
- **authenticate_suspension_test:** Login/suspension logic broken
- **export_utils_test:** CSV formatting or export broken
- **admin_route_guard_test:** Route protection not working
- **integration_test:** End-to-end flow has issues

### Coverage Report
```
Target > 80%:
  - authenticate.dart: 85%
  - export_utils.dart: 85%
  - main.dart (guard): 90%
  - users_model.dart: 95%
```

---

## 📝 Next Steps

### Immediate
1. Run all tests: `flutter test`
2. Check coverage: `flutter test --coverage`
3. Review TEST_EXAMPLES.md for detailed examples

### Before Deployment
1. Ensure all tests pass
2. Coverage above 80% for critical paths
3. Review failed tests if any

### In CI/CD Pipeline
1. Add test step to GitHub Actions/GitLab CI
2. Block merge on test failure
3. Fail on coverage below 80%

---

## 🛠️ Troubleshooting

### Tests won't run
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test
```

### Mock errors
```dart
// Make sure to use:
import 'package:mockito/mockito.dart';

// And annotate mocks:
class MockAuthService extends Mock implements AuthService {}
```

### Coverage not generating
```bash
# Install lcov (macOS)
brew install lcov

# Generate coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📞 Support

### Documentation
- **TEST_COVERAGE.md** - What tests exist
- **TEST_EXAMPLES.md** - How tests work with code examples
- **TEST_STRUCTURE.md** - File organization details

### Questions?
- Review the documentation files first
- Check TEST_EXAMPLES.md for specific feature examples
- Look at actual test code in test/ directory

---

**✅ Ready to test! Run:** `flutter test`
