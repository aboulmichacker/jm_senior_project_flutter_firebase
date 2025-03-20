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
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> userAnswers = {};
  Map<String, TextEditingController> textControllers = {};

  Map<String, String> suggestions = {};

  bool _isLoading = false;
  int? _quizScore;
 

    // Timer related variables
  int _secondsElapsed = 0;
  Timer? _timer;

  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startTimer(); // Start the timer when the widget is created
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

    void _initializeControllers() {
    // Initialize controllers and default answers for MCQs
    for (var question in widget.quiz.mcQuestions) {
      userAnswers[question.id] = question.options[0]; // Default to the first option
    }
    // Initialize controllers and default answers for TFQs
    for (var question in widget.quiz.tfQuestions) {
      userAnswers[question.id] = true; // Default to true
    }

    // Initialize controllers for OpenEndedQuestions
    for (var question in widget.quiz.openEndedQuestions) {
      textControllers[question.id] = TextEditingController();
      userAnswers[question.id] = "";
    }

    // Initialize controllers for FillInTheBlankQuestions
    for (var question in widget.quiz.fillInTheBlankQuestions) {
      textControllers[question.id] = TextEditingController();
      userAnswers[question.id] = "";
    }
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
    // MC: 9 points each (3 * 9= 27 points total)
    // OE: 14 points each (2*14 = 28 points total)
    // TF: 8 points each (3*8 = 24 points total).
    // FB: 7 points each (3 * 7= 21 points total).
    // 27 + 28 + 24 + 21 = 100.

    int trueFalseMcqScore = 0;
    for(var question in quiz.mcQuestions){
      if(question.userAnswer == question.correctAnswer){
        trueFalseMcqScore += 9;
      }
    }
    for(var question in quiz.tfQuestions){
      if(question.userAnswer == question.correctAnswer){
        trueFalseMcqScore += 8;
      }
    }
    print(" TFMCQ SCORE : $trueFalseMcqScore");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    String prompt = '''
    Correct the following quiz questions. 
    Each open ended question is worth 14 points and each fill in the blank is worth 7 points. 
    Since there are 2 open ended questions and 3 fill in the blank questions the maximum possible score must be 49.
    If an open ended question is partially correct but lacks details give half the grade (7 points) instead of all 14 points.
    For fill in the blanks if the word is not the same as the correct answer remove all points. Ignore case sensitivity.\n\n
    ''';
    for(var oequestion in quiz.openEndedQuestions){
      prompt += "Open ended questions:";
      prompt += "Question ID: ${oequestion.id}\n";
      prompt += "Question: ${oequestion.questionText}\n";
      prompt += "Correct Answer: ${oequestion.correctAnswer}\n";
      prompt += "User Answer: ${oequestion.userAnswer}\n\n";
    }
    for(var fbquestion in quiz.fillInTheBlankQuestions){
      prompt += " \n\n\nFill in the blank questions:";
      prompt += "Question ID: ${fbquestion.id}\n";
      prompt += "Question: ${fbquestion.questionText}\n";
      prompt += "Correct Answer: ${fbquestion.correctAnswer}\n";
      prompt += "User Answer: ${fbquestion.userAnswer}\n\n";
    }
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
        int apiScore = jsonResponse["quiz_score"] as int;
        setState(() {
          _quizScore = trueFalseMcqScore + apiScore;
          // Process open-ended suggestions
          if (jsonResponse.containsKey('open_ended_suggestions') && 
          jsonResponse['open_ended_suggestions'] is List) {
            for (var suggestionItem in jsonResponse['open_ended_suggestions']) {
              if (suggestionItem is Map<String, dynamic> &&
                  suggestionItem.containsKey('questionId') &&
                  suggestionItem.containsKey('suggestion')) {
                suggestions[suggestionItem['questionId']] = suggestionItem['suggestion'];
              }
            }
          }

          // Process fill-in-the-blank suggestions
          if (jsonResponse.containsKey('fill_in_the_blank_suggestions') && 
          jsonResponse['fill_in_the_blank_suggestions'] is List) {
            for (var suggestionItem
                in jsonResponse['fill_in_the_blank_suggestions']) {
              if (suggestionItem is Map<String, dynamic> &&
                  suggestionItem.containsKey('questionId') &&
                  suggestionItem.containsKey('suggestion')) {
                suggestions[suggestionItem['questionId']] = suggestionItem['suggestion'];
              }
            }
          }
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

        for (MCQuestion question in widget.quiz.mcQuestions) {
          question.userAnswer = userAnswers[question.id];
        }
        for (TFQuestion question in widget.quiz.tfQuestions) {
          question.userAnswer = userAnswers[question.id];
        }
        for (OpenEndedQuestion question in widget.quiz.openEndedQuestions) {
          question.userAnswer = userAnswers[question.id];
        }
        for (FillInTheBlankQuestion question in widget.quiz.fillInTheBlankQuestions) {
          question.userAnswer = userAnswers[question.id];
        }

        await _correctQuiz(widget.quiz);
        
        if(_quizScore != null){
          widget.quiz.score = _quizScore;
        }

        widget.quiz.timeTaken = _getTimeTakenInMinutes();

        await FirestoreService().saveQuiz(widget.quiz);
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

  Widget _buildQuestionWidget(dynamic question) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 12),
        _buildQuestionInputWidget(question), 
        if (_isSubmitted && suggestions.containsKey(question.id)) ...[
          const SizedBox(height: 8),
          Text(
            suggestions[question.id]!,
            style: const TextStyle(color: Colors.green),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildQuestionInputWidget(dynamic question) {
    if (question is MCQuestion) {
      return Column(
        children: question.options.map((option) {
          Color? tileColor;
          if (_isSubmitted) {
            if (option == question.correctAnswer) {
              tileColor = Colors.green[100];
            } else if (option == userAnswers[question.id] &&
                option != question.correctAnswer) {
              tileColor = Colors.red[100];
            }
          }
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: userAnswers[question.id],
            onChanged: _isSubmitted
                ? null
                : (value) {
              setState(() {
                userAnswers[question.id] = value!;
              });
            },
            tileColor: tileColor,
          );
        }).toList(),
      );
    } else if (question is TFQuestion) {
      return Column(
        children: [true, false].map((value) {
          Color? tileColor;
          if (_isSubmitted) {
            if (value == question.correctAnswer) {
              tileColor = Colors.green[100];
            } else if (value == userAnswers[question.id] &&
                value != question.correctAnswer) {
              tileColor = Colors.red[100];
            }
          }
          return RadioListTile<bool>(
            title: Text(value ? 'True' : 'False'),
            value: value,
            groupValue: userAnswers[question.id],
            onChanged: _isSubmitted
                ? null
                : (value) {
              setState(() {
                userAnswers[question.id] = value!;
              });
            },
            tileColor: tileColor,
          );
        }).toList(),
      );
    } else if (question is OpenEndedQuestion || question is FillInTheBlankQuestion) {
      return TextFormField(
        controller: textControllers[question.id],
        decoration: InputDecoration(
          labelText: 'Your Answer',
          border: const OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          enabled: !_isSubmitted, // Disable after submission
        ),
        maxLines: question is OpenEndedQuestion ? 5 : 1,
        keyboardType: question is OpenEndedQuestion ? TextInputType.multiline : TextInputType.text,
        validator: (value) {
          if (!_isSubmitted && (value == null || value.isEmpty)) {
            return 'Please answer the question';
          }
          return null;
        },
        onChanged: (value) {
          if (!_isSubmitted) {
            userAnswers[question.id] = value;
          }
        },
      );
    } else {
      return const Text('Unknown question type');
    }
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
              const Text("1. Multiple Choice Questions", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              ...widget.quiz.mcQuestions.map(_buildQuestionWidget),
              const Text("2. True or False Questions", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              ...widget.quiz.tfQuestions.map(_buildQuestionWidget),
              const Text("3. Open Ended Questions", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              ...widget.quiz.openEndedQuestions.map(_buildQuestionWidget),
              const Text("4. Fill in the Blank Questions", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              ...widget.quiz.fillInTheBlankQuestions.map(_buildQuestionWidget),
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