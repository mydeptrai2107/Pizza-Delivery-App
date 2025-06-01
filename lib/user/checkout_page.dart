import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/core/dialog.dart';
import 'package:pizza_delivery_app/core/formatter.dart';
import 'package:pizza_delivery_app/user/checkout_success_page.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0;

  String paymentMethod = 'cash'; // 'cash' hoặc 'stripe'

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCartItems();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = userDoc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['mobile'] ?? '';
        _addressController.text = data['address'] ?? '';
      });
    }
  }

  Future<void> _loadCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    double total = 0;

    final items = snapshot.docs.map((doc) {
      final data = doc.data();
      total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
      return data;
    }).toList();

    setState(() {
      cartItems = items;
      totalPrice = total;
    });
  }

  Future<void> _submitOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email,
        'name': _nameController.text,
        'mobile': _phoneController.text,
        'address': _addressController.text,
        'items': cartItems,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Đang xử lý',
      });

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final cartDocs = await cartRef.get();
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutSuccesspage(),
        ),
      );
    } catch (e) {
      showDialogFail(context, 'Đặt hàng thất bại. Vui lòng thử lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh Toán'),
      ),
      body: cartItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Thông tin giao hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_nameController, 'Họ và tên'),
                  _buildTextField(_phoneController, 'Số điện thoại'),
                  _buildTextField(_addressController, 'Địa chỉ'),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: 'cash',
                    groupValue: paymentMethod,
                    title: Row(
                      children: [
                        Image.asset(
                          "assets/cash.png",
                          width: 25,
                          height: 25,
                        ),
                        Text('   Thanh toán tiền mặt'),
                      ],
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: 'stripe',
                    groupValue: paymentMethod,
                    title: Row(
                      children: [
                        Image.asset(
                          "assets/zalo.png",
                          width: 25,
                          height: 25,
                        ),
                        Text('   Thanh toán qua Stripe'),
                      ],
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Divider(),
                  Text('Đơn hàng của bạn',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...cartItems.map((item) => _buildCartItem(item)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng tiền:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Formatter.formatCurrency(totalPrice),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      makePayment(context, totalPrice.toInt().toString());
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text('Xác nhận thanh toán'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> makePayment(BuildContext context, String price) async {
    if (paymentMethod == "cash") {
      _submitOrder(context);
      return;
    }
    try {
      await initPaymentSheet(context, price);
    } catch (err) {
      if (!context.mounted) return;
      showDialogFail(context, err.toString());
    }
  }

  Future<void> initPaymentSheet(BuildContext context, String price) async {
    try {
      final data = await createPaymentIntent(price, 'vnd');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Prospects',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet().then(
        (value) async {
          if (!context.mounted) return;
          await _submitOrder(context);
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showDialogFail(context, e.toString());
      rethrow;
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51OIMAyHdpKm7MB8qBrZGoxMpc6vV5DLsNr37XUCn0kAOgZ9S2UeEOFAvj0QjvyjWSEyZCCkjw1J39OtU11vnKnra00L0jED0P7',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.network(item['imageUrl'],
            width: 50, height: 50, fit: BoxFit.cover),
        title: Text(item['pizzaName'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Size: ${item['selectedSize']}, SL: ${item['quantity']}'),
        trailing: Text(
            '${(item['price'] * item['quantity']).toStringAsFixed(0)} đ',
            style: TextStyle(color: Colors.orange)),
      ),
    );
  }
}
