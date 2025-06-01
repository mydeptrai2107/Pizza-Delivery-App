import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummaryPage extends StatelessWidget {
  final String pizzaName;
  final String description;
  final String imageUrl;
  final double price;
  final int quantity;
  final String selectedSize;
  final String userEmail;

  const OrderSummaryPage({
    super.key,
    required this.pizzaName,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.selectedSize,
    required this.userEmail,
  });

  // Private method to save the order to Firebase Firestore
  Future<void> _saveOrder(BuildContext context) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final String orderId = _generateRandomOrderId();

    final double totalPrice = price * quantity;

    try {
      await db.collection('orders').doc(orderId).set({
        'pizzaName': pizzaName,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'totalPrice': totalPrice,
        'status': 'Awaiting Payment',
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': userEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error placing order. Please try again.'),
        ),
      );
    }
  }

  // Private helper method to generate a random 5-digit order ID
  String _generateRandomOrderId() {
    final Random random = Random();
    final int randomNumber = 10000 + random.nextInt(90000);
    return randomNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan đơn hàng'), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover, 
              ),
            ),
            const SizedBox(height: 16), 
            Text(
              pizzaName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8), // Add vertical spacing
            // Display the pizza description in grey text
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Display the selected pizza size
            Text(
              'Size: $selectedSize',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            // Display the quantity of pizzas ordered
            Text(
              'Quantity: $quantity',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Display the total price in bold orange text
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Button to confirm the order, centered on the screen
            Center(
              child: ElevatedButton(
                onPressed: () => _saveOrder(
                    context), // Call the _saveOrder method when pressed
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Set button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  textStyle: const TextStyle(fontSize: 18), // Set text style
                  foregroundColor: Colors.white, // Set text color
                ),
                child: const Text('Confirm Order'), // Button text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
