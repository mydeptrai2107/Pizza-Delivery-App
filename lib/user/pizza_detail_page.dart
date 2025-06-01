import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/core/dialog.dart';
import 'package:pizza_delivery_app/core/formatter.dart';

class PizzaDetailsPage extends StatefulWidget {
  final String pizzaName;
  final String description;
  final String imageUrl;
  final double price;

  const PizzaDetailsPage({
    super.key,
    required this.pizzaName,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  @override
  State<PizzaDetailsPage> createState() => _PizzaDetailsPageState();
}

class _PizzaDetailsPageState extends State<PizzaDetailsPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  String _selectedSize = 'M';

  // Define size constants for the pizza image
  final Map<String, double> _sizeMap = {
    'S': 200.0,
    'M': 250.0,
    'L': 300.0,
  };

  late AnimationController _animationController; // Controller for animations
  late Animation<double> _scaleAnimation; // Animation for scaling effect
  late Animation<double> _rotationAnimation; // Animation for rotation effect

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.withAlpha(051),
        title: Text(widget.pizzaName),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -150, // Adjust vertical position
            left: -50, // Adjust horizontal position
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withAlpha(051),
              ),
            ),
          ),
          // Pizza image with rotation and scaling animations
          Positioned(
            top: 16,
            left: MediaQuery.of(context).size.width / 2 -
                (_sizeMap[_selectedSize]! / 2),
            child: RotationTransition(
              turns: _rotationAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: _sizeMap[_selectedSize],
                  height: _sizeMap[_selectedSize],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content aligned to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pizza Name
                  Text(
                    widget.pizzaName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pizza Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pizza Size Selection
                  const Text(
                    'Chọn kích thước',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildSizeOption('S'),
                      _buildSizeOption('M'),
                      _buildSizeOption('L'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Số lượng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Giá',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Quantity Selector
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                color: Colors.red,
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                _quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Price Display
                          Text(
                            Formatter.formatCurrency(widget.price * _quantity),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorApp.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        addToCart(
                          context,
                          pizzaName: widget.pizzaName,
                          description: widget.description,
                          imageUrl: widget.imageUrl,
                          price: widget.price,
                          quantity: _quantity,
                          selectedSize: _selectedSize,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.primary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                          foregroundColor: Colors.white),
                      child: const Text('Thêm vào giỏ hàng'),
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

  Future<void> addToCart(
    BuildContext context, {
    required String pizzaName,
    required String description,
    required String imageUrl,
    required double price,
    required int quantity,
    required String selectedSize,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final userId = user.uid;

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      final existingItem = await cartRef
          .where('pizzaName', isEqualTo: pizzaName)
          .where('description', isEqualTo: description)
          .limit(1)
          .get();

      if (existingItem.docs.isNotEmpty) {
        final docId = existingItem.docs.first.id;
        final currentQuantity = existingItem.docs.first['quantity'] ?? 1;

        await cartRef.doc(docId).update({
          'quantity': currentQuantity + quantity,
        });

        if (!context.mounted) return;
        showDialogSuccess(context, 'Đã cập nhật số lượng trong giỏ hàng 🛒');
      } else {
        await cartRef.add({
          'pizzaName': pizzaName,
          'description': description,
          'imageUrl': imageUrl,
          'price': price,
          'quantity': quantity,
          'selectedSize': selectedSize,
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (!context.mounted) return;
        showDialogSuccess(context, 'Thêm vào giỏ hàng thành công 🛒');
      }
    } on FirebaseException catch (e) {
      showDialogFail(context, e.message ?? '');
    }
  }

  Widget _buildSizeOption(String size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size;

          _scaleAnimation = Tween<double>(
            begin: _scaleAnimation.value,
            end: _sizeMap[size]! / _sizeMap[_selectedSize]!,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

          _rotationAnimation = Tween<double>(
            begin: _rotationAnimation.value,
            end: _rotationAnimation.value + 0.06,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

          _animationController.forward(from: 0.0);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _selectedSize == size ? ColorApp.primary : Colors.grey[200],
        ),
        child: Text(
          size,
          style: TextStyle(
            fontSize: 16,
            color: _selectedSize == size ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
