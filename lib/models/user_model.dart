import 'package:jm_senior/models/study_preferences_model.dart';

class UserModel{
  final String id;
  final String username;
  final String email;
  final StudyPreferences studyPreferences;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.studyPreferences
  });

   // Convert from Firestore document to User
  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] as String,
      email: data['email'] as String,
      studyPreferences: StudyPreferences.fromFirestore(data['studyPreferences'] as Map<String,dynamic>)
    );
  }

  // Convert User to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'studyPreferences': studyPreferences.toFirestore()
    };
  }

}
