import 'package:flutter/material.dart';
import 'package:jm_senior/models/quiz_model.dart';

class ExistingQuizzesPage extends StatelessWidget {
  final List<Quiz> quizzes;
  final String selectedTopic;
  final Function(Quiz) onQuizSelected;
  const ExistingQuizzesPage({
    super.key,
    required this.quizzes,
    required this.selectedTopic,
    required this.onQuizSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$selectedTopic Quizzes'),
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          Quiz currentQuiz = quizzes[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text("Preview:", style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MCQ First Question: ${currentQuiz.mcQuestions[0].questionText}"),
                      const SizedBox(height: 5,),
                      Text("TF First Question: ${currentQuiz.tfQuestions[0].questionText}"),
                      const SizedBox(height: 5,),
                      Text("Open Ended First Question: ${currentQuiz.openEndedQuestions[0].questionText}"),
                      const SizedBox(height: 5,),
                      Text("Fill in the Blank First Question: ${currentQuiz.fillInTheBlankQuestions[0].questionText}"),
                      const SizedBox(height: 20,),
                      Center(
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context, currentQuiz);
                            onQuizSelected(currentQuiz); 
                          }, 
                          child: const Text("Solve full quiz")
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}