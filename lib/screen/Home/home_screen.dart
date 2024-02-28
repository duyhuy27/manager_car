import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_car/screen/Home/Components/text.dart';
import 'package:manager_car/screen/manager_car/list_car/all_car.dart';

import '../manager_car/pay/detail_car.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Car Manager')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textTitleInHome('Xe của tôi', 24),
              SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('cars').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (snapshot.hasData) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: double.infinity,
                        child: CarouselSlider.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, itemIndex, pageViewIndex) {
                            var car = snapshot.data!.docs[itemIndex];
                            return InkWell(
                              onTap: () {},
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 300,
                                  width: 600,
                                  child: Image.network(
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.cover,
                                      '${car['imageUrl']}'),
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                              height: 300,
                              autoPlay: true,
                              viewportFraction: 0.55,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              autoPlayAnimationDuration:
                                  const Duration(seconds: 2),
                              enableInfiniteScroll: true,
                              reverse: false,
                              pageSnapping: true,
                              aspectRatio: 16 / 9,
                              initialPage: 0,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.3,
                              scrollDirection: Axis.horizontal),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textTitleInHome('Xe của tôi', 25),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllCarScreen()));
                      },
                      child: textTitleInHome('Xem thêm', 14)),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('cars').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
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
        padding: const EdgeInsets.only(right: 10),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 100,
                    width: 200,
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text(
                  car['plate'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: statusColor),
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
}
