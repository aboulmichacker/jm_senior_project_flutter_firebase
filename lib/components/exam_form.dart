import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jm_senior/components/subject_topic_picker.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:jm_senior/services/firestore_service.dart';

class ExamForm extends StatefulWidget {
  final Exam? exam;
  const ExamForm({super.key, this.exam});

  @override
  State<ExamForm> createState() => _ExamFormState();
}

class _ExamFormState extends State<ExamForm> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('yMMMMEEEEd');
  final DateFormat _timeFormatter = DateFormat('hh:mm a');

  bool _isLoading = false;
  String? _subject;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  DateTime _dateTime = DateTime.now();
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    // Initialize form fields if updating an existing exam
    if (widget.exam != null) {
      _subject = widget.exam!.subject;
      _selectedDate = widget.exam!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.exam!.date);
      _dateTime = widget.exam!.date;
      _topics = List.from(widget.exam!.topics);  // Create a copy of the list
    }
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      if(value != null){
        setState(() {
          _selectedDate = value;
          _setDateTime();
        });
      }
    });
  }

  void _selectTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    ).then((value) {
      if(value != null){
        setState(() {
          _selectedTime = value;
          _setDateTime();
        });
      }
    });
  }

  void _setDateTime() {
    if (_selectedTime != null) {
      setState(() {
        _dateTime = DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _selectedTime!.hour, _selectedTime!.minute);
      });
    }
  }

  String? _validateDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    } else if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    return null;
  }

  String? _validateTime(TimeOfDay? time) {
    if (time == null) {
      return 'Please select a time';
    }
    return null;
  }

  Future<void> _addOrUpdateExam() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        if(widget.exam == null){
          await FirestoreService().addExam(
            exam: Exam(
                subject: _subject!,
                date: _dateTime,
                topics: _topics,
                hasSchedule: false
          ));
        }else{
          await FirestoreService().updateExam(
            exam: Exam(
              id: widget.exam!.id,
              subject: _subject!,
              date: _dateTime,
              topics: _topics,
              hasSchedule: widget.exam!.hasSchedule
            )
          );
        }

        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam ${widget.exam != null ? 'updated' : 'added' } successfully!')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exam: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.exam == null ?
                const Text(
                  'Add an Exam',
                  style: TextStyle(fontSize: 30),
                ) :
                const Text(
                  'Edit Exam',
                  style: TextStyle(fontSize: 30),
                ),
                SubjectTopicPicker(
                  initialSubject: widget.exam?.subject,
                  onSubjectSelected: (subject){
                    _subject = subject;
                    setState(() {
                      _topics = [];
                    });
                  },
                  onTopicSelected: (topic){
                    setState(() {
                      if(!_topics.contains(topic)){
                        _topics.add(topic!);
                      }
                    });
                  }
                ),
                const SizedBox(
                  height: 20,
                ),
                if(_topics.isNotEmpty)
                ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: 
                      _topics.map((topic) {
                        return InputChip(
                          label: Text(topic),
                          onDeleted: () {
                            setState(() {
                              _topics.remove(topic);
                            });
                          },
                        );
                      }).toList()
                   
                  ),
                  const SizedBox(height: 20,)
                ],
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (_) => _validateDate(_selectedDate),
                  controller: TextEditingController(
                    text: _dateFormatter.format(_selectedDate),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap:() => _selectTime(context),
                  validator: (_) => _validateTime(_selectedTime),
                  controller: TextEditingController(
                    text: _selectedTime != null
                        ? _timeFormatter.format(DateTime(
                            0, 0, 0, _selectedTime!.hour, _selectedTime!.minute))
                        : '',
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _addOrUpdateExam,
                        child: widget.exam == null ? const Text('Add Exam') : const Text("Update Exam"),
                      ),
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
