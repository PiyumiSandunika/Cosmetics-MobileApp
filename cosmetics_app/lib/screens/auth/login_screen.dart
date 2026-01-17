import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Light theme colors with pink accents
    final Color lightBackground = const Color(0xFFFFF0F5); // soft pink/white
    final Color lightPink = const Color(0xFFFFC1E3);       // light pink accents
    final Color darkPink = const Color(0xFFFF82AB);        // darker pink accents

    return Scaffold(
      backgroundColor: lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                decoration: BoxDecoration(
                  color: lightPink.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(Icons.brush, size: 80, color: darkPink),
              ),
              const SizedBox(height: 12),
              const Text(
                "GLOW COSMETICS",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome back!",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 60),

              // Email Input
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  prefixIcon: Icon(Icons.email_outlined, color: darkPink),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkPink, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  prefixIcon: Icon(Icons.lock_outline, color: darkPink),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkPink, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: darkPink))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          setState(() => isLoading = true);

                          final user = await auth.login(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );

                          setState(() => isLoading = false);

                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Invalid email or password",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
                                ),
                                backgroundColor: const Color.fromARGB(255, 109, 9, 42), 
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3), 
                              ),
                            );
                          }
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 156, 61, 89),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}