import 'package:flutter/material.dart';
import 'package:jm_senior/auth/auth_service.dart';
import 'package:jm_senior/models/study_preferences_model.dart';
import 'package:jm_senior/models/user_model.dart';
import 'package:jm_senior/services/firestore_service.dart';
import 'package:jm_senior/services/time_string_conversion.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late Future<UserModel?> _userData;
  bool _userDataFetched = false;


  Future<UserModel?> _fetchUserData() async{
    return await FirestoreService().fetchCurrentUser();
  }

  Future<void>_fetchUserDataIfNeeded() async{
    if(!_userDataFetched){
      _userData = _fetchUserData();
      _userDataFetched = true;
    }
  }

  @override
  void initState(){
    super.initState();
    _fetchUserDataIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<UserModel?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {

          UserModel userData = snapshot.data!;
          StudyPreferences studyPreferences = userData.studyPreferences;
          int studySessionDuration = studyPreferences.studySessionDuration;
          int breakDuration = studyPreferences.breakDuration;

          void selectStudyStartTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(studyPreferences.studyStartTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  studyPreferences.studyStartTime = TimeStringConversion().timeOfDayToString(value);
                });
              }
            });
          }
          void selectStudyEndTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(studyPreferences.studyEndTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  studyPreferences.studyEndTime = TimeStringConversion().timeOfDayToString(value);
                });
              }
            });
          }

          void selectWeekendStartTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(studyPreferences.weekendStartTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  studyPreferences.weekendStartTime = TimeStringConversion().timeOfDayToString(value);
                });
              }
            });
          }

          void selectWeekendEndTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(studyPreferences.weekendEndTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  studyPreferences.weekendEndTime = TimeStringConversion().timeOfDayToString(value);
                });
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("${userData.username}'s preferences", style: const TextStyle(fontWeight: FontWeight.bold),),
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Study Session Duration: $studySessionDuration minutes'),
                  Slider(
                    value: studySessionDuration.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 22,
                    onChanged: (value) {
                      setState(() {
                        studySessionDuration = value.toInt();
                        studyPreferences.studySessionDuration = studySessionDuration;
                      });
                    },
                  ),
                  Text('Break Duration: $breakDuration minutes'),
                  Slider(
                    value: breakDuration.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (value) {
                      setState(() {
                        breakDuration = value.toInt();
                        studyPreferences.breakDuration = breakDuration;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('At what time do you start studying?'),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Weekdays',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectStudyStartTime(context),
                    controller: TextEditingController(
                      text: studyPreferences.studyStartTime,
                    ),
                  ),
                     TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Weekends',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectWeekendStartTime(context),
                    controller: TextEditingController(
                      text: studyPreferences.weekendStartTime,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('At what time do you finish studying?'),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Weekdays',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectStudyEndTime(context),
                    controller: TextEditingController(
                      text: studyPreferences.studyEndTime,
                    ),
                  ),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Weekends',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectWeekendEndTime(context),
                    controller: TextEditingController(
                      text: studyPreferences.weekendEndTime,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async{
                        await FirestoreService().savePreferences(userData.id, studyPreferences);
                        ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Settings saved successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Text('Save Study Preferences'),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService().signout();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontFamily: "Quicksand"),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],),
              ),
            ),
          );
        }else{
          return const Text("No user data");
        }
      }
      ),
    );
  }
}