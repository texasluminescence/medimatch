// ignore_for_file: use_build_context_synchronously

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'dart:async';
import 'customize.dart';
// import 'main.dart';
import 'login.dart';

class ConfirmationScreen extends StatefulWidget {
  final String email;
  final String password;

  const ConfirmationScreen(
      {super.key, required this.email, required this.password});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final AmplifyService _amplifyService = AmplifyService();
  String? _errorMessage;
  bool _isResendingCode = false;
  String? _successMessage;
  int _resendCooldown = 30;
  Timer? _cooldownTimer;

  String getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> confirmSignUp() async {
    final code = getCode();
    if (code.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete confirmation code.';
      });
      return;
    }

    try {
      await _amplifyService.confirmSignUpAndRedirect(
        context,
        widget.email,
        code,
        widget.password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstTimeLogin()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Confirmation failed: ${e.toString()}';
      });
    }
  }

  void startCooldownTimer() {
    _cooldownTimer?.cancel();
    _resendCooldown = 30;
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            timer.cancel();
          }
        });
      },
    );
  }

  Future<void> resendCode() async {
    setState(() {
      _isResendingCode = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _amplifyService.resendConfirmationCode(widget.email);
      startCooldownTimer();
      setState(() {
        _successMessage =
            'A new confirmation code has been sent to ${widget.email}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend confirmation code: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResendingCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss the keyboard on tap
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/otp_verification.png',
                    height: 250,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the verification code sent to ${widget.email}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      // Verification code input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _controllers[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context)
                                      .nextFocus(); // Move to the next field
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context)
                                      .previousFocus(); // Move to the previous field
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (_successMessage != null)
                    Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isResendingCode
                        ? null
                        : resendCode, // Disable while resending
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        _isResendingCode
                            ? 'Resending code...'
                            : "Didn't receive the code? RESEND CODE",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: confirmSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'VERIFY & PROCEED',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// This is the confirmation page for resetting the password
// It allows the user to enter the confirmation code and new password
// For ConfirmationScreen (verification code page)
class ResetPasswordConfirmationPage extends StatefulWidget {
  final String email;

  const ResetPasswordConfirmationPage({super.key, required this.email});

  @override
  State<ResetPasswordConfirmationPage> createState() =>
      _ResetPasswordConfirmationPageState();
}

class _ResetPasswordConfirmationPageState extends State<ResetPasswordConfirmationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  String? errorMessage;
  bool _isVerifying = false;

  // Helper to read the 6-digit code from the TextFields.
  String getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  // Instead of calling confirmResetPassword here, we only check the code length,
  // then navigate to the NewPasswordPage.
  Future<void> verifyCode() async {
    final code = getCode();

    // Basic validation: ensure all 6 digits are entered
    if (code.length < 6) {
      setState(() {
        errorMessage = 'Please enter the complete verification code.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      errorMessage = null;
    });

    // Here, we simply pass the code to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NewPasswordPage(
          email: widget.email,
          confirmationCode: code,
        ),
      ),
    );

    // Stop the loading spinner (if any)
    setState(() {
      _isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00FBB0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          ),
        ),
      ),
      body: Stack(
        children: [
          const SizedBox(height: 20),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: DiagonalBackgroundPainter(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'lib/assets/medimatch-logo.png',
                height: 150,
                width: 150,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 200.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Check your email",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  "We sent a verification code to ${widget.email}. "
                  "Please enter the code below to reset your password.",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 6 TextFields for the 6-digit code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller: _controllers[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (value) {
                                // Auto-move focus to next/previous field
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        })
                            .expand((widget) => [widget, const SizedBox(width: 10)])
                            .toList()
                          ..removeLast(),
                      ),
                      const SizedBox(height: 24),
                      // Verify button
                      ElevatedButton(
                        onPressed: _isVerifying ? null : verifyCode,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color(0xFF00FBB0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isVerifying
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF365463)),
                              )
                            : const Text(
                                'Verify Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF365463),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New password entry page after code verification
class NewPasswordPage extends StatefulWidget {
  final String email;
  final String confirmationCode;

  const NewPasswordPage({super.key, required this.email, required this.confirmationCode});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> resetPassword(String confirmationCode) async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      // Reset the password directly without signing in
      await Amplify.Auth.confirmResetPassword(
        username: widget.email,
        newPassword: newPassword,
        confirmationCode: widget.confirmationCode,
      );

      // Navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      if (e is AuthException) {
        setState(() {
          errorMessage = 'Authentication error: ${e.message}';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to set new password: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00FBB0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          ),
        ),
      ),
      body: Stack(
        children: [
          const SizedBox(height: 20),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: DiagonalBackgroundPainter(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'lib/assets/medimatch-logo.png',
                height: 150,
                width: 150,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 200.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create New Password",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  "Your code has been verified. Please create a new password for ${widget.email}.",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: newPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => resetPassword(widget.confirmationCode), // Pass confirmationCode here
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color(0xFF00FBB0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF365463)),
                              )
                            : const Text(
                                'Set New Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF365463),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the DiagonalBackgroundPainter class as is
class DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintMint = Paint()
      ..color = const Color(0xFF00FBB0)
      ..style = PaintingStyle.fill;

    final paintBlue = Paint()
      ..color = const Color(0xFFDDE9F1)
      ..style = PaintingStyle.fill;

    final pathMint = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    final pathBlue = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(0, size.height * 0.8)
      ..close();

    canvas.drawPath(pathMint, paintMint);
    canvas.drawPath(pathBlue, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}