import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueDashboard extends StatefulWidget {
  const RevenueDashboard({super.key});

  @override
  State<RevenueDashboard> createState() => _RevenueDashboardState();
}

class _RevenueDashboardState extends State<RevenueDashboard> {
  double totalRevenue = 0;
  int totalOrders = 0;
  List<BarChartGroupData> revenueChartData = [];
  List<String> xLabels = [];
  bool isMonthlyView = false;

  @override
  void initState() {
    super.initState();
    fetchRevenueData();
  }

  Future<void> fetchRevenueData() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    double revenue = 0;
    int orders = 0;
    Map<String, double> groupedRevenue = {};

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      revenue += (data['totalPrice'] ?? 0).toDouble();
      orders++;

      final date = (data['timestamp'] as Timestamp).toDate();
      final key = isMonthlyView
          ? DateFormat('MM/yyyy').format(date)
          : DateFormat('dd/MM').format(date);

      groupedRevenue[key] =
          (groupedRevenue[key] ?? 0) + (data['totalPrice'] ?? 0);
    }

    final sortedEntries = groupedRevenue.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    setState(() {
      totalRevenue = revenue;
      totalOrders = orders;
      xLabels = sortedEntries.map((e) => e.key).toList();
      revenueChartData = sortedEntries.mapIndexed((index, entry) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: Colors.blueAccent,
              width: 14,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
          showingTooltipIndicators: [0],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Thống kê doanh thu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                isMonthlyView ? Icons.calendar_view_day : Icons.calendar_month),
            tooltip:
                isMonthlyView ? 'Thống kê theo ngày' : 'Thống kê theo tháng',
            onPressed: () {
              setState(() {
                isMonthlyView = !isMonthlyView;
              });
              fetchRevenueData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            SizedBox(height: 20),
            _buildChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'Tổng doanh thu',
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
              .format(totalRevenue),
          Icons.monetization_on,
          Colors.green,
        ),
        _buildStatCard(
          'Tổng đơn hàng',
          '$totalOrders',
          Icons.receipt_long,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.42,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey[600]))
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= xLabels.length) return Text('');
                      return Text(
                        xLabels[index],
                        style: TextStyle(fontSize: 10),
                      );
                    }),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: revenueChartData,
          ),
        ),
      ),
    );
  }
}

// Extension để hỗ trợ map có chỉ số
extension IndexedMap<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}
