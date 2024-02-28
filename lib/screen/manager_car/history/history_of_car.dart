import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryOfCar extends StatefulWidget {
  final DocumentSnapshot car;
  HistoryOfCar({Key? key, required this.car}) : super(key: key);

  @override
  State<HistoryOfCar> createState() => _HistoryOfCarState();
}

class _HistoryOfCarState extends State<HistoryOfCar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đặt xe và chi phí'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Lịch sử đặt xe'),
            Tab(text: 'Chi phí'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          HistoryBookingScreen(car: widget.car),
          CostScreen(car: widget.car),
        ],
      ),
    );
  }
}

class HistoryBookingScreen extends StatelessWidget {
  final DocumentSnapshot car;
  HistoryBookingScreen({required this.car});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('pays')
                .where('carID', isEqualTo: car.id) // Filter by carID
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var pays = snapshot.data!.docs[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Image.network(pays['imageUrl']),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pays['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Ông/bà: ${pays['nameKH']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'SDT : ${pays['phoneKH']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  formatTimestamp(pays['timestamp']),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }

  String formatTimestamp(int timestamp) {
    // Tạo một đối tượng DateTime từ timestamp (được tính bằng mili giây)
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Sử dụng định dạng của DateFormat để chuyển đổi DateTime thành chuỗi ngày/tháng/năm
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return formattedDate; // Trả về chuỗi đã được định dạng
  }
}

class CostScreen extends StatelessWidget {
  final DocumentSnapshot car;
  CostScreen({required this.car});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('costs')
                .where('carID', isEqualTo: car.id) // Filter by carID
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var pays = snapshot.data!.docs[index];
                    final priceFormat =
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
                    int expense = int.parse(pays['expense']);
                    final formattedPrice = priceFormat.format(expense);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Image.network(pays['imageUrl']),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pays['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text('Biển số xe : '),
                                    Text(
                                      '${pays['plate']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Tên chi phí : ${pays['expenseName']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'Chi phí : $formattedPrice',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.redAccent),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  formatTimestamp(pays['payDay']),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }

  String formatTimestamp(int timestamp) {
    // Tạo một đối tượng DateTime từ timestamp (được tính bằng mili giây)
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Sử dụng định dạng của DateFormat để chuyển đổi DateTime thành chuỗi ngày/tháng/năm
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return formattedDate; // Trả về chuỗi đã được định dạng
  }
}
