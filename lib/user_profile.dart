import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _name;
  String? _email;
  String? _profilePictureUrl;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch the user's name and email from AWS Amplify
  Future<void> _fetchUserData() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final nameAttr = attributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'name',
        orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.name, value: 'No Name'),
      );
      final emailAttr = attributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'email',
        orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.email, value: 'No Email'),
      );

      setState(() {
        _name = nameAttr.value;
        _email = emailAttr.value;
        _nameController.text = _name ?? '';
      });
    } catch (e) {
      debugPrint('Error fetching user attributes: $e');
    }
  }

  /// Update the user's name
  Future<void> _updateName() async {
    try {
      await Amplify.Auth.updateUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.name,
        value: _nameController.text,
      );
      setState(() {
        _name = _nameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating name: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update name')),
      );
    }
  }

  /// Show the edit profile slide-up window
  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
                const SizedBox(height: 16),
                Center(
                child: Stack(
                  children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profilePictureUrl != null
                      ? NetworkImage(_profilePictureUrl!)
                      : null,
                    child: _profilePictureUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                    ),
                  ),
                  ],
                ),
                ),
              const SizedBox(height: 16),
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateName();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Show a logout bottom sheet
  void _showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await Amplify.Auth.signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      } catch (e) {
                        debugPrint('Error logging out: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to log out')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Profile Section
            Center(
              child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profilePictureUrl != null
            ? NetworkImage(_profilePictureUrl!)
            : null,
              child: _profilePictureUrl == null
            ? const Icon(Icons.person, size: 50, color: Colors.grey)
            : null,
            ),
            const SizedBox(height: 16),
            Text(
              _name ?? 'No Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _email ?? 'No Email',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
              ),
            ),
            const SizedBox(height: 20),

            // Wallet and Orders Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
          Column(
            children: [
              Text('\$140.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Wallet', style: TextStyle(color: Colors.grey)),
            ],
          ),
          Column(
            children: [
              Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Orders', style: TextStyle(color: Colors.grey)),
            ],
          ),
              ],
            ),
            const Divider(height: 40),

            // List Items
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Your Favorites'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Tell Your Friend'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Promotions'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            const Divider(height: 40),

            // Logout Button
            ListTile(
              leading: const Icon(Icons.power_settings_new, color: Colors.red),
              title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _showLogoutBottomSheet,
            ),
          ],
        ),
      ),
    );
  }
}
