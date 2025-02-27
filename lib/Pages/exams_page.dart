import 'package:flutter/material.dart';
import 'package:jm_senior/Pages/schedules_page.dart';
import 'package:jm_senior/components/exam_form.dart';
import 'package:jm_senior/components/delete_confirmation_dialog.dart';
import 'package:jm_senior/components/missing_topics_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exams', style: TextStyle(fontWeight: FontWeight.bold),),
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
              
              return Dismissible(
                key: Key(exam.id!),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  color: Colors.grey,
                  child: const Icon(Icons.edit, color: Colors.white, size: 40,),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white, size: 40),
                ),
                confirmDismiss: (direction) async {
                  if(direction == DismissDirection.endToStart){
                    return await showDialog<bool>(
                      context: context, 
                      builder: (context) => DeleteConfirmationDialog(
                        title: 'Delete Exam', 
                        message: 'Are you sure you want to delete this exam? This will also delete all related schedules.',
                        onConfirm: () => Navigator.of(context).pop(true),
                        onCancel: () => Navigator.of(context).pop(false),
                      ),
                    ) ?? false;
                  } else {
                    _showExamForm(context, exam);
                    return false; //In order not to remove the item from the ui on edit.
                  }
                },
                onDismissed: (direction) async{
                  if(direction == DismissDirection.endToStart){
                   await FirestoreService().deleteExam(exam.id!);
                  }
                },
                child: GestureDetector(
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
                            subtitle: Text(DateFormat('EEEE MMMM d \'at\' HH:mm').format(exam.date)),
                          ),
                          const SizedBox(height: 5,),
                          Wrap(
                            spacing: 5.0,
                            children: exam.topics.map((topic) => Chip(label: Text(topic))).toList(),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  final quizResults = await FirestoreService().getQuizResultsData(exam.topics);
                                  if(quizResults.isEmpty){
                                    showDialog(
                                      context: context, 
                                      builder: (context) => MissingTopicsDialog(missingTopics: exam.topics)
                                    );
                                  }else if( quizResults.length < exam.topics.length){
                                    // 1. Identify missing topics
                                    List<String> foundTopics = quizResults.map((result) => result['topic'] as String).toList();
                                    List<String> missingTopics = exam.topics.where((topic) => !foundTopics.contains(topic)).toList();
                
                                    // 2. Generate the schedule (with available data)
                                    await GenerateSchedule().generateSchedule(exam, quizResults, context);
                
                                    // 3. Show dialog with missing topics
                                    showDialog(
                                      context: context,
                                      builder: (context) => MissingTopicsDialog(missingTopics: missingTopics)
                                    );
                                  }
                                  else{
                                    GenerateSchedule().generateSchedule(exam, quizResults, context);
                                  }
                                },
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: exam.hasSchedule ? const Text("Update Schedule") :const Text("Generate Study Schedule"),
                              ),
                          ),
                        ],
                      ),
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
