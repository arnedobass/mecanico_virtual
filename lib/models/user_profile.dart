class UserProfile {
  final String? firstName;
  final String? lastName;

  UserProfile({this.firstName, this.lastName});

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) =>
      UserProfile(firstName: j['firstName'], lastName: j['lastName']);
}
