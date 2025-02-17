import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz{
  final String? id;
  String? userId;
  String? topic;
  MCQuestion mcQuestion;
  TFQuestion tfQuestion;
  OpenEndedQuestion openEndedQuestion;
  FillInTheBlankQuestion fillInTheBlankQuestion;
  int? accuracy;
  int? timeTaken;

  Quiz({
    this.id,
    this.userId,
    this.topic,
    required this.mcQuestion,
    required this.tfQuestion,
    required this.openEndedQuestion,
    required this.fillInTheBlankQuestion,
    this.accuracy,
    this.timeTaken,
  });

  Map<String, dynamic> toFirestore(String uid) {
    return {
      'userId': uid,
      'topic': topic,
      'mcQuestion': mcQuestion.toJson(),
      'tfQuestion': tfQuestion.toJson(),
      'openEndedQuestion': openEndedQuestion.toJson(),
      'fillInTheBlankQuestion': fillInTheBlankQuestion.toJson(),
      'accuracy': accuracy,
      'timeTaken': timeTaken,
      'timestamp': FieldValue.serverTimestamp()
    };
  }

  factory Quiz.fromFirestore(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      userId: data['userId'] as String,
      mcQuestion: MCQuestion.fromJson(data['mcQuestion'] as Map<String, dynamic>),
      tfQuestion: TFQuestion.fromJson(data['tfQuestion'] as Map<String, dynamic>),
      openEndedQuestion:
          OpenEndedQuestion.fromJson(data['openEndedQuestion'] as Map<String, dynamic>),
      fillInTheBlankQuestion: FillInTheBlankQuestion.fromJson(
          data['fillInTheBlankQuestion'] as Map<String, dynamic>),
    );
  }
  
  factory Quiz.fromJson(Map<String, dynamic> json){
    return Quiz(
      mcQuestion: MCQuestion.fromJson(json['mcQuestion'] as Map<String, dynamic>),
      tfQuestion: TFQuestion.fromJson(json['tfQuestion'] as Map<String, dynamic>),
      openEndedQuestion:
          OpenEndedQuestion.fromJson(json['openEndedQuestion'] as Map<String, dynamic>),
      fillInTheBlankQuestion: FillInTheBlankQuestion.fromJson(
          json['fillInTheBlankQuestion'] as Map<String, dynamic>),
    );
  }
}

class QuizQuestion{
  final String questionText;
  final dynamic correctAnswer;
  dynamic userAnswer;

  QuizQuestion({
    required this.questionText,
    required this.correctAnswer,
    this.userAnswer
  });

    Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer
    };
  }
}

class MCQuestion extends QuizQuestion{
  final List<String> options;

  MCQuestion({
    required super.questionText,
    required String super.correctAnswer, 
    String? super.userAnswer,
    required this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer
    };
  }
  factory MCQuestion.fromJson(Map<String, dynamic> json) {
    return MCQuestion(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      userAnswer: null
    );
  }

  factory MCQuestion.fromFirestore(Map<String, dynamic> data) {
    return MCQuestion(
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      options: List<String>.from(data['options'] as List<dynamic>),
      userAnswer: data['userAnswer'] as String
    );
  }
}

class TFQuestion extends QuizQuestion{
  TFQuestion({
    required super.questionText,
    required bool super.correctAnswer,
    bool? super.userAnswer
  });

  factory TFQuestion.fromJson(Map<String, dynamic> json) {
    return TFQuestion(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as bool,
      userAnswer: null
    );
  }
    factory TFQuestion.fromFirestore(Map<String, dynamic> data) {
    return TFQuestion(
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as bool,
      userAnswer: data['userAnswer'] as bool
    );
  }
}

class OpenEndedQuestion extends QuizQuestion{
  OpenEndedQuestion({
    required super.questionText,
    required String super.correctAnswer,
    String? super.userAnswer
  });

  factory OpenEndedQuestion.fromJson(Map<String, dynamic> json) {
    return OpenEndedQuestion(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      userAnswer: null
    );
  }

    factory OpenEndedQuestion.fromFirestore(Map<String, dynamic> data) {
    return OpenEndedQuestion(
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      userAnswer: data['userAnswer'] as String
    );
  }
}

class FillInTheBlankQuestion extends QuizQuestion{
  FillInTheBlankQuestion({
    required super.questionText,
    required String super.correctAnswer,
    String? super.userAnswer
  });

  factory FillInTheBlankQuestion.fromJson(Map<String, dynamic> json) {
    return FillInTheBlankQuestion(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      userAnswer: null
    );
  }

    factory FillInTheBlankQuestion.fromFirestore(Map<String, dynamic> data) {
    return FillInTheBlankQuestion(
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      userAnswer: data['userAnswer'] as String
    );
  }
}