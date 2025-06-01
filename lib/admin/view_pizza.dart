import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/admin/update_pizza.dart';
import 'package:pizza_delivery_app/core/formatter.dart';

class ViewPizzaPage extends StatelessWidget {
  const ViewPizzaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pizzas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pizzas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có món pizza nào'));
          } else {
            final pizzas = snapshot.data!.docs;
            return ListView.builder(
              itemCount: pizzas.length, // Number of pizzas to display.
              itemBuilder: (context, index) {
                final pizza = pizzas[index]; // Get each pizza document.
                return Card(
                  color: Colors.deepOrange[50],
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 2,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(8.0), // Padding inside the card.
                    title: Text(
                      pizza['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      pizza['description'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Image.network(
                      pizza['imageUrl'],
                    ),
                    trailing: Text(
                      Formatter.formatCurrency(pizza['price']),
                      style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdatePizzaPage(pizzaId: pizza.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
