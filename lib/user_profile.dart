import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Need potential state variables
  List<String> selectedConditions = ["Condition 1", "Condition 2", "Condition 3", "Condition 4"];

  void removeCondition(String condition) {
    setState(() {
      selectedConditions.remove(condition);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(222, 234, 241, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 251, 179, 1),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, color: Color.fromRGBO(54, 75, 96, 1), size: 32),
            SizedBox(width: 32),
            Text(
              'MEDIMATCH', 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(54, 75, 96, 1),
              )
            ),
          ],
        ),
      ),

      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // Form header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6)
                ),
                child: const Text('Full Name\'s Profile'),
              ),

              const SizedBox(height: 16),

              // Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // DOB Field
                    const Text(
                      'Date of Birth', 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Select',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        // Height Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                  'Height', 
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Select',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Weight Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )

                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Pre-Existing Conditons',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        suffixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Container for conditions
                    const SizedBox(height: 8),

                    // Display condition blocks
                    Wrap(
                      spacing: 8,
                      runSpacing: 8, // Ensures wrapping behavior
                      children: selectedConditions.map((condition) => 
                        ElevatedButton(
                          onPressed: () => removeCondition(condition),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FBB0), // Bright green color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded buttons
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(
                            condition,
                            style: const TextStyle(color: Color.fromRGBO(54, 75, 96, 1)),
                          ),
                        ),
                      ).toList(),
                    )

                  ],
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FBB0),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(54, 75, 96, 1)
                  )
                ),
              )
            ],
          ),
        ),
      )
    );
  }

}

// class UserProfile extends StatefulWidget {
//   const UserProfile({super.key});

//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   String? _name;
//   String? _email;
//   String? _profilePictureUrl;
//   final TextEditingController _nameController = TextEditingController();
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//     _loadProfilePicture(); // Load cached profile picture URL
//   }

//   /// Load the profile picture URL from local storage
//   Future<void> _loadProfilePicture() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedUrl = prefs.getString('profilePictureUrl');
//     if (savedUrl != null) {
//       setState(() {
//         _profilePictureUrl = savedUrl;
//       });
//     }
//   }

//   /// Save the profile picture URL to local storage
//   Future<void> _saveProfilePicture(String url) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('profilePictureUrl', url);
//   }

//   /// Fetch the user's name and email from AWS Amplify
//   Future<void> _fetchUserData() async {
//     try {
//       final attributes = await Amplify.Auth.fetchUserAttributes();
//       final nameAttr = attributes.firstWhere(
//         (attr) => attr.userAttributeKey.key == 'name',
//         orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.name, value: 'No Name'),
//       );
//       final emailAttr = attributes.firstWhere(
//         (attr) => attr.userAttributeKey.key == 'email',
//         orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.email, value: 'No Email'),
//       );

//       setState(() {
//         _name = nameAttr.value;
//         _email = emailAttr.value;
//         _nameController.text = _name ?? '';
//       });
//     } catch (e) {
//       debugPrint('Error fetching user attributes: $e');
//     }
//   }

//   /// Update the user's name
//   Future<void> _updateName() async {
//     try {
//       await Amplify.Auth.updateUserAttribute(
//         userAttributeKey: CognitoUserAttributeKey.name,
//         value: _nameController.text,
//       );
//       setState(() {
//         _name = _nameController.text;
//       });
//     } catch (e) {
//       debugPrint('Error updating name: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update name')),
//       );
//     }
//   }

//   /// Pick and upload a new profile picture
//   Future<void> _uploadProfilePicture(StateSetter modalSetState) async {
//     if (_isUploading) return;

//     setState(() {
//       _isUploading = true;
//     });

//     modalSetState(() {
//       _isUploading = true;
//     });

//     try {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile == null) {
//         setState(() {
//           _isUploading = false;
//         });
//         modalSetState(() {
//           _isUploading = false;
//         });
//         return;
//       }

//       final file = File(pickedFile.path);
//       const key = 'profile_picture.jpg';

//       // Upload the image to Amplify Storage
//       await Amplify.Storage.uploadFile(
//         local: file,
//         key: key,
//       );

//       // Fetch the new image URL
//       final url = (await Amplify.Storage.getUrl(key: key)).url;

//       setState(() {
//         _profilePictureUrl = url;
//         _isUploading = false;
//       });

//       modalSetState(() {
//         _profilePictureUrl = url;
//         _isUploading = false;
//       });

//       // Save the URL locally for persistence
//       await _saveProfilePicture(url);
//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//       modalSetState(() {
//         _isUploading = false;
//       });
//       debugPrint('Error uploading profile picture: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update profile picture')),
//       );
//     }
//   }

//   /// Show the edit profile slide-up window
//   void _showEditProfileSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to dynamically update modal UI
//           builder: (BuildContext context, StateSetter modalSetState) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Edit Profile',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Center(
//                     child: Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundImage: _profilePictureUrl != null
//                               ? NetworkImage(_profilePictureUrl!)
//                               : null,
//                           child: _profilePictureUrl == null
//                               ? const Icon(Icons.person, size: 50, color: Colors.grey)
//                               : null,
//                         ),
//                         if (_isUploading)
//                           const Positioned.fill(
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.blue,
//                                 strokeWidth: 2.0,
//                               ),
//                             ),
//                           ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () async {
//                               await _uploadProfilePicture(modalSetState);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.blue,
//                               ),
//                               child: const Icon(
//                                 Icons.edit,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       hintText: 'Enter your name',
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       _updateName();
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('Save', style: TextStyle(color: Colors.white)),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Show a logout bottom sheet
//   void _showLogoutBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return SizedBox(
//           height: 200,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'Are you sure you want to log out?',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 35),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.9,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         await Amplify.Auth.signOut();
//                         Navigator.pop(context);
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => const Login()),
//                         );
//                       } catch (e) {
//                         debugPrint('Error logging out: $e');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Failed to log out')),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Log Out',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: _showEditProfileSheet,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _profilePictureUrl != null
//                         ? NetworkImage(_profilePictureUrl!)
//                         : null,
//                     child: _profilePictureUrl == null
//                         ? const Icon(Icons.person, size: 50, color: Colors.grey)
//                         : null,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _name ?? 'No Name',
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _email ?? 'No Email',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Wallet and Orders Section
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     Text('\$140.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text('Wallet', style: TextStyle(color: Colors.grey)),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text('Orders', style: TextStyle(color: Colors.grey)),
//                   ],
//                 ),
//               ],
//             ),
//             const Divider(height: 40),

//             // List Items
//             ListTile(
//               leading: const Icon(Icons.favorite_outline),
//               title: const Text('Your Favorites'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.payment),
//               title: const Text('Payment'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.share),
//               title: const Text('Tell Your Friend'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.local_offer),
//               title: const Text('Promotions'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Settings'),
//               onTap: () {},
//             ),
//             const Divider(height: 40),

//             // Logout Button
//             ListTile(
//               leading: const Icon(Icons.power_settings_new, color: Colors.red),
//               title: const Text(
//                 'Log Out',
//                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//               ),
//               onTap: _showLogoutBottomSheet,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
