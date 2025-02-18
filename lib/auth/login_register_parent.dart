import 'package:flutter/material.dart';
import 'package:jm_senior/auth/login_page.dart';
import 'package:jm_senior/auth/signup_page.dart';

class LoginRegisterParent extends StatefulWidget {
  const LoginRegisterParent({super.key});

  @override
  State<LoginRegisterParent> createState() => _LoginRegisterParentState();
}

class _LoginRegisterParentState extends State<LoginRegisterParent> {

  bool _isLogin = true; // Control which screen to show

  void _toggleScreen() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
  @override
   Widget build(BuildContext context) {
    if(_isLogin){
      return LoginPage(onToggleScreen:_toggleScreen);
    }else{
      return SignupPage(onToggleScreen:_toggleScreen);
    }
  }
}