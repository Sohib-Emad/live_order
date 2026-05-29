class AuthModel {
  final String email;
  final String password;
  final String uid;

  AuthModel({required this.email, required this.password, required this.uid});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'uid': uid,
    };
  }


}
