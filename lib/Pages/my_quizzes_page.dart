import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/components/delete_confirmation_dialog.dart';
import 'package:jm_senior/models/quiz_model.dart';
import 'package:jm_senior/services/firestore_service.dart';

class MyQuizzesPage extends StatefulWidget {
  const MyQuizzesPage({super.key});

  @override
  State<MyQuizzesPage> createState() => _MyQuizzesPageState();
}

class _MyQuizzesPageState extends State<MyQuizzesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<Quiz>>(
        stream: FirestoreService().getQuizzesStream(), 
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quizzes solved yet! Solve some at "Quiz Me" page.'));
          }

          List<Quiz> quizzes = snapshot.data!;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              Quiz quiz = quizzes[index];
              return Dismissible(
                key: Key(quiz.id!),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context, 
                    builder: (context) => DeleteConfirmationDialog(
                      title: 'Delete Quiz', 
                      message: 'Make sure you are deleting an old quiz since we use the new ones to generate your schedules!',
                      onConfirm: () => Navigator.of(context).pop(true),
                      onCancel: () => Navigator.of(context).pop(false),
                    ),
                  ) ?? false;
                },
                onDismissed: (direction) async => await FirestoreService().deleteQuiz(quiz.id!),
                child: QuizListItem(quiz: quiz)
              );
            },
          );
        }
      ),
    );
  }
}

class QuizListItem extends StatefulWidget {
  final Quiz quiz;
  const QuizListItem({super.key, required this.quiz});

  @override
  State<QuizListItem> createState() => _QuizListItemState();
}

class _QuizListItemState extends State<QuizListItem> {

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.quiz.topic!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Solved on ${DateFormat('d/M/yyyy \'at\' HH:mm').format(widget.quiz.timestamp!)}"),
              ],
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0, 
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Score"),
                          Text("${widget.quiz.score}%", style: const TextStyle(fontSize: 50),),
                          const Text("Time Taken"),
                          Text("${widget.quiz.timeTaken } ${widget.quiz.timeTaken == 1 ? "minute" : "minutes"}",
                            style: const TextStyle(fontSize: 25),
                          )
                        ],
                      ),
                    ),
                    const Text("Multiple Choice Questions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    ...widget.quiz.mcQuestions.map(_buildQuestion),
                    const Text("True or False Questions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    ...widget.quiz.tfQuestions.map(_buildQuestion),
                    const Text("Open Ended Questions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    ...widget.quiz.openEndedQuestions.map(_buildQuestion),
                    const Text("Fill in the Blank Questions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    ...widget.quiz.fillInTheBlankQuestions.map(_buildQuestion),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildQuestion(QuizQuestion question) {
    // Handle different question types
    if (question is MCQuestion) {
      return _buildMCQ(question);
    } else if (question is TFQuestion) {
      return _buildTFQ(question);
    } else if (question is OpenEndedQuestion) {
      return _buildOpenEndedQ(question);
    } else if (question is FillInTheBlankQuestion) {
      return _buildFillInTheBlankQ(question);
    }else {
      return const Text('Unknown question type');
    }
}

Widget _buildMCQ(MCQuestion question) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
      ...question.options.map((option) {
        bool isCorrect = option == question.correctAnswer;
        bool isSelected = option == question.userAnswer; 

        return ListTile(
          title: Text(
            option,
            style: TextStyle(
              color: isSelected
                  ? (isCorrect ? Colors.green : Colors.red) // User's answer
                  : (isCorrect ? Colors.green : null), // Correct answer (if not selected)
            ),
          ),
          leading: Icon(
            isSelected
                ? (isCorrect ? Icons.check_circle : Icons.cancel)
                : (isCorrect ? Icons.check_circle_outline : Icons.radio_button_unchecked),
            color: isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : (isCorrect ? Colors.green : null),
          ),
        );
      }),
      const SizedBox(height: 8),
    ],
  );
}

Widget _buildTFQ(TFQuestion question) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          _buildTFOption(true, question),
          const SizedBox(width: 16),
          _buildTFOption(false, question),
        ],
      ),
      const SizedBox(height: 8),
    ],
  );
}

Widget _buildTFOption(bool optionValue, TFQuestion question) {
  bool isCorrect = optionValue == question.correctAnswer;
  bool isSelected = optionValue == question.userAnswer; // Always true for one of the options

  return Row(
    children: [
      Icon(
        isSelected
            ? (isCorrect ? Icons.check_circle : Icons.cancel)
            : (isCorrect ? Icons.check_circle_outline : Icons.check_box_outline_blank),
        color: isSelected
            ? (isCorrect ? Colors.green : Colors.red)
            : (isCorrect ? Colors.green : null),
      ),
      Text(
        optionValue ? "True" : "False",
        style: TextStyle(
          color: isSelected
              ? (isCorrect ? Colors.green : Colors.red)
              : (isCorrect ? Colors.green : null),
        ),
      ),
    ],
  );
}

  Widget _buildOpenEndedQ(OpenEndedQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Correct Answer: ${question.correctAnswer}"),
        Text("Your Answer: ${question.userAnswer}",),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFillInTheBlankQ(FillInTheBlankQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Correct Answer: ${question.correctAnswer}"),
        Text("Your Answer: ${question.userAnswer}"),
        const SizedBox(height: 8),
      ],
    );
  }