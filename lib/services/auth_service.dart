// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../main.dart';
import '../login.dart';


class AmplifyService {
  /// Sign Up a new user
  Future<String> signUp(String email, String password, String name) async {
    try {
      final userAttributes = {
        CognitoUserAttributeKey.email: email,
        CognitoUserAttributeKey.name: name,
      };

      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: CognitoSignUpOptions(userAttributes: userAttributes),
      );

      return 'Sign-Up Successful. Please confirm your email.';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> confirmSignUpAndRedirect(
    BuildContext context, String email, String confirmationCode, String password) async {
    try {
      // Force log out any active session
      await Amplify.Auth.signOut();

      // Confirm the sign-up
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );

      // Automatically sign the user back in
      await Amplify.Auth.signIn(username: email, password: password);

      // Navigate to the Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: "Home Page")),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation failed: ${e.message}')),
      );
    }
  }

  /// Log in a user
  Future<String> login(String email, String password) async {
    try {
      await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return 'Login Successful';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // Perform sign-out with global sign-out
      await Amplify.Auth.signOut(options: const SignOutOptions(globalSignOut: true));

      // Clear the sign-in session
      await Amplify.Auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  /// Check if a user is already logged in
  Future<bool> isLoggedIn() async {
    try {
      final authSession = await Amplify.Auth.fetchAuthSession();
      return authSession.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  /// Resend the confirmation code to the user
  Future<void> resendConfirmationCode(String email) async {
  try {
    await Amplify.Auth.resendSignUpCode(username: email);
  } on AuthException catch (e) {
    throw Exception('Resend code failed: ${e.message}');
  }
}
}
