import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jm_senior/assets/schemas.dart';
import 'package:jm_senior/components/quiz_widget.dart';
import 'package:jm_senior/components/subject_topic_picker.dart';
import 'package:jm_senior/models/quiz_model.dart';
class QuizMePage extends StatefulWidget {
  const QuizMePage({super.key});

  @override
  State<QuizMePage> createState() => _QuizMePageState();
}

class _QuizMePageState extends State<QuizMePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  String? _selectedTopic;
  bool _isLoading = false;
  Quiz? quiz;// = Quiz.fromJson({"topic":"Electricity and Magnetism","fillInTheBlankQuestion": {"correctAnswer": "circuit", "questionText": "A complete path through which electricity can flow is called a(n) _______."}, "mcQuestion": {"correctAnswer": "parallel", "options": ["series", "parallel", "open", "closed"], "questionText": "What type of circuit has more than one path for the current to flow?"}, "openEndedQuestion": {"correctAnswer": "A magnet attracts iron and other magnetic materials.  It has a north and south pole. Like poles repel each other, and opposite poles attract each other.", "questionText": "Explain the properties of a magnet."}, "tfQuestion": {"correctAnswer": true, "questionText": "Static electricity is the buildup of electrical charges on the surface of an object."}});
  //SAMPLE QUIZ FOR TESTING PURPOSES. WILL LATER BE REMOVED.
  Future<void> _generateQuiz() async {
    if(_formKey.currentState!.validate()){
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      final prompt = 'Generate a $_selectedSubject quiz for a middle school student with the topic $_selectedTopic ';

      try {
        setState(() {
          quiz = null;
          _isLoading = true;
        });
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey!,
          generationConfig: GenerationConfig(responseMimeType: 'application/json', responseSchema: Schemas().quizSchema)
        );

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        if(response.text != null){
          setState(() {
            quiz = Quiz.fromJson(jsonDecode(response.text!));
            quiz?.topic = _selectedTopic;
          });
        }
      } catch (e) {
        throw Exception('Error Generating Quiz: ${e.toString()}'); 
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return quiz != null ?
      QuizWidget(quiz: quiz!)
      :
      Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: SubjectTopicPicker(
                onSubjectSelected: (subject){
                  setState(() { 
                    _selectedSubject = subject;
                  });
                },
                onTopicSelected: (topic){
                  setState(() {
                    _selectedTopic = topic;
                  });
                } 
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _isLoading ? null : (){
                  try{
                    _generateQuiz();
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: Colors.red,
                      )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
      );
  }
}
