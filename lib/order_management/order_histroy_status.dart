import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/core/formatter.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đơn hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Bạn chưa có đơn hàng nào.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final timestamp = order['timestamp'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
        : 'Không rõ';

    final List<dynamic> items = order['items'] ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: trạng thái và ngày đặt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order['id'].substring(0, 6)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorApp.primary),
                ),
                Text(
                  order['status'] ?? 'Chờ xử lý',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _statusColor(order['status']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Thời gian: $date', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // Danh sách sản phẩm
            ...items.map((item) => _buildItemTile(item)).toList(),

            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatter.formatCurrency(order['totalPrice']),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['imageUrl'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['pizzaName'] ?? 'Pizza',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Size: ${item['selectedSize']}, SL: ${item['quantity']}'),
              ],
            ),
          ),
          Text(
            Formatter.formatCurrency(
                (item['price'] ?? 0) * (item['quantity'] ?? 1)),
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Đang xử lý':
        return Colors.orange;
      case 'Đã giao':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
