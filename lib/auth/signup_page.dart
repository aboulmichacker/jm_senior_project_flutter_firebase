import 'package:flutter/material.dart';
import 'package:jm_senior/auth/auth_service.dart';
class SignupPage extends StatefulWidget {
  final VoidCallback onToggleScreen;
  const SignupPage({super.key, required this.onToggleScreen});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false; 
  bool _buttonEnabled = true;

  Future<void> _signUp() async{
    try{
      if(_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
          _buttonEnabled = false;
        });
        await AuthService().signup(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        )
      );
    }finally{
      setState(() {
          _isLoading = false;
          _buttonEnabled = true;
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key:_formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const SizedBox(height: 20,),
                      const Text('Sign Up',
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                    const SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _usernameController,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please enter a Username.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                          controller: _emailController,
                          validator: (value){
                            if(value == null || value.isEmpty){
                            return 'Please enter an email.';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _passwordController,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please enter a password.';
                          }
                          return null;
                        }
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _confirmedPasswordController,
                        validator: (value){
                          if(value != _passwordController.text){
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      _isLoading 
                      ?
                      const CircularProgressIndicator()
                      :
                      // Sign Up button
                      ElevatedButton(
                        onPressed: _buttonEnabled ? _signUp: null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(fontSize: 18,fontFamily: "Quicksand"),
                        ),
                        child: const Text('Sign Up'),
                      ),
                      const SizedBox(height: 20),
                      // Login link
                      GestureDetector(
                        onTap: widget.onToggleScreen,
                        child: const Text(
                          "Already Have an Account? Login Here",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        )
    );
  }
}
