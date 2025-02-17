import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jm_senior/models/quiz_model.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'package:jm_senior/models/user_model.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  //USERS
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
  
  Future<UserModel?> fetchCurrentUser() async{
    final userDoc = await _db
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    final data = userDoc.data();
    if (data != null) {
      return UserModel.fromFirestore(currentUser!.uid, data);
    }
    return null;
  }

  //EXAMS
  Future<void> addExam({required Exam exam}) async {
    try {
      if (currentUser != null) {
        await _db.collection('exams')
                    .add(exam.toFirestore(currentUser!.uid));
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Exam>> getExamsStream() {
    if (currentUser == null) {
      return Stream.value([]); // Return an empty stream if no user is logged in.
    }

    return _db.collection('exams')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('date') 
          .snapshots()
            .map((snapshot) => snapshot.docs
              .map((doc) => Exam.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<List<Exam>> getExamsList() async {
    List<Exam> exams = [];
    final examsSnapshot = await _db.collection('exams')
                                        .where('userId', isEqualTo: currentUser!.uid).get();
    for(DocumentSnapshot doc in examsSnapshot.docs){
      Exam exam = Exam.fromFirestore(doc.id, doc.data() as Map<String,dynamic>);
      exams.add(exam);
    }
    return exams;
  }

  Future<void> updateExam({required Exam exam}) async{
    await _db.collection('exams')
        .doc(exam.id)
        .update(exam.toFirestore(currentUser!.uid));
  }

  Future<void> deleteAllExamSchedules(String documentID) async{
    // Get all schedules
    final QuerySnapshot<Map<String, dynamic>> schedulesSnapshot =
        await _db.collection('studySchedules')
            .where('examId', isEqualTo: documentID)
            .get();

    // Delete each schedule document
    for (var doc in schedulesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteExam(String documentID) async {
    await _db.collection('exams').doc(documentID).delete();
    await deleteAllExamSchedules(documentID);
  }

    
  //SCHEDULES
  Future<void> addstudySchedule(StudySchedule studySchedule) async {
    await _db.collection('studySchedules').doc(studySchedule.id)
        .set(studySchedule.toFirestore(currentUser!.uid));
  }

  Future<void> addStudySchedules(List<StudySchedule> studySchedules) async {
  WriteBatch batch = _db.batch();

  for (var studySchedule in studySchedules) {
    DocumentReference docRef = _db.collection('studySchedules')
                              .doc(studySchedule.id);

    batch.set(docRef, studySchedule.toFirestore(currentUser!.uid));
  }

  await batch.commit();
}

  Future<void> updatestudySchedule(StudySchedule studySchedule) async {
    await _db.collection('studySchedules')
        .doc(studySchedule.id)
        .update(studySchedule.toFirestore(currentUser!.uid));
  }

  Future<void> deletestudySchedule(String id) async {
    await _db.collection('studySchedules')
        .doc(id).delete();
  }

  Stream<List<StudySchedule>> getSchedulesStream() {
    return _db.collection('studySchedules')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) => StudySchedule.fromFirestore(doc.id, doc.data()))
          .toList());
  }
  
  Future<List<StudySchedule>> getSchedulesList() async{
    List<StudySchedule> schedules = [];
    final schedulesSnapshot = await _db.collection('studySchedules')
                                        .where('userId', isEqualTo: currentUser!.uid).get();
    for(DocumentSnapshot doc in schedulesSnapshot.docs){
      StudySchedule schedule = StudySchedule.fromFirestore(doc.id, doc.data() as Map<String,dynamic>);
      schedules.add(schedule);
    }
    return schedules;
  }

  //USER SETTINGS
  Future<void> savePreferences(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('studySessionDuration', user.studySessionDuration);
    await prefs.setInt('breakDuration', user.breakDuration);
    await prefs.setString('studyStartTime', user.studyStartTime);
    await prefs.setString('studyEndTime', user.studyEndTime);
    await _db.collection('users').doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  //QUIZZES
  Future<void> saveQuiz(Quiz quiz) async {
    try {
      if (currentUser != null) {
        await _db.collection('quizzes')
                    .add(quiz.toFirestore(currentUser!.uid));
      }
    } catch (e) {
      rethrow;
    }
  }

  //QUIZ RESULTS DATA
  Future<List<Map<String, dynamic>>> getQuizResultsData(
    List<String> topics) async {
  List<Map<String, dynamic>> results = [];

  for (String topic in topics) {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('quizzes') 
          .where('userId', isEqualTo: currentUser!.uid)
          .where('topic', isEqualTo: topic)
          .orderBy('timestamp', descending: true) // Order by timestamp
          .limit(1) // Get only the latest
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract only the required fields
        results.add({
          'topic': data['topic'],
          'accuracy': data['accuracy']*0.01,
          'quiz_time_taken': data['timeTaken'],
        });
      }
    } catch (e) {
      rethrow;
    }
  }
  return results;
}
}





