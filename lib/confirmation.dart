// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final String email;
  final String password;

  const ConfirmationScreen({super.key, required this.email, required this.password});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final AmplifyService _amplifyService = AmplifyService();
  String? _errorMessage;
  bool _isResendingCode = false; // Flag to indicate if the code is being resent
  String? _successMessage; // For showing success message after resending

  /// Combine all controllers' text to create the final code
  String getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  /// Confirm the user's sign-up and automatically log them in.
  Future<void> confirmSignUp() async {
    final code = getCode();

    if (code.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete confirmation code.';
      });
      return;
    }

    try {
      // Confirm sign-up and automatically log the user in
      await _amplifyService.confirmSignUpAndRedirect(
        context,
        widget.email,
        code,
        widget.password,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Confirmation failed: ${e.toString()}';
      });
    }
  }

  /// Resend a new verification code to the user
  Future<void> resendCode() async {
    setState(() {
      _isResendingCode = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _amplifyService.resendConfirmationCode(widget.email);
      setState(() {
        _successMessage = 'A new confirmation code has been sent to ${widget.email}';
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
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard on tap
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
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus(); // Move to the next field
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus(); // Move to the previous field
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
                    onTap: _isResendingCode ? null : resendCode, // Disable while resending
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
