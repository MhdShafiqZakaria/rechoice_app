class Users {
  final int userID;
  final String name;
  final String email;
  final String password;
  final String profilePic;
  final String bio;
  final double reputationScore;

  Users({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.profilePic,
    required this.bio,
    required this.reputationScore,
  });
//Factory Method to create model instance from Json map

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userID: json['userID'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      profilePic: json['profilePic'] as String,
      bio: json['bio'] as String,
      reputationScore: (json['reputationScore'] as num).toDouble(),
    );
  }  
  
  //Factory Method to convert model to Json structure for data storage in firebase

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'password': password,
      'profilePic': profilePic,
      'bio': bio,
      'reputationScore': reputationScore,
    };
  }
}


