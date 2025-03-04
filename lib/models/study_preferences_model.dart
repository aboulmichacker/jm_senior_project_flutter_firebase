class StudyPreferences {
  int studySessionDuration;
  int breakDuration;
  String studyStartTime;
  String studyEndTime;
  String weekendStartTime;
  String weekendEndTime;

  StudyPreferences({
    this.studySessionDuration = 45,
    this.breakDuration = 15,
    this.studyStartTime = '15:00',
    this.studyEndTime = '23:00',
    this.weekendStartTime = '15:00',
    this.weekendEndTime = '23:00'
  });

  factory StudyPreferences.fromFirestore(Map<String,dynamic> data){
    return StudyPreferences(
      studySessionDuration: data['studySessionDuration'] ?? 45,
      breakDuration: data['breakDuration'] ?? 15,
      studyStartTime: data['studyStartTime'] ?? '15:00',
      studyEndTime: data['studyEndTime'] ?? '23:00',
      weekendStartTime: data['weekendStartTime'] ?? '15:00',
      weekendEndTime: data['weekendEndTime'] ?? '23:00',
    );
  }

    Map<String, dynamic> toFirestore() {
    return {
      'studySessionDuration': studySessionDuration,
      'breakDuration': breakDuration,
      'studyStartTime': studyStartTime,
      'studyEndTime': studyEndTime,
      'weekendStartTime': weekendStartTime,
      'weekendEndTime': weekendEndTime
    };
  }
}