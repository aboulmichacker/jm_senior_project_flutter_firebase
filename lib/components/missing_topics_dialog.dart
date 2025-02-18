import 'package:flutter/material.dart';

class MissingTopicsDialog extends StatelessWidget {
  final List<String> missingTopics;
  const MissingTopicsDialog({super.key, required this.missingTopics});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Let us know more about you!", style: TextStyle(fontWeight: FontWeight.bold),),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("In order to get a nice and complete study schedule, make sure to solve these topics in the quiz me page!"),
          const SizedBox(height: 10,),
          for(var topic in missingTopics)
          Text("-$topic", style: const TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(height: 10,),
          const Text("Based on your quiz results, a study schedule for this exam will be generated!")
        ],
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, 
        child: const Text("Got It!")
      )
      ],
    );
  }
}