import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/components/event_form.dart';
import 'package:jm_senior/components/event_info.dart';
import 'package:jm_senior/components/schedule_form.dart';
import 'package:jm_senior/components/study_schedule_info.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:jm_senior/services/firestore_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:jm_senior/models/study_schedule_model.dart';

class Schedule extends StatefulWidget {
  final Exam? exam;
  const Schedule({super.key, this.exam});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  List<Exam> exams = [];
  DateTime? selectedTime;
  Exam? currentExam;
  bool _examsLoaded = false;
  @override
  void initState(){
    super.initState();
    currentExam = widget.exam;
    _loadExams();
  }

  Future<void> _loadExams() async {
    if(!_examsLoaded){
      final fetchedExams = await FirestoreService().getExamsList();
      setState(() {
        exams = fetchedExams;  
        _examsLoaded = true;
      });
    }
  }

  void _setTime(CalendarTapDetails details) {
    selectedTime = details.date!;
  }

  List<Appointment> _mapSchedulesToAppointments(
      List<StudySchedule> schedules, List<Exam> exams) {
    return schedules.map((schedule) {
      String subject = '';
      if(schedule.examId != null){
        Exam scheduleExam =
            exams.firstWhere((exam) => exam.id == schedule.examId);
        subject = scheduleExam.subject;
      }
      return Appointment(
        id: schedule.id,
        subject: schedule.topic,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        color: _getColor(subject),
      );
    }).toList();
  }

  Color _getColor(String? subject) {
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
            exam: widget.exam!,
            selectedTime: selectedTime!,
          );
        });
  }

  void _addEvent(){
        showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return EventForm(
            selectedTime: selectedTime!,
          );
        });
  }

  Future<void> _deleteSchedule(StudySchedule schedule, Color snackbarColor) async {
    final backupData = StudySchedule(
        examId: schedule.examId,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        topic: schedule.topic);
    await FirestoreService().deletestudySchedule(schedule.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackbarColor != Colors.black ? "Study ${schedule.topic} deleted" : "Event Deleted"),
        duration: const Duration(seconds: 5),
        backgroundColor: snackbarColor,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await FirestoreService().addstudySchedule(backupData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${snackbarColor != Colors.black ? 'Study Session': 'Event'} restored')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error restoring: $e')),
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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTime != null) {
            if(currentExam != null){
              _addSchedule();
            }else{
              _addEvent();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Tap on the calendar to select a date')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: 
      _examsLoaded ?
      Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownMenu(
                helperText: "Select an Exam",
                initialSelection: currentExam?.id,
                dropdownMenuEntries: [
                  const DropdownMenuEntry(
                    value: null,
                    label: 'Full Schedule',
                  ),
                  ...exams.map((exam) => DropdownMenuEntry<String?>(
                    value: exam.id,
                    label: '${exam.subject} exam on ${DateFormat('EEEE MMMM d \'at\' h:mm a').format(exam.date)}',
                  )),
                ],
                onSelected: (value){
                  setState(() {
                    currentExam = value != null ? exams.firstWhere((exam) => exam.id == value) : null;
                  
                  });
                }
              ),
            ),
        
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: 
                 StreamBuilder<List<StudySchedule>>(
                    stream: FirestoreService().getSchedulesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
              
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
              
                      final List<StudySchedule> fetchedSchedules = snapshot.data ?? [];
              
                      List<StudySchedule> filteredSchedules = currentExam != null ? 
                      fetchedSchedules.where((schedule) => schedule.examId == currentExam!.id).toList()
                      : fetchedSchedules;
                      
                      //map the schedules from the database to UI elements as an 
                      //"Appointment" object provided by the sfcalendar library
                      List<Appointment> appointments = _mapSchedulesToAppointments(filteredSchedules, exams);
              
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
                            StudySchedule selectedSchedule = 
                            filteredSchedules.firstWhere((schedule) => schedule.id == tappedAppointment.id);
                            if(selectedSchedule.examId != null){
                              Exam selectedExam = exams.firstWhere((exam) => exam.id == selectedSchedule.examId);
                              //get the corresponding exam for selected schedule to display as info
                              showScheduleInfo(
                                context, 
                                selectedSchedule, 
                                selectedExam,
                                tappedAppointment.color, 
                                _deleteSchedule
                              );
                            }else{
                              showEventInfo(
                                context, 
                                selectedSchedule, 
                                _deleteSchedule
                              );
                            }
                          }
                        },
                        firstDayOfWeek: 1,
                        allowDragAndDrop: true,
                        onDragEnd: (appointmentDragEndDetails) {
                          final draggedItem = appointmentDragEndDetails.appointment as Appointment;
                          final updatedSchedule = filteredSchedules.firstWhere((element) => element.id == draggedItem.id);
                          Duration diff = updatedSchedule.endTime.difference(updatedSchedule.startTime);
                          draggedItem.startTime = appointmentDragEndDetails.droppingTime!;
                          draggedItem.endTime = appointmentDragEndDetails.droppingTime!.add(diff);
                          FirestoreService().updatestudySchedule(
                            StudySchedule(
                              id: updatedSchedule.id,
                              startTime: draggedItem.startTime, 
                              endTime: draggedItem.endTime,
                              examId: updatedSchedule.examId,
                              topic: updatedSchedule.topic
                            )
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
      ) : const Center(child: CircularProgressIndicator())
    );
  }
}

//required for sfcalendar widget
class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}
