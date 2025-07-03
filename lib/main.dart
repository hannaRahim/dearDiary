import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart'; // Import your new AuthScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project URL and Anon Key
  await Supabase.initialize(
    url: 'https://ogqtxedbcdvedzzffhvt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ncXR4ZWRiY2R2ZWR6emZmaHZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NjM5NDMsImV4cCI6MjA2NzAzOTk0M30.ZfI4QlQC62z6CQP-pNsO1yWx8K66y6AAxBLd7iB_4PA',
  );

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Supabase connected!'),
      ),
    ),
  ));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen for authentication state changes and redirect the user accordingly.
    // This ensures that if a user signs in or out, they are navigated to the correct screen.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // User signed in, navigate to Home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out, navigate to AuthScreen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DearDiary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Determine the initial screen based on whether a user is currently logged in.
      // If there's an active Supabase session, go to HomeScreen; otherwise, go to AuthScreen.
      home: Supabase.instance.client.auth.currentUser == null
          ? const AuthScreen()
          : const HomeScreen(),
    );
  }
}
