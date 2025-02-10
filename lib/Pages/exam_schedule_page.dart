import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/components/schedule_form.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:jm_senior/services/firestore_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:jm_senior/models/study_schedule_model.dart';

class Schedule extends StatefulWidget {
  final Exam exam;
  const Schedule({super.key, required this.exam});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  DateTime? selectedTime;

  void _setTime(CalendarTapDetails details) {
    selectedTime = details.date!;
  }

  Color _getColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.green;
      case 'Physics':
        return Colors.grey;
      case 'Chemistry':
        return Colors.pink;
      default:
        return Colors.black;
    }
  }

  void _addSchedule() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ScheduleForm(
            exam: widget.exam,
            selectedTime: selectedTime!,
          );
        });
  }

  Future<void> _deleteSchedule(
      String scheduleId, StudySchedule schedule, Color snackbarColor) async {
    final backupData = StudySchedule(
        examId: schedule.examId,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        topic: schedule.topic);
    await FirestoreService().deletestudySchedule(scheduleId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Study ${schedule.topic} deleted'),
        duration: const Duration(seconds: 5),
        backgroundColor: snackbarColor,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await FirestoreService().addstudySchedule(backupData);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule restored')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error restoring schedule: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTime != null) {
            _addSchedule();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Tap on the calendar to select a date')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<List<StudySchedule>>(
            stream: FirestoreService().getstudySchedulesforExam(widget.exam.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final List<StudySchedule> scheduleList = snapshot.data ?? [];

              List<Appointment> appointments = scheduleList.map((schedule) {
                return Appointment(
                  id: schedule.id,
                  subject: schedule.topic,
                  startTime: schedule.startTime,
                  endTime: schedule.endTime,
                  color: _getColor(widget.exam.subject),
                );
              }).toList();

              return SfCalendar(
                view: CalendarView.week,
                timeSlotViewSettings: const TimeSlotViewSettings(
                  timeInterval: Duration(minutes: 25),
                  timeIntervalWidth: 200,
                ),
                showNavigationArrow: true,
                dataSource: DataSource(appointments),
                onTap: (details) {
                  if (details.targetElement == CalendarElement.calendarCell) {
                    _setTime(details);
                  } else if (details.targetElement == CalendarElement.appointment) {
                    Appointment tappedAppointment = details.appointments!.first;

                    StudySchedule schedule = scheduleList.firstWhere((schedule) => schedule.id == tappedAppointment.id);

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Study ${schedule.topic} from ${TimeOfDay.fromDateTime(schedule.startTime).format(context)} till ${TimeOfDay.fromDateTime(schedule.endTime).format(context)}',
                              textAlign: TextAlign.center,
                            ),
                            content: Text('Since you have a ${widget.exam.subject} exam on ${DateFormat('EEEE MMMM d \'at\' h:mm a').format(widget.exam.date)}',
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: tappedAppointment.color,
                            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                            contentTextStyle: const TextStyle(color: Colors.white, ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteSchedule(schedule.id!, schedule, tappedAppointment.color);
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
                        });
                  }
                },
                firstDayOfWeek: 1,
                todayHighlightColor: Colors.yellow.shade700,
              );
            }),
      ),
    );
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}
