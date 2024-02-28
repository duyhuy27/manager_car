import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_car/screen/manager_car/add/add_car_screen.dart';
import 'package:manager_car/screen/manager_car/pay/detail_car.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Manager'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Tìm Kiếm',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCarScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Thêm Xe',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCarScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Khách hàng',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('cars').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var car = snapshot.data!.docs[index];
                        return _buildCarCard(car);
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(DocumentSnapshot car) {
    String statusText = '';
    Color statusColor = Colors.black;

    bool isValue = false;

    // Xác định trạng thái và màu sắc tương ứng
    switch (car['status']) {
      case 0:
        statusText = 'Xe không hoạt động';
        statusColor = Colors.grey;
        isValue = false;
        break;
      case 1:
        statusText = 'Xe đăng đặt';
        statusColor = Colors.blue;
        isValue = true;
        break;
      case 2:
        statusText = 'Xe đã đặt';
        statusColor = Colors.red;
        isValue = true;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.black;
    }
    // Định dạng giá tiền
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedPrice = priceFormat.format(car['price']);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCar(
                car: car), // Truyền dữ liệu của xe sang màn hình chi tiết
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey,
                    child: Image.network(
                      car['imageUrl'],
                      fit: BoxFit.cover,
                    )),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        car['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        car['plate'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: statusColor),
                ),
                Container(
                  child: isValue
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ông/bà - ${car['nameKH']} - ${car['phoneKH']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            Text(
                              'Từ ${formatTimestamp(car['starDay'])} đến ${formatTimestamp(car['endDay'])}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        )
                      : Container(),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$formattedPrice/ngày',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          ),
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
}
