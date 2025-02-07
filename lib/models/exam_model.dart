import 'package:cloud_firestore/cloud_firestore.dart';
class Exam {
  final String? id;
  final String subject;
  final List<String> topics;
  final DateTime date;


  Exam({
    this.id,
    required this.subject,
    required this.date,
    required this.topics
  });

  // Convert from Firestore document to Exam
  factory Exam.fromFirestore(String id, Map<String, dynamic> data) {
    return Exam(
      id: id,
      subject: data['subject'] as String,
      date: (data['date'] as Timestamp).toDate(),
      topics: List<String>.from(data['topics'] as List<dynamic>)
    );
  }

  // Convert Exam to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'date': date,
      'topics': topics
    };
  }
}
