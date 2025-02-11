import 'package:flutter/material.dart';

class SubjectTopicPicker extends StatefulWidget {
  final Function(String?) onSubjectSelected;
  final Function(String?) onTopicSelected;
  final String? initialSubject;
  const SubjectTopicPicker({super.key, 
    required this.onSubjectSelected, 
    required this.onTopicSelected,
    this.initialSubject,
  });

  @override
  State<SubjectTopicPicker> createState() => _SubjectTopicPickerState();
}

class _SubjectTopicPickerState extends State<SubjectTopicPicker> {
  String? _selectedSubject;
  String? _selectedTopic;

  final Map<String, List<String>> _topics = {
    'Math': [
      'Algebra',
      'Fractions and Decimals',
      'Geometry',
      'Ratios and Proportions',
      'Statistics and Probability',
    ],
    'Physics': [
      'Motion and Forces',
      'Energy',
      'Light and Sound',
      'Electricity and Magnetism',
      'Simple Machines',
    ],
    'Chemistry': [
      'The Structure of Matter',
      'The Periodic Table',
      'Chemical Reactions',
      'Acids and Bases',
      'Mixtures and Solutions',
    ],
  };


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Subject'),
          value: widget.initialSubject ?? _selectedSubject,
          items: _topics.keys.map((subject) => DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
              widget.onSubjectSelected(_selectedSubject);
              _selectedTopic = null; // Reset topic when subject changes
            });
          },
          validator: (value) => value == null ? 'Please select a subject' : null,

        ),
        const SizedBox(height: 20), // Add some spacing
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Topic'),
          value: _selectedTopic,
          items: _selectedSubject != null
              ? _topics[_selectedSubject]!.map((topic) => DropdownMenuItem<String>(
                    value: topic,
                    child: Text(topic),
                  )).toList()
              : [], // Show empty list if no subject is selected
          onChanged: _selectedSubject != null
              ? (value) {
                  setState(() {
                    _selectedTopic = value;
                    widget.onTopicSelected(_selectedTopic);
                  });
                }
              : null,
          validator: (value) => _selectedSubject != null && value == null ? 'Please select a topic' : null,
        ),
      ],
    );
  }
}