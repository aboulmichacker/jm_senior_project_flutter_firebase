import 'package:flutter/material.dart';
import 'package:jm_senior/models/study_schedule_model.dart';

class EventInfo extends StatelessWidget {
  final StudySchedule schedule;


  final Function(StudySchedule, Color) onDelete; // Callback for delete action

  const EventInfo({
    super.key,
    required this.schedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${schedule.topic} from ${TimeOfDay.fromDateTime(schedule.startTime).format(context)} till ${TimeOfDay.fromDateTime(schedule.endTime).format(context)}',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first
            onDelete(schedule, Colors.black);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          child: const Text('Delete This Event'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

//  Helper function to show the dialog (optional, but good practice)
void showEventInfo(BuildContext context,
  StudySchedule schedule,
  Function(StudySchedule, Color) onDelete
){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EventInfo(
        schedule: schedule,
        onDelete: onDelete,
      );
    },
  );
}