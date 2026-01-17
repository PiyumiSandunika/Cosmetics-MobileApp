import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Imports for your screens and services
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/cart_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- UPLOAD SECTION ---
  print("ATTEMPTING TO UPLOAD PRODUCTS..."); // Look for this in console
  try {
    await DatabaseService().addDummyData();
    print("UPLOAD FUNCTION FINISHED"); // Look for this in console
  } catch (e) {
    print("UPLOAD FAILED: $e");
  }
  // ----------------------

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glow Cosmetics',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFE91E63),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      // Check if user is logged in
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}