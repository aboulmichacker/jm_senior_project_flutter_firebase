class UserModel{
  final String? id;
  final String username;
  final String email;

  UserModel({this.id ,required this.username, required this.email});

   // Convert from Firestore document to User
  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] as String,
      email: data['email'] as String,
    );
  }

  // Convert User to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
    };
  }

}
