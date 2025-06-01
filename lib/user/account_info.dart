import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/login.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<DocumentSnapshot> _userData;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userData = _firestore.collection('users').doc(userId).get();
    } else {
      _userData = Future.value();
    }
  }

  // Method to handle user logout
  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found.'));
          }

          // Extract user data from the snapshot
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No name';
          final email = data['userEmail'] ?? 'No email';
          final mobile = data['mobile'] ?? 'No mobile number';
          final address = data['address'] ?? 'No address';
          final profileImage = data['profileImage'] ?? 'dp_3.png';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/profile_pic/$profileImage',
                    ),
                    radius: 100,
                  ),
                ),
                const SizedBox(height: 20),
                RowItem('Name:  ', name),
                RowItem('Email:  ', email),
                RowItem('Mobile Number:  ', mobile),
                RowItem('Địa chỉ:  ', address),
                const SizedBox(height: 20),
                SizedBox(
                  height: 45,
                  width: MediaQuery.sizeOf(context).width,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Đăng xuất'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  const RowItem(this.title, this.value, {super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}
