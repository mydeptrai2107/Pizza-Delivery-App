import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/core/formatter.dart';
import 'package:pizza_delivery_app/user/pizza_detail_page.dart';

class ProductHorizontalItem extends StatelessWidget {
  const ProductHorizontalItem(this.item, {super.key});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      height: 250,
      width: 120,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PizzaDetailsPage(
                pizzaName: item['name'],
                description: item['description'],
                imageUrl: item['imageUrl'],
                price: item['price'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pizza Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                item['imageUrl'],
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Badges (Spicy, Non-Veg)
                  Row(
                    children: [
                      if (item['isNonVeg'])
                        const Badge(label: 'Non-Veg', color: Colors.red),
                      if (item['isSpicy'])
                        const Badge(label: 'Spicy', color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Pizza Name
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Pizza Description
                  Text(
                    item['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Row with Price
                  Text(
                    Formatter.formatCurrency(item['price']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The Badge widget displays a small badge with a label and color.
class Badge extends StatelessWidget {
  final String label; // Text to display on the badge
  final Color color; // Background color of the badge

  const Badge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4.0), // Margin to the right
      padding: const EdgeInsets.symmetric(
          horizontal: 6.0, vertical: 2.0), // Padding inside the badge
      decoration: BoxDecoration(
        color: color, // Badge background color
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Text(
        label, // Badge text
        style: const TextStyle(
          color: Colors.white, // Text color
          fontSize: 10, // Text size
        ),
      ),
    );
  }
}
