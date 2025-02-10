import 'package:flutter/material.dart';
import 'package:jm_senior/Pages/exam_schedule_page.dart';
import 'package:jm_senior/models/api_prediciton.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:dio/dio.dart';
import 'package:jm_senior/models/study_schedule_model.dart';
import 'dart:math';

import 'package:jm_senior/services/firestore_service.dart';
class GenerateSchedule {

  Future<List<ApiPrediction>> _fetchPredictions(List<String> topics) async{
    //THIS MUST BE CONVERTED TO AN OBJECT LATER ON
    //DATA TO BE FETCHED FROM SOLVED QUIZZES
    //FOR TESTING PURPOSES ONLY.
    List<Map<String, dynamic>> quizResultsData = topics.map((topic){
        final quizTimeTaken = Random().nextInt(26) + 5; // Random quiz time taken between 5 and 30 minutes
        final accuracy = (Random().nextDouble() * 0.8 + 0.2).toStringAsFixed(1); // Random accuracy between 0.2 and 1

        return {
          "topic": topic,
          "quiz_time_taken": quizTimeTaken,
          "accuracy": accuracy, // Convert back to double
        };
    }).toList();

    print(' #####PASSED DATA: $quizResultsData');
    
    try{
      final dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 5000), // 5 seconds connection timeout
          receiveTimeout: const Duration(milliseconds: 3000), // 3 seconds receive timeout
          sendTimeout: const Duration(milliseconds: 3000), // 3 seconds send timeout
      ));
      
      final response = await dio.post(
          'http://10.0.2.2:5000/predict', 
          data: quizResultsData,
      );
      List<Map<String,dynamic>> listpredictions = List<Map<String,dynamic>>.from(response.data);
      List<ApiPrediction> predictions = listpredictions.map((prediction) => ApiPrediction.fromJSON(prediction)).toList();
      return predictions;

    } on DioException catch(e){
        String errorMessage = "An error occurred during prediction.";

        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timed out. Please check your network.";
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = "Receive timeout. Server not responding.";
        } else if (e.response != null) {
          // The request was made and the server responded with a status code
            // that falls out of the timeSlot of 2xx.
          errorMessage = "Server Error: ${e.response?.statusCode} - ${e.response?.data}";
        } else if (e.type == DioExceptionType.sendTimeout) {
          errorMessage = "Send timeout. Unable to send request.";
        } else if (e.type == DioExceptionType.unknown) {
            errorMessage = "Unknown Error. Please check your network.";
        } else {
          errorMessage = "Dio Error: ${e.message}";
        }
        throw Exception(errorMessage);
      }catch (e) { // Catch any other exceptions
        throw Exception("An unexpected error occured: ${e.toString()}");
      }
  }


  Future<List<Map<String, DateTime>>> _getAvailableTimeSlots({
    required TimeOfDay studyStartTime,
    required DateTime examDate,
    required int studyBreak
  }) async {
    
  List<Map<String, DateTime>> availableTimeSlots = [];
  DateTime dayIterator = DateTime.now().copyWith(
      hour: studyStartTime.hour,
      minute: studyStartTime.minute,
      second: 0,
      millisecond: 0
  );

  // Fetch existing schedules.
  List<StudySchedule> existingSchedules = await FirestoreService().getListAllStudySchedules();

    while (dayIterator.isBefore(examDate) || dayIterator.isAtSameMomentAs(examDate)) {
      DateTime startOfDay = dayIterator;
      DateTime endOfDay = DateTime(dayIterator.year, dayIterator.month, dayIterator.day, 23, 0);

      if (startOfDay.isBefore(endOfDay)) {
        availableTimeSlots.add({"start": startOfDay, "end": endOfDay});
      }
      dayIterator = dayIterator.add(const Duration(days: 1));
    }

    // Sort existing schedules by start time.  Crucial for efficient processing.
    existingSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Remove overlapping times from availableTimeSlots based on existingSchedules.
    for (StudySchedule schedule in existingSchedules) {
      List<Map<String, DateTime>> updatedtimeSlots = [];
      for (Map<String, DateTime> timeSlot in availableTimeSlots) {
        DateTime timeSlotStart = timeSlot["start"]!;
        DateTime timeSlotEnd = timeSlot["end"]!;

        // Case 1: Schedule is completely outside the timeSlot (before or after).
        if (schedule.endTime.isBefore(timeSlotStart) || schedule.startTime.isAfter(timeSlotEnd)) {
          updatedtimeSlots.add(timeSlot); // Keep the timeSlot as is.
        } else {
            // Case 2: Schedule overlaps with the beginning of the timeSlot
            if (schedule.startTime.isBefore(timeSlotStart) && schedule.endTime.isAfter(timeSlotStart) && schedule.endTime.isBefore(timeSlotEnd))
            {
                DateTime newtimeSlotStart = schedule.endTime.add(Duration(minutes: studyBreak));
                if(newtimeSlotStart.isBefore(timeSlotEnd)){
                     updatedtimeSlots.add({"start": newtimeSlotStart, "end": timeSlotEnd});
                }

            }
             // Case 3: Schedule overlaps with the end
            else if (schedule.startTime.isAfter(timeSlotStart) && schedule.startTime.isBefore(timeSlotEnd) && schedule.endTime.isAfter(timeSlotEnd))
            {
                timeSlotEnd = schedule.startTime;
                updatedtimeSlots.add({"start": timeSlotStart, "end": timeSlotEnd});
            }
            // Case 4: Schedule is completely within the timeSlot.
             else if (schedule.startTime.isAfter(timeSlotStart) && schedule.endTime.isBefore(timeSlotEnd)) {
                 DateTime newtimeSlotStart = schedule.endTime.add(Duration(minutes: studyBreak));

                 updatedtimeSlots.add({"start": timeSlotStart, "end": schedule.startTime});
                  if(newtimeSlotStart.isBefore(timeSlotEnd)){
                    updatedtimeSlots.add({"start": newtimeSlotStart, "end": timeSlotEnd});
                 }
            }
          // Case 5: The timeSlot is completely within the schedule
          // In this case we don't need to add anything. The timeSlot is fully covered.

        }
      }
      availableTimeSlots = updatedtimeSlots; // Use the updated timeSlots for the next iteration.
    }

  return availableTimeSlots;
}



  Future<List<StudySchedule>> _convertToStudySchedules({
    required List<ApiPrediction> predictions,
    required Exam exam,
    required TimeOfDay studyStartTime,
    required int studyBreak,
    required int sessionLength
  }) async {
    List<StudySchedule> schedules = [];
    
    DateTime examDate = exam.date.subtract(const Duration(days: 1)); //stop scheduling the day before the exam.
    
    List<Map<String,DateTime>> availableTimeSlots = await _getAvailableTimeSlots(
      studyStartTime: studyStartTime, 
      examDate: examDate, 
      studyBreak: studyBreak
    );

    for(var prediction in predictions){
      int totalMinutes = (prediction.studyDuration * 60).toInt();


      while(totalMinutes > 0 && availableTimeSlots.isNotEmpty){

        // Select a random timeSlot.
        int timeSlotIndex = Random().nextInt(availableTimeSlots.length);
        Map<String, DateTime> selectedtimeSlot = availableTimeSlots[timeSlotIndex];
        DateTime timeSlotStart = selectedtimeSlot["start"]!;
        DateTime timeSlotEnd = selectedtimeSlot["end"]!;

        
        // Calculate the required duration for the session + break.
        // Determine session minutes 
        int sessionMinutes;
        if (totalMinutes >= sessionLength) {
          sessionMinutes = sessionLength; // Full session if enough time.
        } else if (totalMinutes >= sessionLength / 2) {
          sessionMinutes = sessionLength;  // Full session if more than half.
        } else {
          // Discard remaining minutes (less than half a session).
          totalMinutes = 0; // Exit the while loop for this prediction.
          break;
        }

        int totalRequiredMinutes = sessionMinutes;
        if (totalMinutes > sessionMinutes ) { //Only add break if it's not the last session
            totalRequiredMinutes += studyBreak;
        }
        // Check if the timeSlot can accommodate the session.
        if (timeSlotEnd.difference(timeSlotStart).inMinutes >= totalRequiredMinutes) {
        // Place the session at the beginning of the timeSlot.
          DateTime selectedStartTime = timeSlotStart;
          DateTime sessionEndTime = selectedStartTime.add(Duration(minutes: sessionMinutes));

          // Create the schedule.
          schedules.add(StudySchedule(
            examId: exam.id!,
            startTime: selectedStartTime,
            endTime: sessionEndTime,
            topic: prediction.topic,
          ));

          // Update totalMinutes.
          totalMinutes -= sessionMinutes;

          // Update the timeSlot.
          DateTime newtimeSlotStart = sessionEndTime.add(Duration(minutes: studyBreak));
        
          if(newtimeSlotStart.isBefore(timeSlotEnd)){
              selectedtimeSlot["start"] = newtimeSlotStart;
          } else {
              availableTimeSlots.removeAt(timeSlotIndex); // Remove if the updated start exceeds the end
          }
        } else {
          // timeSlot is too small, remove it.
          availableTimeSlots.removeAt(timeSlotIndex);
        }           
      }
    }
    return schedules;
  }

  Future<void> generateSchedule(Exam exam, BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center( 
          child: CircularProgressIndicator(),
        );
      },
    );
    try{
      final predictions = await _fetchPredictions(exam.topics);
      final schedules = await _convertToStudySchedules(
        predictions: predictions,
        exam: exam, 
        studyStartTime: const TimeOfDay(hour: 15, minute: 0,),
        studyBreak: 30,
        sessionLength: 45
      );
      await FirestoreService().addStudySchedules(schedules);
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Schedule(exam: exam,)));
    }catch(e){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        )
      );
    }
 
  }
}