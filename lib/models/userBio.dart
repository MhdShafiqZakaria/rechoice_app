import 'package:rechoice_app/models/users.dart';

class UserBio {
  final List<Users> userData = [
    Users(
      userID: 1,
      name: 'John Doe',
      email: 'test123@gmail.com',
      password: 'test123',
      profilePic: 'assets/images/google.png',
      bio: 'bio',
      reputationScore: 10.00,
    ),
  ];
}
