import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/core/formatter.dart';
import 'package:pizza_delivery_app/user/pizza_detail_page.dart';

// Main screen for searching and filtering pizzas
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to fetch pizza data from Firestore
  Future<List<Map<String, dynamic>>> fetchPizzas() async {
    QuerySnapshot querySnapshot = await firestore.collection('pizzas').get();
    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'price': doc['price'],
        'imageUrl': doc['imageUrl'],
        'description': doc['description'],
        'isSpicy': doc['badge'] == 'spicy',
        'isNonVeg': doc['badge'] == 'non-veg',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm món bạn yêu thích',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Dropdown for filtering by category
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField(
                    value: selectedCategory,
                    items: ['All', 'Veg', 'Non-Veg'].map((String category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value.toString();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Display list of pizzas based on search and filter criteria
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchPizzas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading pizzas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không tìm thấy pizza nào'));
                } else {
                  final pizzas = snapshot.data!;
                  return ListView.builder(
                    itemCount: pizzas.length,
                    itemBuilder: (context, index) {
                      // Filter pizzas based on search query and selected category
                      if ((searchQuery.isEmpty ||
                              pizzas[index]['name']
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase())) &&
                          (selectedCategory == 'All' ||
                              (selectedCategory == 'Veg' &&
                                  !pizzas[index]['isNonVeg']) ||
                              (selectedCategory == 'Non-Veg' &&
                                  pizzas[index]['isNonVeg']))) {
                        return ListTile(
                          leading: Image.network(
                            pizzas[index]['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(pizzas[index]['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (pizzas[index]['isNonVeg'])
                                    const Badge(
                                      label: 'Non-Veg',
                                      color: Colors.red,
                                    ),
                                  if (pizzas[index]['isSpicy'])
                                    const Badge(
                                      label: 'Spicy',
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pizzas[index]['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Text(
                            Formatter.formatCurrency(
                              pizzas[index]['price'],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PizzaDetailsPage(
                                  pizzaName: pizzas[index]['name'],
                                  description: pizzas[index]['description'],
                                  imageUrl: pizzas[index]['imageUrl'],
                                  price: pizzas[index]['price'],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Badge Widget for displaying labels like 'Spicy' and 'Non-Veg'
class Badge extends StatelessWidget {
  final String label;
  final Color color;

  const Badge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
