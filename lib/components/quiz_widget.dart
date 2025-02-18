import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jm_senior/assets/schemas.dart';
import 'package:jm_senior/models/quiz_model.dart';
import 'package:jm_senior/services/firestore_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class QuizWidget extends StatefulWidget {
   final Quiz quiz;
   final VoidCallback onReset;
   const QuizWidget({super.key, required this.quiz, required this.onReset});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  late String _selectedMcqOption = widget.quiz.mcQuestion.options[0];
  bool _selectedTrueOrFalseAnswer = true;
  final _fillInTheBlankAnswer = TextEditingController();
  final _openEndedAnswer = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? _quizScore;
  String? _openEndedSuggestion;
  String? _fillInTheBlankSuggestion;

    // Timer related variables
  int _secondsElapsed = 0;
  Timer? _timer;

  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the widget is created
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  int _getTimeTakenInMinutes() {
      int minutes = (_secondsElapsed / 60).ceil();
      return minutes > 0 ? minutes : 1;
  }

  Future<void> _correctQuiz(Quiz quiz) async{
    int accuracy = 0;
    if(quiz.mcQuestion.userAnswer == quiz.mcQuestion.correctAnswer){
      accuracy += 25;
    }
    if(quiz.tfQuestion.userAnswer == quiz.tfQuestion.correctAnswer){
      accuracy += 25;
    }
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final prompt = '''
      Correct the following quiz questions and return an accuracy score from 0 to 100.
      If answers are partially correct, add 10 to 25% to the total accuracy instead of removing all credit.
      If user answer has the same meaning as the correct answer give full credit. (Add the full 50% to the accuracy)
      "open ended question"{
        "questionText": ${quiz.openEndedQuestion.questionText},
        "correctAnswer": ${quiz.openEndedQuestion.correctAnswer},
        "userAnswer": ${quiz.openEndedQuestion.userAnswer}
      }
      "fill in the blank question"{
        "questionText": ${quiz.fillInTheBlankQuestion.questionText},
        "userAnswer": ${quiz.fillInTheBlankQuestion.userAnswer},
        "correctAnswer": ${quiz.fillInTheBlankQuestion.correctAnswer},
      }
    ''';

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey!,
      generationConfig: GenerationConfig(responseMimeType: 'application/json', responseSchema: Schemas().resultSchema)
    );

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if(response.text != null){
        Map<String,dynamic> jsonResponse = jsonDecode(response.text!);
        
        setState(() {
          _quizScore = accuracy + (jsonResponse["accuracy_score"]/2).toInt() as int;
          _openEndedSuggestion = jsonResponse["open_ended_suggestions"];
          _fillInTheBlankSuggestion = jsonResponse["fill_in_the_blank_suggestion"];
        });
      }else{
        throw Exception("Gemini API returned a null response");
      }

    } catch (e) {
      throw Exception('Error Correcting Quiz: ${e.toString()}'); 
    } 
  }

  Future<void>_submit() async{

    if(_formKey.currentState!.validate()){
      try{
        setState(() {
          _isLoading = true;
        });
        _timer?.cancel();
        Quiz submittedQuiz = widget.quiz;
        submittedQuiz.mcQuestion.userAnswer = _selectedMcqOption;
        submittedQuiz.tfQuestion.userAnswer = _selectedTrueOrFalseAnswer;
        submittedQuiz.fillInTheBlankQuestion.userAnswer = _fillInTheBlankAnswer.text;
        submittedQuiz.openEndedQuestion.userAnswer = _openEndedAnswer.text;

        await _correctQuiz(submittedQuiz);
        
        if(_quizScore != null){
          submittedQuiz.accuracy = _quizScore;
        }

        submittedQuiz.timeTaken = _getTimeTakenInMinutes();

        await FirestoreService().saveQuiz(submittedQuiz);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz Saved. You can view it in "My Quizzes" page.'))
        );
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });

      }catch(e){
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error Submitting Quiz: ${e.toString()}"),
          backgroundColor: Colors.red,)
        );
      }
    }
  }


    // --- Helper Method for MCQ Radio Buttons ---
  Widget _buildMcqOption(String option) {
    Color? tileColor;
    if (_isSubmitted) {
      if (option == widget.quiz.mcQuestion.correctAnswer) {
        tileColor = Colors.green[100]; // Light green for correct answer
      } else if (option == _selectedMcqOption &&
          option != widget.quiz.mcQuestion.correctAnswer) {
        tileColor = Colors.red[100]; // Light red for incorrect selection
      }
    }

    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: _selectedMcqOption,
      onChanged: _isSubmitted
          ? null
          : (value) {
              // Disable changes after submission
              setState(() {
                _selectedMcqOption = value!;
              });
            },
      tileColor: tileColor, // Apply the determined color
    );
  }

