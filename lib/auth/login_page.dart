import 'package:flutter/material.dart';
import 'package:jm_senior/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleScreen;
  const LoginPage({super.key, required this.onToggleScreen});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false; 
  bool _buttonEnabled = true;
  
  Future<void> _login()async{
    try{
      if(_formKey.currentState!.validate()){
        setState(() {
          _isLoading = true;
          _buttonEnabled = false;
        });
        await AuthService().signin(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            context: context
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        )
      );
      setState(() {
        _isLoading = false;
        _buttonEnabled = true;
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key:_formKey,
        child: SingleChildScrollView(
          child: Container(         
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('images/classroom_bg.jpeg'), 
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.green.withValues(alpha: 0.75), // Adjust opacity as needed
                BlendMode.srcATop,  // Very good for tinting
              ),
            ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: const Center(
                    child: Text(
                    "First in Class",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: "Cabin Sketch",
                      fontWeight: FontWeight.bold
                    ),
                  ),),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    )
                  ),
                  child: Column(
                    children: [
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
                    const SizedBox(height: 30),
                    _isLoading 
                    ? 
                    const CircularProgressIndicator()
                    :
                    // Login button
                    ElevatedButton(
                      onPressed: _buttonEnabled ? _login : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontFamily: "Quicksand"),
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    
                    GestureDetector(
                      onTap: widget.onToggleScreen,
                      child: const Text(
                        "Don't have an account? Sign Up Here",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,)
                    ],
                ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
