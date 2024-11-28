// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'login.dart';
import 'user_profile.dart';
import 'scanner.dart';
import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      debugPrint('Error checking login status: $e');
      return false; // Explicitly return false if an error occurs
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
      home: isLoggedIn ? const MyHomePage(title: 'HomePage',) : const Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final double _opacity = 1.0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  /// Fetch the user's name from AWS Amplify
  Future<void> _fetchUserName() async {
    try {
      final userAttributes = await Amplify.Auth.fetchUserAttributes();
      final nameAttribute =
        userAttributes.firstWhere((attr) => attr.userAttributeKey.key == 'name', orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.custom('name'), value: 'User'));
      setState(() {
      _userName = nameAttribute.value.split(' ').first;
      });
    } catch (e) {
      print('Error fetching user name: $e');
      setState(() {
        _userName = 'User';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      // Navigate to the profile page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfile()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Slightly lighter off-white background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: const Color.fromARGB(255, 117, 232, 167), // Set the background color to white
            width: double.infinity, // Ensure the container takes the full width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0), // Increased vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50), // Add white space
                  Text(
                    'Hello, ${_userName ?? 'User'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Divider line between header and body
          const Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color: Colors.grey[100], // Slightly lighter off-white background
              ),
            ),
          ),
        ],
      ),
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
          backgroundColor: Colors.white.withOpacity(0.9),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
