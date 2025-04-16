import 'package:flutter/material.dart';
import 'package:medimatch/mongo_db_connection.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  DateTime? selectedDate;
  int selectedFeet = 5;
  int selectedInches = 9;
  int? weight;
  // Needed to load weight from MongoDB when user opens page
  final TextEditingController weightController = TextEditingController();
  List<String> selectedConditions = [];

  // Hardcoded for now
  final String userEmail = "joseph.angel349@gmail.com";

  bool isLoading = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void removeCondition(String condition) {
    setState(() { 
      selectedConditions.remove(condition);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await getUserProfile(userEmail);
    if (userData != null) {
      setState(() {
        // Parse DOB
        if (userData['dob'] != null) {
          selectedDate = DateTime.tryParse(userData['dob']);
        }

        // Parse height
        if (userData['feet'] != null) {
          selectedFeet = userData['feet'];
        }

        if (userData['inches'] != null) {
          selectedInches = userData['inches'];
        }

        // Parse weight
        if (userData['weight'] != null) {
          weight = userData['weight'];
          weightController.text = weight.toString();
        }

        // Parse conditions
        if (userData['conditions'] is List) {
          selectedConditions = List<String>.from(userData['conditions']);
        }

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

      
      body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
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
                child: const Text('Joseph\'s Profile'),
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
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: selectedDate == null 
                              ? 'Select' 
                              : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                          ),
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

                                const SizedBox(height: 4),

                                Row(children: [
                                  // Feet dropdown
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: selectedFeet, 
                                      decoration: InputDecoration(
                                        labelText: 'Feet',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: List.generate(6, (index) => index + 3)
                                          .map((ft) => DropdownMenuItem(
                                                value: ft,
                                                child: Text('$ft'),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedFeet = value!;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Inches Dropdown
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: selectedInches, 
                                      decoration: InputDecoration(
                                        labelText: 'Inches',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: List.generate(12, (index) => index)
                                          .map((inch) => DropdownMenuItem(
                                                value: inch,
                                                child: Text('$inch'),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedInches = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
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

                              const SizedBox(height: 4),

                              TextFormField(
                                controller: weightController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 150',
                                  suffixText: 'lbs',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    weight = int.tryParse(value);
                                  });
                                },
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
                onPressed: () async {
                  await updateUserProfile(
                    email: userEmail,
                    dob: selectedDate,
                    feet: selectedFeet,
                    inches: selectedInches,
                    weight: weight,
                    conditions: selectedConditions,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved!')),
                  );
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
