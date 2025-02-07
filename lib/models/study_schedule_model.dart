import 'package:cloud_firestore/cloud_firestore.dart';

class StudySchedule {
  String? id;
  String examId;
  DateTime startTime;
  DateTime endTime;
  String subject;
  String topic;


  StudySchedule({
    this.id,
    required this.examId,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.topic,
  });

  // Convert from Firebase document to StudySchedule
  factory StudySchedule.fromFirestore(String documentId, Map<String, dynamic> data,) {
    return StudySchedule(
      id: documentId,
      examId: data['examId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      subject: data['subject'] as String,
      topic: data['topic'] as String
    );
  }

  // Convert from StudySchedule to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'examId': examId,
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'topic': topic
    };
  }
}
