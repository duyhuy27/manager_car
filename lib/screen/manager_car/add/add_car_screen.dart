import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager_car/constant/utils.dart';
import 'package:manager_car/screen/manager_car/firebase_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  Uint8List? image;
  File? selectedImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _plateController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  bool _saving = false;
  void seletedImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  Future _pickImage() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = File(returnImage!.path);
      print(selectedImage);
    });
  }

  //Firebase
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _saveCarData() async {
    setState(() {
      _saving =
          true; // Kích hoạt hiển thị loading khi bắt đầu đẩy dữ liệu lên Firebase
    });
    // Lấy thông tin người dùng hiện tại
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }
    // Kiểm tra xem người dùng đã chọn ảnh chưa
    if (selectedImage == null) {
      print('No image selected');
      return;
    }

    // Upload ảnh lên Firebase Storage
    String imageUrl = await _firebaseService.uploadImage(selectedImage!);

    // Lấy dữ liệu từ các trường nhập liệu
    String name = _nameController.text;
    String plate = _plateController.text;
    int price = int.tryParse(_priceController.text) ?? 0;

    // Thêm dữ liệu vào Firestore
    await _firebaseService.addCarData(name, plate, price, imageUrl, user.uid);

    setState(() {
      _saving =
          false; // Tắt hiển thị loading sau khi đẩy dữ liệu lên Firebase xong
    });
    // Thông báo hoàn thành việc thêm dữ liệu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thêm xe thành công')),
    );
    _nameController.text = '';
    _plateController.text = '';
    _priceController.text = '0';
    selectedImage = null;
  }

  Widget _entryField(String title, TextEditingController controller,
      bool obscureText, TextInputType type) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm mới xe'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveCarData,
            icon: Icon(Icons.check),
            color: Colors.black,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: !_saving
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      // File? selectedImage = await getImageFromGallery(context);
                      // print(selectedImage);
                      _pickImage();
                    },
                    child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.grey.shade100),
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: const Text(
                                    'Chưa ảnh nào được chọn. Bấm vào đây để chọn ảnh'))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Tên xe',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _entryField(
                      'Xe Vinfast', _nameController, false, TextInputType.text),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Biển số xe',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _entryField('VD : 29A1 123.12', _plateController, false,
                      TextInputType.text),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Giá thuê',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _entryField(
                      '0', _priceController, false, TextInputType.number),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
