import 'package:cloud_firestore/cloud_firestore.dart';

class StudySchedule {
  String? id;
  String? userId;
  String examId;
  DateTime startTime;
  DateTime endTime;
  String topic;


  StudySchedule({
    this.id,
    this.userId,
    required this.examId,
    required this.startTime,
    required this.endTime,
    required this.topic,
  });

  // Convert from Firebase document to StudySchedule
  factory StudySchedule.fromFirestore(String documentId, Map<String, dynamic> data,) {
    return StudySchedule(
      id: documentId,
      userId: data['userId'] as String,
      examId: data['examId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      topic: data['topic'] as String
    );
  }

  // Convert from StudySchedule to Firebase document
  Map<String, dynamic> toFirestore(uid) {
    return {
      'examId': examId,
      'userId': uid,
      'startTime': startTime,
      'endTime': endTime,
      'topic': topic
    };
  }
}
