import 'package:cloud_firestore/cloud_firestore.dart';
//A study schedule slot can also be used as a constraint called an event where a student has a specific
//time slot where he cannot study so that the scheduling algorithm will generate him a schedule based on these constraints.
//for reusability purposes examID can be nullable and the topic can be the event's name
class StudySchedule {
  String? id;
  String? userId;
  String? examId;
  DateTime startTime;
  DateTime endTime;
  String topic;


  StudySchedule({
    this.id,
    this.userId,
    this.examId,
    required this.startTime,
    required this.endTime,
    required this.topic,
  });

  // Convert from Firebase document to StudySchedule
  factory StudySchedule.fromFirestore(String documentId, Map<String, dynamic> data,) {
    return StudySchedule(
      id: documentId,
      userId: data['userId'] as String,
      examId: data['examId'] as String?,
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
