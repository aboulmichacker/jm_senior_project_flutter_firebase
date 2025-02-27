import 'package:flutter/material.dart';
import 'package:jm_senior/auth/auth_service.dart';
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
          int studySessionDuration = userData.studySessionDuration;
          int breakDuration = userData.breakDuration;

          void selectStudyStartTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(userData.studyStartTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  userData.studyStartTime = TimeStringConversion().timeOfDayToString(value);
                });
              }
            });
          }

          void selectStudyEndTime(BuildContext context) {
            showTimePicker(
              context: context,
              initialTime: TimeStringConversion().stringToTimeOfDay(userData.studyEndTime),
            ).then((value) {
              if (value != null) {
                setState(() {
                  userData.studyEndTime = TimeStringConversion().timeOfDayToString(value);
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
                        userData.studySessionDuration = studySessionDuration;
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
                        userData.breakDuration = breakDuration;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'At what time do you start studying?',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectStudyStartTime(context),
                    controller: TextEditingController(
                      text: userData.studyStartTime,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'At what time do you finish studying?',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => selectStudyEndTime(context),
                    controller: TextEditingController(
                      text: userData.studyEndTime,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async{
                        await FirestoreService().savePreferences(userData);
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
                        textStyle: const TextStyle(fontSize: 18),
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