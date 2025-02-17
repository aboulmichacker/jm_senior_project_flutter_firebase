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
   const QuizWidget({super.key, required this.quiz});

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
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final prompt = '''
      Correct the following quiz and return an accuracy score from 0 to 100.
      for the open ended question and fill in the blank question, if answers are partially correct, add 5 to 12% to the accuracy score instead of removing all 25%
      for fill in the blanks disregard case sensitivity and if the word has the same meaning mark it as correct.
      "multiple choice question"{
        "questionText" : ${quiz.mcQuestion.questionText},
        "options": ${quiz.mcQuestion.options},
        "correctAnswer": ${quiz.mcQuestion.correctAnswer},
        "userAnswer": ${quiz.mcQuestion.userAnswer}
      }
      "true or false question"{
        "questionText": ${quiz.tfQuestion.questionText},
        "correctAnswer": ${quiz.tfQuestion.correctAnswer},
        "userAnswer": ${quiz.tfQuestion.userAnswer}
      }
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
      model: 'gemini-1.5-flash',
      apiKey: apiKey!,
      generationConfig: GenerationConfig(responseMimeType: 'application/json', responseSchema: Schemas().resultSchema)
    );

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if(response.text != null){
        Map<String,dynamic> jsonResponse = jsonDecode(response.text!);
        setState(() {
          _quizScore = jsonResponse["accuracy_score"];
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
        setState(() {
          _isLoading = false;

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
                RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedMcqOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedMcqOption = value!;
                    });
                  },
                ),
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
                if(_openEndedSuggestion != null)
                ...[
                  const SizedBox(height: 20,),
                  Text(_openEndedSuggestion!, style: const TextStyle(fontSize: 15, color: Colors.green),)
                ],
                const SizedBox(height: 40,),
                Text(widget.quiz.tfQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
                ),
                const SizedBox(height: 12),
                RadioListTile(
                    title: const Text('True'),
                    value: true, 
                    groupValue: _selectedTrueOrFalseAnswer, 
                    onChanged: (value){
                      setState(() { 
                        _selectedTrueOrFalseAnswer = value!;
                      });
                    }
                  ),
                RadioListTile(
                  title: const Text('False'),
                  value: false, 
                  groupValue: _selectedTrueOrFalseAnswer, 
                  onChanged: (value){
                    setState(() { 
                      _selectedTrueOrFalseAnswer = value!;
                    });
                  }
                ),
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
              if(_fillInTheBlankSuggestion != null)
              ...[
                const SizedBox(height: 20,),
                Text(_fillInTheBlankSuggestion!, style: const TextStyle(fontSize: 15, color: Colors.green),)
              ],
              const SizedBox(height: 60,),
              _isLoading?
              const Center(child: CircularProgressIndicator())
              :
              _quizScore != null ?
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("You Scored"),
                    Text("$_quizScore%", style: const TextStyle(fontSize: 100),),
                    const Text("You Solved the Quiz In"),
                    Text("${_getTimeTakenInMinutes()} minutes", style: const TextStyle(fontSize: 50),)
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
                )
              ],
            ),
          ),
      ),
    );
  }
}