class UserModel{
  final String id;
  final String username;
  final String email;
  int studySessionDuration;
  int breakDuration;
  String studyStartTime;
  String studyEndTime;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.studySessionDuration = 45,
    this.breakDuration = 15,
    this.studyStartTime = '15:00',
    this.studyEndTime = '23:00'
  });

   // Convert from Firestore document to User
  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] as String,
      email: data['email'] as String,
      studySessionDuration: data['studySessionDuration'] ?? 45,
      breakDuration: data['breakDuration'] ?? 15,
      studyStartTime: data['studyStartTime'] ?? '15:00',
      studyEndTime: data['studyEndTime'] ?? '23:00',
    );
  }

  // Convert User to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'studySessionDuration': studySessionDuration,
      'breakDuration': breakDuration,
      'studyStartTime': studyStartTime,
      'studyEndTime': studyEndTime,
    };
  }

}
