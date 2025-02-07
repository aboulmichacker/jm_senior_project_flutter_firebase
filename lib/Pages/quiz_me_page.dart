import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jm_senior/assets/schemas.dart';
import 'package:jm_senior/components/subject_topic_picker.dart';
class QuizMePage extends StatefulWidget {
  const QuizMePage({super.key});

  @override
  State<QuizMePage> createState() => _QuizMePageState();
}

class _QuizMePageState extends State<QuizMePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  String? _selectedTopic;
  String? _responseText;
  bool _isLoading = false;

  Future<void> _generateQuiz() async {
    if(_formKey.currentState!.validate()){
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    final prompt = 'Generate a $_selectedSubject quiz for a middle school student with the topic $_selectedTopic ';

    try {
      setState(() {
        _responseText = null;
        _isLoading = true;
      });
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(responseMimeType: 'application/json', responseSchema: Schemas().quizSchema)
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      setState(() {
        _responseText = response.text;
      });
    } catch (e) {
      setState(() {
        _responseText = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        onPressed: _isLoading ? null : _generateQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white)),
                      ),
                if (_responseText != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    child: Text(_responseText!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
