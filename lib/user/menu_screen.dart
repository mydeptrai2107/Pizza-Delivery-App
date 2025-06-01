import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/user/widgets/image_slider.dart';
import 'package:pizza_delivery_app/user/widgets/product_grid_item.dart';
import 'package:pizza_delivery_app/user/widgets/product_horizontal_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchPizzas() async {
    QuerySnapshot querySnapshot = await firestore.collection('pizzas').get();
    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'], // Pizza name
        'price': doc['price'], // Pizza price
        'imageUrl': doc['imageUrl'], // URL of the pizza image
        'description': doc['description'], // Pizza description
        'isSpicy': doc['badge'] == 'spicy', // Spicy badge flag
        'isNonVeg': doc['badge'] == 'non-veg', // Non-Veg badge flag
      };
    }).toList();
  }

  List<String> assets = [
    'assets/images/panel_1.png',
    'assets/images/panel_2.png',
    'assets/images/panel_3.png',
    'assets/images/panel_4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageSlider(assets: assets),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  "Bạn sẽ thích",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Danh sách sẽ thay đổi theo định vị của bạn",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPizzas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading pizzas'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No pizzas available'));
                  } else {
                    final pizzas = snapshot.data!;
                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: pizzas.length,
                        itemBuilder: (context, index) {
                          return ProductHorizontalItem(pizzas[index]);
                        },
                      ),
                    );
                  }
                },
              ),
              Image.asset(
                'assets/images/panel_5.png',
                width: MediaQuery.sizeOf(context).width,
                height: 150,
                fit: BoxFit.cover,
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPizzas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading pizzas'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No pizzas available'));
                  } else {
                    final pizzas = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      itemCount: pizzas.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 2 / 3,
                      ),
                      itemBuilder: (context, index) {
                        return ProductGridItem(pizzas[index]);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
