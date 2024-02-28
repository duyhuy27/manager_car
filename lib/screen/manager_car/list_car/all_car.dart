import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_car/screen/manager_car/cost/add_cost.dart';
import 'package:manager_car/screen/manager_car/firebase_service.dart';
import 'package:manager_car/screen/manager_car/history/history_of_car.dart';

import '../pay/detail_car.dart';

class AllCarScreen extends StatefulWidget {
  const AllCarScreen({super.key});

  @override
  State<AllCarScreen> createState() => _AllCarScreenState();
}

class _AllCarScreenState extends State<AllCarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả các xe'),
        centerTitle: true,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
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
                        return _buildCarCard(car, index);
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

  Widget _buildCarCard(DocumentSnapshot car, int index) {
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
      onLongPress: () {
        _showCarOptionsDialog(car, index);
      },
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

  void _showCarOptionsDialog(DocumentSnapshot car, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn chức năng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Sao chép xe')
                  ],
                ),
                onTap: () {
                  _copyCar(car);
                  Navigator.pop(context); // Đóng dialog
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.monetization_on_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Chi phí xe')
                  ],
                ),
                onTap: () {
                  _showCarCostDialog(car);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Xóa xe')
                  ],
                ),
                onTap: () {
                  _confirmDeleteCar(car.id);
                  // Navigator.pop(context); // Đóng dialog
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Lịch sử đặt xe và chi phí')
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryOfCar(car: car)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCar(String carID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa xe này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại xác nhận
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                FirebaseService().deleteCar(carID); // Gọi hàm xóa xe
                Navigator.of(context).pop(); // Đóng hộp thoại xác nhận
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _copyCar(DocumentSnapshot car) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }

    // Upload ảnh lên Firebase Storage
    String imageUrl = car['imageUrl'];

    // Lấy dữ liệu từ các trường nhập liệu

    // Thêm dữ liệu vào Firestore
    await FirebaseService().addCarData(
        car['name'], car['plate'], car['price'], imageUrl, user.uid);

    // Thông báo hoàn thành việc thêm dữ liệu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sao chép xe thành công')),
    );
  }

  void _showCarCostDialog(DocumentSnapshot car) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddCost(car: car)));
  }
}
