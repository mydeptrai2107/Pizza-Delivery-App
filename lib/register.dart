// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/core/color_app.dart';

// StatefulWidget to create a register page with form functionality
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// State class for RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Key to uniquely identify the Form
  String _name = ''; // Store user name
  String _email = ''; // Store user email
  String _password = ''; // Store user password
  String _mobileNumber = ''; // Store user mobile number
  String _address = ''; // Store user address
  String _selectedImage = 'dp_3.png'; // Default profile image
  final List<String> _imageOptions = [
    // List of available profile images
    'dp_1.png',
    'dp_2.png',
    'dp_3.png',
    'dp_4.png',
    'dp_5.png',
    'dp_6.png'
  ];
  int _currentImageIndex = 0;
  final String _userType = 'user';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildProfileImageSelector(),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên của bạn';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
                onSaved: (value) => _mobileNumber = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      foregroundColor: Colors.white),
                  child: const Text('Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the profile image selector
  Widget _buildProfileImageSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _currentImageIndex =
                  (_currentImageIndex + 1) % _imageOptions.length;
              _selectedImage = _imageOptions[_currentImageIndex];
            });
          },
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/profile_pic/$_selectedImage'),
            radius: 100,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nhấn để đổi ảnh đại diện',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if form is valid
      _formKey.currentState!.save(); // Save form values
      try {
        // Create user with email and password using Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Hash the password before storing it
        String hashedPassword = _hashPassword(_password);

        // Save additional user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'userEmail': _email,
          'hashedPassword': hashedPassword,
          'mobile': _mobileNumber,
          'address': _address,
          'profileImage': _selectedImage,
          'userType': _userType, // Save user type
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký tài khoảng thành công!')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.message}')),
        );
      }
    }
  }

  // Method to hash the password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode password to bytes
    var digest = sha256.convert(bytes); // Compute SHA-256 hash
    return digest.toString(); // Return hash as string
  }
}
