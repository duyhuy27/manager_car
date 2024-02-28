import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      // Tạo reference cho ảnh trên Firebase Storage
      Reference storageReference = _storage
          .ref()
          .child('car_images/${DateTime.now().millisecondsSinceEpoch}');

      // Upload ảnh lên Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot storageSnapshot = await uploadTask;

      // Lấy URL của ảnh sau khi upload thành công
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> addCarData(String name, String plate, int price, String imageUrl,
      String userId) async {
    try {
      // Thêm dữ liệu vào Firestore
      DocumentReference newCarRef = await _firestore.collection('cars').add({
        'name': name,
        'plate': plate,
        'price': price,
        'imageUrl': imageUrl,
        'userId': userId,
        'endDay': 0,
        'endKM': 0,
        'extras': 0,
        'totals': 0,
        'timestamp': 0,
        'status': 0,
        'startKM': 0,
        'starDay': 0,
        'stability': 0,
        'freeType': 0,
        'nameKH': '',
        'phoneKH': '',
        'payDay': 0,
      });
      String carID = newCarRef.id;
    } catch (e) {
      print('Error adding car data: $e');
    }
  }

  Future<void> saveDetailsCarData(
      String nameKH,
      int endDay,
      int payDay,
      int startDay,
      String endKm,
      String startKM,
      int status,
      String payFee,
      String extraFee,
      String phoneKH,
      String carID) async {
    try {
      // Thêm dữ liệu vào Firestore
      await _firestore.collection('cars').doc(carID).update({
        'nameKH': nameKH,
        'endDay': endDay,
        'endKM': endDay,
        'extras': extraFee,
        'totals': payFee,
        'timestamp': 0,
        'status': status,
        'startKM': startKM,
        'starDay': startDay,
        'phoneKH': phoneKH,
        'payDay': payDay,
      });
    } catch (e) {
      print('Error adding car data: $e');
    }
  }

  Future<void> deleteCar(String carID) async {
    try {
      await _firestore.collection('cars').doc(carID).delete();
      print('Car with ID $carID has been deleted.');
    } catch (e) {
      print('Error deleting car: $e');
    }
  }

  Future<void> payCar(
      String carID,
      int day,
      String name,
      String plate,
      int price,
      String imageUrl,
      String userId,
      int endDay,
      String endKM,
      String exTra,
      String total,
      int timestamp,
      String startKM,
      int startDay,
      String nameKH,
      String phoneKH,
      int payDay) async {
    try {
      // Thêm dữ liệu vào Firestore
      await _firestore.collection('pays').add({
        'day': day,
        'name': name,
        'plate': plate,
        'price': price,
        'imageUrl': imageUrl,
        'userId': userId,
        'endDay': endDay,
        'endKM': endKM,
        'extras': exTra,
        'totals': total,
        'timestamp': timestamp,
        'startKM': startKM,
        'starDay': startDay,
        'nameKH': nameKH,
        'phoneKH': phoneKH,
        'payDay': payDay,
        'carID': carID
      });
    } catch (e) {
      print('Error adding car data: $e');
    }
  }

  Future<void> addCost(
      String expense,
      String expenseName,
      String name,
      int payDay,
      String imageUrl,
      String userId,
      String plate,
      int timestamp,
      String carID) async {
    try {
      // Thêm dữ liệu vào Firestore
      await _firestore.collection('costs').add({
        'expense': expense,
        'expenseName': expenseName,
        'name': name,
        'payDay': payDay,
        'imageUrl': imageUrl,
        'userId': userId,
        'plate': plate,
        'carID': carID
      });
    } catch (e) {
      print('Error adding car data: $e');
    }
  }
}
