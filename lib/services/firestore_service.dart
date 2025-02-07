import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'package:jm_senior/models/user_model.dart';
import 'package:jm_senior/models/exam_model.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> addUser({
    required String userId, 
    required String username,
    required String email,
    }) async {
    await _db.collection('users').doc(userId).set({
      'username': username,
      'email': email
    });
  }
  
  Future<UserModel?> fetchUser(String uid) async{
    final userDoc = await _db
        .collection('users')
        .doc(uid)
        .get();
    final data = userDoc.data();
    if (data != null) {
      return UserModel.fromFirestore(uid, data);
    }
    return null;
  }

    Future<DocumentReference?> addExam({required Exam exam}) async {
    try {
      if (currentUser != null) {
        return await _db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('exams')
            .add(exam.toFirestore());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Exam>> getExams() {
    if (currentUser == null) {
      return Stream.value([]); // Return an empty stream if no user is logged in.
    }

    return _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('exams')
        .orderBy('date') 
        .snapshots()
          .map((snapshot) => snapshot.docs
            .map((doc) => Exam.fromFirestore(doc.id, doc.data()))
          .toList());
  }

  Future<void> deleteExam(String documentID) async {
    await _db.collection('users')
        .doc(currentUser!.uid)
        .collection('exams').doc(documentID).delete();
        // Get all schedules
    final QuerySnapshot<Map<String, dynamic>> schedulesSnapshot =
        await _db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('studySchedules')
            .where('examId', isEqualTo: documentID)
            .get();

    // Delete each schedule document
    for (var doc in schedulesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

    

  Future<void> addstudySchedule(StudySchedule studySchedule) async {
    await _db.collection('users')
        .doc(currentUser!.uid)
        .collection('studySchedules').doc(studySchedule.id)
        .set(studySchedule.toFirestore());
  }

  Future<void> addStudySchedules(List<StudySchedule> studySchedules) async {
  WriteBatch batch = _db.batch();

  for (var studySchedule in studySchedules) {
    DocumentReference docRef = _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('studySchedules')
        .doc(studySchedule.id);

    batch.set(docRef, studySchedule.toFirestore());
  }

  await batch.commit();
}

  Future<void> updatestudySchedule(StudySchedule studySchedule) async {
    await _db.collection('users')
        .doc(currentUser!.uid)
        .collection('studySchedules')
        .doc(studySchedule.id)
        .update(studySchedule.toFirestore());
  }

  Future<void> deletestudySchedule(String id) async {
    await _db.collection('users')
        .doc(currentUser!.uid)
        .collection('studySchedules')
        .doc(id).delete();
  }

  Stream<List<StudySchedule>> getstudySchedules(String examId) {
    return _db.collection('users')
        .doc(currentUser!.uid)
        .collection('studySchedules')
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) => StudySchedule.fromFirestore(doc.id, doc.data()))
          .toList());
    }
  }



