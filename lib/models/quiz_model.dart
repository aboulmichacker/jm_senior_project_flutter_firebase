import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz{
  final String? id;
  String? userId;
  String? topic;
  List<MCQuestion> mcQuestions;
  List<TFQuestion> tfQuestions;
  List<OpenEndedQuestion> openEndedQuestions;
  List<FillInTheBlankQuestion> fillInTheBlankQuestions;
  int? score;
  int? timeTaken;
  DateTime? timestamp;

  Quiz({
    this.id,
    this.userId,
    this.topic,
    required this.mcQuestions,
    required this.tfQuestions,
    required this.openEndedQuestions,
    required this.fillInTheBlankQuestions,
    this.score,
    this.timeTaken,
    this.timestamp
  });

  Map<String, dynamic> toFirestore(String uid) {
    return {
      'userId': uid,
      'topic': topic,
      'mcQuestions': mcQuestions.map((q) => q.toJson()).toList(),
      'tfQuestions': tfQuestions.map((q) => q.toJson()).toList(),
      'openEndedQuestions': openEndedQuestions.map((q) => q.toJson()).toList(),
      'fillInTheBlankQuestions': fillInTheBlankQuestions.map((q) => q.toJson()).toList(),
      'score': score,
      'timeTaken': timeTaken,
      'timestamp': FieldValue.serverTimestamp()
    };
  }

  factory Quiz.fromFirestore(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      topic: data['topic'],
      userId: data['userId'] as String,
      mcQuestions: (data['mcQuestions'] as List<dynamic>)
          .map((item) => MCQuestion.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      tfQuestions: (data['tfQuestions'] as List<dynamic>)
          .map((item) => TFQuestion.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      openEndedQuestions: (data['openEndedQuestions'] as List<dynamic>)
          .map((item) => OpenEndedQuestion.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      fillInTheBlankQuestions: (data['fillInTheBlankQuestions'] as List<dynamic>)
          .map((item) => FillInTheBlankQuestion.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      score: data["score"],
      timeTaken: data["timeTaken"],
      timestamp: (data["timestamp"] as Timestamp).toDate()
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'mcQuestions': mcQuestions.map((q) => q.toJson()).toList(),
      'tfQuestions': tfQuestions.map((q) => q.toJson()).toList(),
      'openEndedQuestions': openEndedQuestions.map((q) => q.toJson()).toList(),
      'fillInTheBlankQuestions': fillInTheBlankQuestions.map((q) => q.toJson()).toList(),
    };
  }
  factory Quiz.fromJson(Map<String, dynamic> json){
    return Quiz(
      topic: json['topic'] as String?,
      mcQuestions: (json['mcQuestions'] as List<dynamic>)
          .map((item) => MCQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      tfQuestions: (json['tfQuestions'] as List<dynamic>)
          .map((item) => TFQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      openEndedQuestions: (json['openEndedQuestions'] as List<dynamic>)
          .map((item) => OpenEndedQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      fillInTheBlankQuestions: (json['fillInTheBlankQuestions'] as List<dynamic>)
          .map((item) => FillInTheBlankQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestion{
  final String id;
  final String questionText;
  final dynamic correctAnswer;
  dynamic userAnswer;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    this.userAnswer
  });

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      if(userAnswer != null) 'userAnswer': userAnswer
    };
  }
}

class MCQuestion extends QuizQuestion{
  final List<String> options;

  MCQuestion({
    required super.id,
    required super.questionText,
    required String super.correctAnswer, 
    String? super.userAnswer,
    required this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer
    };
  }
  factory MCQuestion.fromJson(Map<String, dynamic> json) {
    return MCQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      userAnswer: null
    );
  }

  factory MCQuestion.fromFirestore(Map<String, dynamic> data) {
    return MCQuestion(
      id: data['id'] as String,
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      options: List<String>.from(data['options'] as List<dynamic>),
      userAnswer: data['userAnswer'] as String
    );
  }
}

class TFQuestion extends QuizQuestion{
  TFQuestion({
    required super.id,
    required super.questionText,
    required bool super.correctAnswer,
    bool? super.userAnswer
  });

  factory TFQuestion.fromJson(Map<String, dynamic> json) {
    return TFQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as bool,
      userAnswer: null
    );
  }
    factory TFQuestion.fromFirestore(Map<String, dynamic> data) {
    return TFQuestion(
      id: data['id'] as String,
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as bool,
      userAnswer: data['userAnswer'] as bool
    );
  }
}

class OpenEndedQuestion extends QuizQuestion{
  OpenEndedQuestion({
    required super.id,
    required super.questionText,
    required String super.correctAnswer,
    String? super.userAnswer
  });

  factory OpenEndedQuestion.fromJson(Map<String, dynamic> json) {
    return OpenEndedQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      userAnswer: null
    );
  }

    factory OpenEndedQuestion.fromFirestore(Map<String, dynamic> data) {
    return OpenEndedQuestion(
      id: data['id'] as String,
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      userAnswer: data['userAnswer'] as String
    );
  }
}

class FillInTheBlankQuestion extends QuizQuestion{
  FillInTheBlankQuestion({
    required super.id,
    required super.questionText,
    required String super.correctAnswer,
    String? super.userAnswer
  });

  factory FillInTheBlankQuestion.fromJson(Map<String, dynamic> json) {
    return FillInTheBlankQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      userAnswer: null
    );
  }

    factory FillInTheBlankQuestion.fromFirestore(Map<String, dynamic> data) {
    return FillInTheBlankQuestion(
      id: data['id'] as String,
      questionText: data['questionText'] as String,
      correctAnswer: data['correctAnswer'] as String,
      userAnswer: data['userAnswer'] as String
    );
  }
}