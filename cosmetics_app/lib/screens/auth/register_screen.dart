import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final Color lightBackground = const Color(0xFFFFF0F5);
    final Color darkPink = const Color(0xFFFF82AB);

    return Scaffold(
      backgroundColor: lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 🖼️ LOCAL LOGO START ---
              Container(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/logo.png', // <--- Ensure matches your file (logo.jpg or logo.png)
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
              // --- 🖼️ LOCAL LOGO END ---

              const SizedBox(height: 12),
              const Text(
                "JOIN GLOW COSMETICS",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Create your free account now",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              const SizedBox(height: 60),

              // Email Input
              TextField(
                controller: emailCtrl,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                style: const TextStyle(fontSize: 16, color: Colors.black87),
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

              // Register Button
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
                          "REGISTER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          setState(() => isLoading = true);

                          final user = await auth.register(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );

                          if (!mounted) return;

                          setState(() => isLoading = false);

                          if (user != null) {
                            // --- ✅ YOUR UPDATED SNACKBAR CODE ---
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text( // Removed 'const' here to allow dynamic styling if needed, but 'const' is fine if style is static
                                  "Account created! Please login.",
                                  style: TextStyle(
                                    color: Colors.grey[700], // <--- GREY TEXT
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: darkPink,
                                behavior: SnackBarBehavior.floating, // Added floating for better look
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            // -------------------------------------

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Registration failed. Try again.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 109, 9, 42),
                              ),
                            );
                          }
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Color.fromARGB(255, 99, 99, 99), fontSize: 16),
                  ),
                  TextButton(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 156, 61, 89),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}