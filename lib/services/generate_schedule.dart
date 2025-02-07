import 'package:flutter/material.dart';
import 'package:jm_senior/models/api_prediciton.dart';
import 'package:jm_senior/models/exam_model.dart';
import 'package:dio/dio.dart';
import 'dart:math';
class GenerateSchedule {

  Future<List<ApiPrediction>> _fetchPredictions(List<String> topics) async{
    //THIS MUST BE CONVERTED TO AN OBJECT LATER ON
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
            // that falls out of the range of 2xx.
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
        print(e);
        throw Exception("An unexpected error occured: ${e.toString()}");
      }
  }

  Future<void> generateSchedule(Exam exam, BuildContext context) async{

    try{
      final predictions = await _fetchPredictions(exam.topics);
      print(' #####RECEIVED DATA:'); // Start printing on a new line
      for(ApiPrediction prediction in predictions) {
        print("Topic: ${prediction.topic}");
        print("Study Duration: ${prediction.studyDuration} minutes");
      };
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        )
      );
    }
 
  }
}