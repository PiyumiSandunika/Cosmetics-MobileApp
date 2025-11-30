import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'providers/cart_provider.dart'; // Import your new CartProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Wrap the app with ChangeNotifierProvider
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
      // ... (Rest of your theme code remains the same)
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primaryColor: const Color(0xFFE91E63),
        // ... keep your existing theme settings here
      ),
      home: const LoginScreen(),
    );
  }
}