import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'package:jm_senior/services/firestore_service.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({
    super.key,
    required this.selectedTime,
    required this.exam,
  });
  final Exam exam;
  final DateTime selectedTime;

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _timeFormatter = DateFormat('hh:mm a');
  String? _selectedTopic;

  bool _isLoading = false;

  late DateTime _startTime;
  late DateTime _endTime;
  @override
  void initState() {
    super.initState();
    _startTime = widget.selectedTime;
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  void _selectStartTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    ).then((value) {
      if (value != null) {
        setState(() {
          _startTime = DateTime(
            widget.selectedTime.year,
            widget.selectedTime.month,
            widget.selectedTime.day,
            value.hour,
            value.minute,
          );
        });
      }
    });
  }

  void _selectEndTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    ).then((value) {
      if (value != null) {
        setState(() {
          _endTime = DateTime(
            widget.selectedTime.year,
            widget.selectedTime.month,
            widget.selectedTime.day,
            value.hour,
            value.minute,
          );
        });
      }
    });
  }

  String? _validateEndTime(DateTime? time) {
    if (time == null) {
      return 'Please select a time';
    } else if (time.isBefore(_startTime)) {
      return 'End Time must be after start time';
    }
    return null;
  }

  void _addstudySchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final newStudySchedule = StudySchedule(
        examId: widget.exam.id!,
        topic: _selectedTopic!,
        startTime: _startTime,
        endTime: _endTime,
      );

      await FirestoreService().addstudySchedule(newStudySchedule);
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Add Schedule',
              style: TextStyle(fontSize: 30),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Topic'),
              value: _selectedTopic,
              items: widget.exam.topics.map((topic) => DropdownMenuItem<String>(
                            value: topic,
                            child: Text(topic),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTopic = value;
                });
              },
              validator: (value) => _selectedTopic == null
                  ? 'Please select a topic'
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Start Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _selectStartTime(context),
              controller: TextEditingController(
                text: _timeFormatter.format(_startTime),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'End Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _selectEndTime(context),
              validator: (_) => _validateEndTime(_endTime),
              controller: TextEditingController(
                text: _timeFormatter.format(_endTime),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addstudySchedule,
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, foregroundColor: Colors.white),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
