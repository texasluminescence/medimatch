// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class FirstTimeLogin extends StatefulWidget {
  const FirstTimeLogin({super.key});

  @override
  State<FirstTimeLogin> createState() => _FirstTimeLoginState();
}

class _FirstTimeLoginState extends State<FirstTimeLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(painter: DiagonalBackgroundPainter())),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome to",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF365463),
                      height: 1.5,
                    ),
                  ),
                  const Text(
                    "MEDIMATCH",
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF365463),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Image.asset(
                    'lib/assets/medimatch-logo.png',
                    height: 250,
                    width: 250,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSetupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 52, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Customize Your Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF365463), // Increased font size
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintMint = Paint()
      ..color = const Color(0xFF00FBB0) // Mint color
      ..style = PaintingStyle.fill;

    final paintBlue = Paint()
      ..color = const Color(0xFFDDE9F1) // Blue color
      ..style = PaintingStyle.fill;

    final pathMint = Path();
    pathMint.moveTo(0, size.height * 0.8);
    pathMint.lineTo(size.width, size.height * 0.4);
    pathMint.lineTo(size.width, 0);
    pathMint.lineTo(0, 0);
    pathMint.close();

    final pathBlue = Path();
    pathBlue.moveTo(0, size.height);
    pathBlue.lineTo(size.width, size.height);
    pathBlue.lineTo(size.width, size.height * 0.4);
    pathBlue.lineTo(0, size.height * 0.8);
    pathBlue.close();

    canvas.drawPath(pathMint, paintMint);
    canvas.drawPath(pathBlue, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  void moveToNextField(
      {required TextEditingController controller,
      required FocusNode nextFocus,
      int maxLength = 2}) {
    if (controller.text.length == maxLength) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  final FocusNode monthFocus = FocusNode();
  final FocusNode dayFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE9F1),
      body: Column(
        children: [
          // Title section (Mint Background)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FBB0), // Mint color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "MEDIMATCH",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF365463),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Form section inside a white container
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preferred Name section
                      const Text(
                        "Preferred Name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your preferred name",
                          filled: true,
                          fillColor: const Color(0xFFF0F0F0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth section
                      const Text(
                        "Date of Birth",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: monthController,
                              focusNode: monthFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              onChanged: (_) => moveToNextField(
                                  controller: monthController,
                                  nextFocus: dayFocus),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "MM",
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: dayController,
                              focusNode: dayFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              onChanged: (_) => moveToNextField(
                                  controller: dayController,
                                  nextFocus: yearFocus),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "DD",
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: yearController,
                              focusNode: yearFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "YYYY",
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Height & Weight
                      const Text("Height & Weight"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'))
                              ],
                              decoration: InputDecoration(
                                hintText: "Height (in)",
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                suffixText: "in",
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'))
                              ],
                              decoration: InputDecoration(
                                hintText: "Weight (lbs)",
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                suffixText: "lbs",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pre-Existing Conditions
                      const Text("Pre-Existing Conditions"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField(
                        items: const [
                          DropdownMenuItem(value: "None", child: Text("None")),
                          DropdownMenuItem(
                              value: "Diabetes", child: Text("Diabetes")),
                          DropdownMenuItem(
                              value: "Hypertension",
                              child: Text("Hypertension")),
                        ],
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Conditions section
                      const SizedBox(height: 8),
                      const Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            Chip(label: Text("Diabetes")),
                            Chip(label: Text("Hypertension")),
                            Chip(label: Text("Condition X")),
                            Chip(label: Text("Condition Y")),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Save Changes Button (Closer to the White Block)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: SizedBox(
              width: double.infinity,
                child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(
                        title: 'Home',
                      )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FBB0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF365463),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
