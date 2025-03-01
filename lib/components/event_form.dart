import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'package:jm_senior/services/firestore_service.dart';

class EventForm extends StatefulWidget {
  const EventForm({
    super.key,
    required this.selectedTime,
  });
  final DateTime selectedTime;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _timeFormatter = DateFormat('hh:mm a');
  final _eventNameController = TextEditingController();

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
        topic: _eventNameController.text,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Add Event',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Text("Add any event at times where you can't study. Our algorithm will take care of the rest."),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Event Name')
                ),
                controller: _eventNameController,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter a name for the event.';
                  }
                  return null;
                }
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
      ),
    );
  }
}
