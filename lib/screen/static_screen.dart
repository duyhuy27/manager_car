import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaticScreen extends StatefulWidget {
  const StaticScreen({Key? key}) : super(key: key);

  @override
  State<StaticScreen> createState() => _StaticScreenState();
}

class _StaticScreenState extends State<StaticScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late int totalRevenue;
  late int totalExpense;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    totalRevenue = 0;
    totalExpense = 0;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> calculateTotalRevenueAndExpense(
      DateTime startDate, DateTime endDate) async {
    QuerySnapshot revenueSnapshot = await _firestore
        .collection('pays')
        .where('endDay',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('endDay', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .get();

    QuerySnapshot expenseSnapshot = await _firestore
        .collection('costs')
        .where('payDay',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('payDay', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .get();

    int revenue = 0;
    int expense = 0;

    for (QueryDocumentSnapshot doc in revenueSnapshot.docs) {
      revenue += int.parse(doc['totals']);
    }

    for (QueryDocumentSnapshot doc in expenseSnapshot.docs) {
      expense += int.parse(doc['expense']);
    }

    setState(() {
      totalRevenue = revenue;
      totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedPricetotalRevenue = priceFormat.format(totalRevenue);
    final formattedPricetotalExpense = priceFormat.format(totalExpense);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tổng kết doanh số'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn khoảng thời gian:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Ngày bắt đầu',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        _startDateController.text = pickedDate.toString();
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Ngày kết thúc',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        _endDateController.text = pickedDate.toString();
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (_startDateController.text.isNotEmpty &&
                      _endDateController.text.isNotEmpty) {
                    DateTime startDate =
                        DateTime.parse(_startDateController.text);
                    DateTime endDate = DateTime.parse(_endDateController.text);
                    calculateTotalRevenueAndExpense(startDate, endDate);
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                child: Center(
                  child: Text(
                    'Tính toán',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.lightGreen,
              child: Center(
                child: Text(
                  'Tổng doanh thu: $formattedPricetotalRevenue',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.redAccent,
              child: Center(
                child: Text(
                  'Tổng chi phí: $formattedPricetotalExpense',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
