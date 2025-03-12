import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jm_senior/Pages/existing_quizzes_page.dart';
import 'package:jm_senior/Pages/my_quizzes_page.dart';
import 'package:jm_senior/assets/schemas.dart';
import 'package:jm_senior/components/quiz_widget.dart';
import 'package:jm_senior/components/subject_topic_picker.dart';
import 'package:jm_senior/models/quiz_model.dart';
// import 'package:jm_senior/sample_data.dart';
import 'package:jm_senior/services/firestore_service.dart';

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
  Quiz? quiz;// = SampleData().sampleQuiz; //FOR TESTING PURPOSES ONLY. TO BE REMOVED LATER.

  // @override
  // void initState(){
  //   super.initState();
  //   if(quiz != null){
  //     quiz!.topic = "Algebra";
  //   }
  // }
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
            if(quiz != null){
              await FirestoreService().saveGeneratedQuiz(quiz!);
            }
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

  void _selectExistingQuiz(Quiz selectedQuiz) {
    if(mounted){
      setState(() {
        quiz = selectedQuiz;
      });
    }
  }

  Future<void> _navigateToExistingQuizzes(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    List<Quiz> quizzes = await FirestoreService().getGeneratedQuizzes(_selectedTopic!);

    if (quizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No quizzes found.'),
        ),
      );
    setState(() {
      _isLoading = false;
    });
      return;
    }

    Quiz? selectedQuiz = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExistingQuizzesPage(
          selectedTopic: _selectedTopic!,
          quizzes: quizzes,
          onQuizSelected: _selectExistingQuiz, // Pass the callback
        ),
      ),
    );

    //Check if a quiz was selected before updating the state.
    if (selectedQuiz != null) {
        _selectExistingQuiz(selectedQuiz); // redundant but to make it clearer
    }
    setState(() {
      _isLoading = false;
    });
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
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/classroom_bg.jpeg'),
              opacity: 0.2,
              fit: BoxFit.cover
            )
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
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
                    : Column(
                      children: [
                        ElevatedButton.icon(
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
                              textStyle: const TextStyle(fontSize: 18, fontFamily: "Quicksand"),
                            ),
                            icon: const Icon(Icons.auto_awesome, color: Colors.white,),
                            label: const Text('Generate Quiz', style: TextStyle(color: Colors.white)),
                          ),
                      const SizedBox(height:20),
                      const Center(child: Text("OR")),
                      const SizedBox(height:20),
                      ElevatedButton.icon(
                        onPressed: () {
                          if(_formKey.currentState!.validate()){
                            _navigateToExistingQuizzes(context);
                          }
                        },
                        icon: const Icon(Icons.list, color: Colors.white),
                        label: const Text('Browse Existing Quizzes', style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                      ],
                    ),
                    ],
                  ),
              ),
            ),
          ),
        ),
    );
  }
}
