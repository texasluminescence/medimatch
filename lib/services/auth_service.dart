// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class MongoDBService {
  final String connectionString = dotenv.env['MONGO_DB_CONNECTION'] ?? '';
  late Db _db;
  late DbCollection _usersCollection;
  bool _isConnected = false;

  /// Connect to MongoDB
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      _db = await Db.create(connectionString);
      await _db.open();
      _usersCollection = _db.collection('users');
      _isConnected = true;
    } catch (e) {
      throw Exception('Failed to connect to MongoDB: $e');
    }
  }

  /// Ensure that MongoDB is connected before any operation
  Future<void> ensureConnected() async {
    if (!_isConnected) {
      await connect();
    }
  }

  /// Check if a user exists by email
  Future<bool> checkUserExists(String email) async {
    await ensureConnected();
    try {
      final user = await _usersCollection.findOne({'email': email});
      return user != null;
    } catch (e) {
      throw Exception('Error checking user existence: $e');
    }
  }

  /// Login a user by email and password
  Future<void> handleLogin(BuildContext context, String email, String password) async {
    await ensureConnected();
    try {
      final user = await _usersCollection.findOne({
        'email': email,
        'password': password, // Ensure passwords are hashed in production
      });

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        // Redirect to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: "Home Page"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  /// Sign up a new user
  Future<void> handleSignUp(
      BuildContext context, String name, String email, String password) async {
    await ensureConnected();
    try {
      if (await checkUserExists(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User Already Exists')),
        );
        return;
      }

      await _usersCollection.insertOne({
        'name': name,
        'email': email,
        'password': password, // Hash passwords in production
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Created Successfully')),
      );

      // Redirect to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: "Home Page"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: ${e.toString()}')),
      );
    }
  }
}
