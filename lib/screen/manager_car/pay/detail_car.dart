import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_car/screen/manager_car/firebase_service.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class DetailCar extends StatefulWidget {
  DocumentSnapshot car;

  DetailCar({super.key, required this.car});

  @override
  State<DetailCar> createState() => _DetailCarState();
}

class _DetailCarState extends State<DetailCar> {
  late int status;
  TextEditingController _nameKH = TextEditingController();
  TextEditingController _phoneKH = TextEditingController();
  TextEditingController _startKM = TextEditingController();
  TextEditingController _endKM = TextEditingController();
  TextEditingController _extrafeesKM = TextEditingController();
  TextEditingController _feePay = TextEditingController();
  late DateTime ngayNhanXe;
  late DateTime duKienTraXe;
  late DateTime ngayTraXe;
  bool isSaving = false;
  bool isSave = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    status = widget.car['status'];
    ngayNhanXe = DateTime.fromMillisecondsSinceEpoch(widget.car['starDay']);
    duKienTraXe = DateTime.fromMillisecondsSinceEpoch(widget.car['endDay']);
    ngayTraXe = DateTime.fromMillisecondsSinceEpoch(widget.car['payDay']);
    _nameKH.text = widget.car['nameKH'];
    _phoneKH.text = widget.car['phoneKH'];
  }

  Future<void> showDialogPickDateNgayNhanXe() async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );
    if (pickedDateTime != null) {
      setState(() {
        if (ngayNhanXe != null) {
          ngayNhanXe = pickedDateTime;
          print('$ngayNhanXe : Ngày nhận xe ');
          print(
              '$ngayNhanXe : Ngày nhận xe timestamp ${ngayNhanXe.millisecondsSinceEpoch}');
        }
      });
    }
  }

  Future<void> showDialogPickDateDuKien() async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );
    if (pickedDateTime != null) {
      setState(() {
        if (duKienTraXe != null) {
          duKienTraXe = pickedDateTime;
          print('$duKienTraXe : Dự kiến trả xe ');
          print(
              '$duKienTraXe : Dự kiến trả xe timestamp ${duKienTraXe.millisecondsSinceEpoch}');
        }
      });
    }
  }

  Future<void> showDialogPickDateNgayTraXe() async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );
    if (pickedDateTime != null) {
      setState(() {
        if (ngayTraXe != null) {
          ngayTraXe = pickedDateTime;
          print('$ngayTraXe : Ngày trả xe ');
          print(
              '$ngayTraXe : Ngày trả xe timestamp ${ngayTraXe.millisecondsSinceEpoch}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedPrice = priceFormat.format(widget.car['price']);
    String statusText = '';
    Color statusColor = Colors.black;
    switch (status) {
      case 0:
        statusText = 'Không hoạt động';
        statusColor = Colors.grey;
        break;
      case 1:
        statusText = 'Đăng đặt';
        statusColor = Colors.blue;
        break;
      case 2:
        statusText = 'Đã đặt';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.black;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin chi tiết'),
        elevation: 0,
        actions: [IconButton(onPressed: _saveCarData, icon: Icon(Icons.check))],
      ),
      body: !isSaving
          ? Padding(
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey,
                          child: Image.network(
                            widget.car['imageUrl'],
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.car['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Text(widget.car['plate'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16))
                        ],
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Text(
                        '$formattedPrice /VND',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      InkWell(
                        onTap: () {
                          _showStatusDialog(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trạng thái xe',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Text(statusText),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        child: status == 1 || status == 2
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _entryField(
                                        'Tên khách hàng', _nameKH, false),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    _entryField(
                                        'Số điện thoại', _phoneKH, false),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialogPickDateNgayNhanXe();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ngày nhận xe',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  DateFormat('dd/MM/yyyy HH:mm')
                                                      .format(ngayNhanXe)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialogPickDateDuKien();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Dự kiến trả xe',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  DateFormat('dd/MM/yyyy HH:mm')
                                                      .format(duKienTraXe)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialogPickDateNgayTraXe();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ngày trả xe',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  DateFormat('dd/MM/yyyy HH:mm')
                                                      .format(ngayTraXe)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text('Số kilomet (km)'),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _entryField(
                                                '0', _startKM, false),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: _entryField(
                                                  '0', _endKM, false)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    _entryField('Chi phí phát sinh (VND)',
                                        _extrafeesKM, false),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    _entryField('Tổng thanh toán (VND)',
                                        _feePay, false),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            pay();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black)),
                                          child: Text(
                                            'Pay',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      )
                    ]),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    bool obscureText,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (value) {
        controller.text =
            value; // Cập nhật giá trị trong controller khi người dùng thay đổi
      },
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(),
      ),
    );
  }

  FirebaseService _firebaseService = FirebaseService();
  void _saveCarData() async {
    setState(() {
      isSaving = true;
    });
    // Lấy dữ liệu từ các trường nhập liệu
    String nameKH = _nameKH.text;
    String endKM = _endKM.text;
    String startKM = _startKM.text;
    String payFee = _feePay.text;
    String extraFee = _extrafeesKM.text;
    String phoneKH = _phoneKH.text;
    if (status == 0) {
      nameKH = '';
      endKM = '';
      startKM = '';
      payFee = '';
      extraFee = '';
      phoneKH = '';
      await _firebaseService.saveDetailsCarData(
          nameKH,
          duKienTraXe.millisecondsSinceEpoch,
          ngayTraXe.millisecondsSinceEpoch,
          ngayNhanXe.millisecondsSinceEpoch,
          endKM,
          startKM,
          status,
          payFee,
          extraFee,
          phoneKH,
          widget.car.id);

      setState(() {
        isSaving = false;
        isSave = true;
      });

      // Thông báo hoàn thành việc thêm dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sửa xe thành công')),
      );
    } else {
      // Thêm dữ liệu vào Firestore
      await _firebaseService.saveDetailsCarData(
          nameKH,
          duKienTraXe.millisecondsSinceEpoch,
          ngayTraXe.millisecondsSinceEpoch,
          ngayNhanXe.millisecondsSinceEpoch,
          endKM,
          startKM,
          status,
          payFee,
          extraFee,
          phoneKH,
          widget.car.id);
      setState(() {
        isSaving = false;
        isSave = true;
      });
      // Thông báo hoàn thành việc thêm dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sửa xe thành công')),
      );
    }
  }

  void pay() async {
    if (isSave == false) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn phải lưu trước khi thanh toán ! ')));
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user signed in');
        return;
      }

      int soNgay = ngayTraXe.difference(ngayNhanXe).inDays;
      String nameKH = _nameKH.text;
      String endKM = _endKM.text;
      String startKM = _startKM.text;
      String payFee = _feePay.text;
      String extraFee = _extrafeesKM.text;
      String phoneKH = _phoneKH.text;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await FirebaseService().payCar(
          widget.car.id,
          soNgay,
          widget.car['name'],
          widget.car['plate'],
          widget.car['price'],
          widget.car['imageUrl'],
          user.uid,
          duKienTraXe.millisecondsSinceEpoch,
          endKM,
          extraFee,
          payFee,
          timestamp,
          startKM,
          ngayNhanXe.millisecondsSinceEpoch,
          nameKH,
          phoneKH,
          ngayTraXe.millisecondsSinceEpoch);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Thanh toán thành công ! ')));
      nameKH = '';
      endKM = '';
      startKM = '';
      payFee = '';
      extraFee = '';
      phoneKH = '';
      await _firebaseService.saveDetailsCarData(
          nameKH,
          duKienTraXe.millisecondsSinceEpoch,
          ngayTraXe.millisecondsSinceEpoch,
          ngayNhanXe.millisecondsSinceEpoch,
          endKM,
          startKM,
          0,
          payFee,
          extraFee,
          phoneKH,
          widget.car.id);
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn trạng thái'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('Không hoạt động'),
                value: 0,
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status =
                        value!.toInt(); // Assign new value directly to the map
                    Navigator.of(context).pop();
                    print(status);
                  });
                },
              ),
              RadioListTile(
                title: Text('Đăng đặt'),
                value: 1,
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status = value!.toInt();
                    print(status); // Assign new value directly to the map
                    Navigator.of(context).pop();
                  });
                },
              ),
              RadioListTile(
                title: Text('Đã đặt'),
                value: 2,
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status =
                        value!.toInt(); // Assign new value directly to the map
                    Navigator.of(context).pop();
                    print(status);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
