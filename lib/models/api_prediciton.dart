class ApiPrediction{
  final String topic;
  final double studyDuration;

  ApiPrediction({
    required this.topic,
    required this.studyDuration
  });


  factory ApiPrediction.fromJSON(Map<String,dynamic> data){
    return ApiPrediction(
      topic: data['topic'] as String, 
      studyDuration: data['study_duration'] as double,
    );
  }
}