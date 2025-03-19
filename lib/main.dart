// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:medimatch/continue_diagnosis.dart';
import 'login.dart';
import 'user_profile.dart';
import 'amplifyconfiguration.dart';
import 'scanner.dart';
import 'colors.dart';
import 'mongo_db_connection.dart';

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

  // load MongoDB
  await connectToMongo();

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
      home: isLoggedIn ? const MyHomePage(title: 'MEDIMATCH') : const Login(),
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
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> _selectedSymptoms = [];

  // This callback will update the _selectedSymptoms from the child
  void _updateSymptoms(List<String> newSymptoms) {
    setState(() {
      _selectedSymptoms = newSymptoms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const WelcomeSection(userName: "User"), // Replace with dynamic username
            const SizedBox(height: 24),

            // Symptoms Input Section
           SymptomsInputSection(
              onSymptomsChanged: _updateSymptoms,
            ),
          ],
        ),
      ),

    bottomNavigationBar: Padding(
      // Continue button at the bottom 
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // ensure user inputs something
              if (_selectedSymptoms.isEmpty) {
                // show a warning message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one symptom.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // pass in symptoms to next page
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SymptomDetailsPage(
                      symptoms: _selectedSymptoms,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mintColor,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Continue Diagnosis",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
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
              image: AssetImage(
                  "lib/assets/doctor.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            "Welcome $userName, what symptoms are you feeling today?",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Symptom Input in Dashboard
class SymptomsInputSection extends StatefulWidget {
    final ValueChanged<List<String>> onSymptomsChanged;
  const SymptomsInputSection({Key? key, required this.onSymptomsChanged}) : super(key: key);
  @override
  _SymptomsInputSectionState createState() => _SymptomsInputSectionState();
}

class _SymptomsInputSectionState extends State<SymptomsInputSection> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedSymptoms = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSymptom() {
  final symptom = _controller.text.trim();
  if (symptom.isNotEmpty) {
    setState(() {
      _selectedSymptoms.add(symptom);
      _controller.clear();
    });
    widget.onSymptomsChanged(_selectedSymptoms);
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // user type symptom 
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search",
              suffixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "lib/assets/search-icon.png",
                  width: 12,
                  height: 12,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Displayed symptoms
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSymptoms.map((symptom) {
                return Chip(
                  backgroundColor: AppColors.mintColor,
                  label: Text(symptom),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedSymptoms.remove(symptom);
                    });
                    widget.onSymptomsChanged(_selectedSymptoms);
                  },
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // adds symptom user typed to list
              _addSymptom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mintColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Add Symptom",
              style: TextStyle(color: Colors.black, fontSize: 16),
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
        backgroundColor: AppColors.mintColor,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Mononoki',
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
        ),
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
          backgroundColor: Colors.white.withOpacity(0.9),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
