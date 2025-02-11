import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'package:jm_senior/models/exam_model.dart';

class StudyScheduleInfo extends StatelessWidget {
  final StudySchedule schedule;
  final Exam exam;
  final Color color;

  final Function(StudySchedule, Color) onDelete; // Callback for delete action

  const StudyScheduleInfo({
    super.key,
    required this.schedule,
    required this.exam,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Study ${schedule.topic} from ${TimeOfDay.fromDateTime(schedule.startTime).format(context)} till ${TimeOfDay.fromDateTime(schedule.endTime).format(context)}',
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Since you have a ${exam.subject} exam on ${DateFormat('EEEE MMMM d \'at\' h:mm a').format(exam.date)}',
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first
            onDelete(schedule, color);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          child: const Text('Delete This Study Session'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

//  Helper function to show the dialog (optional, but good practice)
void showScheduleInfo(BuildContext context,
  StudySchedule schedule,
  Exam exam,
  Color color,
  Function(StudySchedule, Color) onDelete
){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StudyScheduleInfo(
        schedule: schedule,
        exam: exam,
        color: color,
        onDelete: onDelete,
      );
    },
  );
}