import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime startDay;
  late DateTime endDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamController<QuerySnapshot> _streamController;

  @override
  void initState() {
    super.initState();
    startDay = DateTime.now();
    endDay = DateTime.now();
    _streamController = StreamController<QuerySnapshot>();
    _updateStream();
  }

  Widget _entryField(BuildContext context, DateTime dateTime, bool isStartDay) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            child: Text(
              DateFormat('dd/MM/yyyy').format(dateTime),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () {
              _showDatePicker(context, dateTime, isStartDay);
            },
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(
      BuildContext context, DateTime selectedDate, bool isStartDay) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDay) {
          startDay = pickedDate;
        } else {
          endDay = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đơn đặt xe'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _entryField(context, startDay, true),
                Text('đến'),
                _entryField(context, endDay, false)
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Container(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _searchByDate();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: Text(
                    'Tìm kiếm',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _streamController.stream,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                    }))
          ],
        ),
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    // Tạo một đối tượng DateTime từ timestamp (được tính bằng mili giây)
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Sử dụng định dạng của DateFormat để chuyển đổi DateTime thành chuỗi ngày/tháng/năm
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return formattedDate; // Trả về chuỗi đã được định dạng
  }

  void _searchByDate() {
    _updateStream();
  }

  void _updateStream() {
    int startTimestamp = startDay.millisecondsSinceEpoch;
    int endTimestamp = endDay.millisecondsSinceEpoch;

    Stream<QuerySnapshot> query;
    if (startTimestamp == DateTime.now().millisecondsSinceEpoch &&
        endTimestamp == DateTime.now().millisecondsSinceEpoch) {
      query = _firestore.collection('pays').snapshots();
    } else {
      query = _firestore
          .collection('pays')
          .where('endDay', isGreaterThanOrEqualTo: startTimestamp)
          .where('endDay', isLessThanOrEqualTo: endTimestamp)
          .snapshots();
    }

    if (!_streamController.isClosed) {
      _streamController.addStream(query);
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
