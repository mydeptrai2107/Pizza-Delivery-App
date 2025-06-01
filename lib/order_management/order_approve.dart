import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizza_delivery_app/core/formatter.dart';

class OrderManagerPage extends StatefulWidget {
  const OrderManagerPage({super.key});

  @override
  State<OrderManagerPage> createState() => _OrderManagerPageState();
}

class _OrderManagerPageState extends State<OrderManagerPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchAllOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchAllOrders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});

    setState(() {
      _ordersFuture = _fetchAllOrders(); // Refresh
    });
  }

  void _showUpdateStatusDialog(String orderId, String currentStatus) {
    final statuses = ['Đang xử lý', 'Đã giao', 'Đã hủy'];

    showDialog(
      context: context,
      builder: (context) {
        String selected = currentStatus;

        return AlertDialog(
          title: Text('Cập nhật trạng thái'),
          content: DropdownButtonFormField<String>(
            value: selected,
            items: statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) {
              selected = value!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateStatus(orderId, selected);
                Navigator.pop(context);
              },
              child: Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có đơn hàng nào.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildAdminOrderCard(order);
            },
          );
        },
      ),
    );
  }

  void _showUserInfoFromOrder(
      BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin khách hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Họ tên:   ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order['name']),
              ],
            ),
            Row(
              children: [
                Text(
                  'SĐT:   ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order['mobile']),
              ],
            ),
            Row(
              children: [
                Text(
                  'Địa chỉ:   ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order['address']),
              ],
            ),
            Row(
              children: [
                Text(
                  'Email:   ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order['userEmail']),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOrderCard(Map<String, dynamic> order) {
    final date = (order['timestamp'] as Timestamp?) != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(
            (order['timestamp'] as Timestamp).toDate(),
          )
        : 'Không rõ';

    final List<dynamic> items = order['items'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + User
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Mã đơn: #${order['id'].substring(0, 6)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      _showUserInfoFromOrder(context, order);
                    },
                    child: Text(
                      'UID: ${order['userId'] ?? 'Ẩn'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Thời gian: $date', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // Danh sách món
            ...items.map((item) => _buildItemTile(item)).toList(),

            const Divider(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng tiền:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  Formatter.formatCurrency(order['totalPrice']),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            // Trạng thái + nút cập nhật
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạng thái: ${order['status']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _statusColor(order['status']),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showUpdateStatusDialog(
                    order['id'],
                    order['status'] ?? 'Đang xử lý',
                  ),
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Cập nhật'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                Text(item['pizzaName'] ?? 'Pizza',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