// --- Helper Method for True/False Radio Buttons ---
  Widget _buildTrueFalseOption(bool value) {
    Color? tileColor;
    if (_isSubmitted) {
      if (value == widget.quiz.tfQuestion.correctAnswer) {
        tileColor = Colors.green[100];
      } else if (value == _selectedTrueOrFalseAnswer &&
          value != widget.quiz.tfQuestion.correctAnswer) {
        tileColor = Colors.red[100];
      }
    }

    return RadioListTile<bool>(
      title: Text(value ? 'True' : 'False'),
      value: value,
      groupValue: _selectedTrueOrFalseAnswer,
      onChanged: _isSubmitted
          ? null
          : (value) {
              setState(() {
                _selectedTrueOrFalseAnswer = value!;
              });
            },
      tileColor: tileColor,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
            margin: const EdgeInsets.fromLTRB(12,20,12,12),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.quiz.mcQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
                ),
                const SizedBox(height: 12,),

                for (var option in widget.quiz.mcQuestion.options)
                _buildMcqOption(option),

                const SizedBox(height: 40,),
                Text(widget.quiz.openEndedQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
                ),
                const SizedBox(height: 12,),
                SizedBox( 
                  height: 100, 
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Your Answer',
                      border: OutlineInputBorder( 
                        borderSide: BorderSide(), 
                      ),
                    ),
                    controller: _openEndedAnswer,
                    maxLines: null, 
                    expands: true,  
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return  "Please answer the question";
                      }
                      return null;
                    },
                  ),
                ),
                if(_isSubmitted)
                ...[
                  const SizedBox(height: 20,),
                  Text(_openEndedSuggestion!, style: const TextStyle(fontSize: 15, color: Colors.green),)
                ],

                const SizedBox(height: 40,),
                Text(widget.quiz.tfQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
                ),

                const SizedBox(height: 12),
                _buildTrueFalseOption(true),
                _buildTrueFalseOption(false),

                const SizedBox(height: 40,),
                Text(widget.quiz.fillInTheBlankQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
                ),
                TextFormField( 
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(), 
                  ),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return  "Please answer the question";
                  }
                  return null;
                },
                controller: _fillInTheBlankAnswer,
              ),
              if(_isSubmitted)
              ...[
                const SizedBox(height: 20,),
                Text(_fillInTheBlankSuggestion!, style: const TextStyle(fontSize: 15, color: Colors.green),)
              ],
              const SizedBox(height: 60,),
              _isLoading?
              const Center(child: CircularProgressIndicator())
              :
              _isSubmitted ?
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("You Scored"),
                    Text("$_quizScore%", style: const TextStyle(fontSize: 100),),
                    const Text("You Solved the Quiz In"),
                    Text("${_getTimeTakenInMinutes() } ${_getTimeTakenInMinutes() == 1 ? "minute" : "minutes"}",
                      style: const TextStyle(fontSize: 50),
                    )
                  ],
                ),
              )
              :
              Center(
                child: ElevatedButton(
                   onPressed: _submit,
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(30),
                     ),
                     textStyle: const TextStyle(fontSize: 18),
                   ),
                   child: const Text('Submit Quiz'),
                 ),
                ),
                const SizedBox(height: 20,),
                Center(
                  child: ElevatedButton(
                    onPressed: widget.onReset,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Back"),
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }
}