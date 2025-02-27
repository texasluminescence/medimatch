// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_profile.dart' as medimatch;
import 'amplifyconfiguration.dart';
import 'scanner.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Sign-In
  await _googleSignIn.signInSilently();

  // Configure Amplify
  try {
    final authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugins([authPlugin]);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Error configuring Amplify: $e');
  }

  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  Future<bool> _checkLoginStatus() async {
    try {
      final authSession = await Amplify.Auth.fetchAuthSession();
      return authSession.isSignedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false; // Return false explicitly if an error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          // Ensure we pass a non-null value for isLoggedIn
          final isLoggedIn = snapshot.data ?? false;
          return MyApp(isLoggedIn: isLoggedIn);
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediMatch',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? const MyHomePage(title: 'Home Page') : const Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Dashboard Code
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Section
            WelcomeSection(userName: "User"), // Replace with dynamic username

            SizedBox(height: 24),

            // Symptoms Input Section
            SymptomsInputSection(),
          ],
        ),
      ),
    );
  }
}

// Welcome Message in Dashboard
class WelcomeSection extends StatelessWidget {
  final String userName;

  const WelcomeSection({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            image: const DecorationImage(
              image:
                  AssetImage("lib/assets/doctor.jpg"), // Add your image to assets
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            "Welcome $userName, what brings you in today?",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Symptom Input in Dashboard
class SymptomsInputSection extends StatelessWidget {
  const SymptomsInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: "Message Dr. MediMatch",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Handle user input submission
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  // Default to "Home" tab
  double _opacity = 1.0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      // Navigate to the profile page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const medimatch.UserProfile()),
      ).then((_) {
        setState(() {
          _selectedIndex = 1; // Reset to Home tab
        });
      });
    } else if (index == 4) {
      // Show settings modal
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return SizedBox(
            height: 200,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          );
        },
      );
    } else if (index == 2) {
      // Navigate to the scanner
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Scanner()),
      ).then((_) {
        setState(() {
          _selectedIndex = 1; // Reset to Home tab
        });
      });
    }
  }

  // unused for now but once we have content it will be used to make navbar transparent
  // ignore: unused_element
  void _onScroll(double offset) {
    // Adjust opacity based on scroll offset
    setState(() {
      _opacity = (1 - offset / 200).clamp(0.5, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          Center(child: Text("Search Page")),
          Dashboard(),
          Center(child: Text("Scan Page")),
          Center(child: Text("Profile Placeholder")),
          Center(child: Text("Settings Placehold")),
        ],
      ),
      //
      bottomNavigationBar: Opacity(
        opacity: _opacity,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          // ignore: deprecated_member_use
          backgroundColor: Colors.white.withOpacity(0.9),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}