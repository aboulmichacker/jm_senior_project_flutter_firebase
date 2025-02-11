import 'package:flutter/material.dart';
import 'package:jm_senior/Pages/schedules_page.dart';
import 'package:jm_senior/components/exam_form.dart';
import 'package:jm_senior/components/delete_confirmation_dialog.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:jm_senior/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/services/generate_schedule.dart';
class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  Future<void> _showExamForm(BuildContext context, Exam? exam) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        if(exam != null){
          return  ExamForm(exam: exam,);
        }else{
          return const ExamForm();
        }
      },
    );
  }

  Future<void> _deleteExam(String examID) async {
    showDialog(
      context: context, 
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Exam', 
        message: 'Are you sure you want to delete this exam? This will also delete all related schedules.', 
        onConfirm: () async{
          await FirestoreService().deleteExam(examID);
        }
      ));
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exams'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExamForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Exam>>(
        stream: FirestoreService().getExamsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming exams.'));
          }

          List<Exam> exams = snapshot.data!;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              Exam exam = exams[index];
              
              return GestureDetector(
                onTap:(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Schedule(exam: exam,)));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            exam.subject,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Text(DateFormat('EEEE MMMM d \'at\' h:mm a').format(exam.date)),
                        ),
                        const SizedBox(height: 5,),
                        GestureDetector(
                          child: Wrap(
                            spacing: 5.0,
                            children: exam.topics.map((topic) => Chip(label: Text(topic))).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _deleteExam(exam.id!), 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white
                              ),
                              child: const Text("Delete Exam")
                            ),
                            ElevatedButton(
                              onPressed: () => _showExamForm(context, exam),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white
                              ),
                              child: const Text("Edit Exam")
                            ),
                          ],
                        ),
                        Center(
                          child: ElevatedButton.icon(
                              onPressed: () {
                                GenerateSchedule().generateSchedule(exam, context);
                              },
                              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white,),
                              label: exam.hasSchedule ? const Text("Update Schedule") :const Text("Generate Study Schedule"),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
