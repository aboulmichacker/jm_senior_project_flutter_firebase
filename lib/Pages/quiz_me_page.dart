import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jm_senior/Pages/my_quizzes_page.dart';
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
  Quiz? quiz = Quiz.fromJson(
    {
  "mcQuestions": [
      {
        "id": "mc1",
        "questionText": "Solve for x:  2x + 5 = 11",
        "options": [
          "2",
          "3",
          "4",
          "6"
        ],
        "correctAnswer": "3"
      },
      {
        "id": "mc2",
        "questionText": "Simplify the expression: 3(y - 4) + 2y",
        "options": [
          "5y - 12",
          "5y - 4",
          "y - 12",
          "3y - 12"
        ],
        "correctAnswer": "5y - 12"
      },
      {
        "id": "mc3",
        "questionText": "If a shirt costs USD 20 and is on sale for 25% off, what is the sale price?",
        "options": [
          "USD 5",
          "USD 15",
          "USD 10",
          "USD 25"
        ],
        "correctAnswer": "USD 15"
      }
    ],
    "openEndedQuestions": [
      {
        "id": "oe1",
        "questionText": "Solve for x:  (x/4) - 7 = 2",
        "correctAnswer": "36"
      },
      {
        "id": "oe2",
        "questionText": "A rectangle has a length of (x + 5) cm and a width of 3 cm.  If the area of the rectangle is 24 cm², what is the value of x?",
        "correctAnswer": "3"
      }
    ],
    "tfQuestions": [
      {
        "id": "tf1",
        "questionText": "The expression 5x + 2x - 3x is equivalent to 4x.",
        "correctAnswer": true
      },
      {
        "id": "tf2",
        "questionText": "If 2y = 10, then y = 20.",
        "correctAnswer": false
      },
      {
        "id": "tf3",
        "questionText": "In the equation y = mx + b, 'b' represents the slope of the line.",
        "correctAnswer": false
      }
    ],
    "fillInTheBlankQuestions": [
      {
        "id": "fb1",
        "questionText": "Simplify: 12a - 5a + 2a = ____a",
        "correctAnswer": "9"
      },
      {
        "id": "fb2",
        "questionText": "If x + 7 = 15, then x = ____.",
        "correctAnswer": "8"
      },
      {
        "id": "fb3",
        "questionText": "The solution to the equation 3n = 21 is n = _____.",
        "correctAnswer": "7"
      }
    ]
  }

  );
  @override
  void initState(){
    super.initState();
    if(quiz != null){
      quiz!.topic = "Algebra";
    }
  }
//FOR TESTING PURPOSES ONLY. TO BE REMOVED LATER.
  Future<void> _generateQuiz() async {
    if(_formKey.currentState!.validate()){
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      final prompt = 'Generate a $_selectedSubject quiz for a middle school student with the topic $_selectedTopic ';

      try {
        setState(() {
          _isLoading = true;
        });
        final model = GenerativeModel(
          model: 'gemini-2.0-flash',
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
        } else {
          // Handle the case where response.text is null
          
          // Show an error message to the user, or perhaps retry the request.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error generating quiz. Please try again.'), backgroundColor: Colors.red),
          );
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

  void _resetQuiz(){
    setState(() {
      quiz = null;
      _selectedSubject = null;
      _selectedTopic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Me", style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          TextButton.icon(
            onPressed:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const MyQuizzesPage()));
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent, 
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            label: const Text("My Quizzes"),
            icon: const Icon(Icons.menu_book, color: Colors.black,),
          )
        ],
      ),
      body: quiz != null ?
        QuizWidget(quiz: quiz!, onReset: _resetQuiz)
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
              : ElevatedButton.icon(
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
                  icon: const Icon(Icons.auto_awesome, color: Colors.white,),
                  label: const Text('Generate Quiz', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        ),
    );
  }
}
