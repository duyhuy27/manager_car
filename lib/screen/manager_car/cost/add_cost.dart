import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../firebase_service.dart';

class AddCost extends StatefulWidget {
  DocumentSnapshot car;
  AddCost({super.key, required this.car});

  @override
  State<AddCost> createState() => _AddCostState();
}

class _AddCostState extends State<AddCost> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _expenseController = TextEditingController();
  FirebaseService _firebaseService = FirebaseService();

  late DateTime timePay;

  void _saveData() async {
    String expense = _expenseController.text;
    String nameExpense = _nameController.text;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }
    await _firebaseService.addCost(
        expense,
        nameExpense,
        widget.car['name'],
        timePay.millisecondsSinceEpoch,
        widget.car['imageUrl'],
        user.uid,
        widget.car['plate'],
        DateTime.now().millisecondsSinceEpoch,
        widget.car.id);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Thêm chi phí thành công')));

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    timePay = DateTime.now();
  }

  Widget _entryField(
      String title, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> showDialogPickDate() async {
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
        if (timePay != null) {
          timePay = pickedDateTime;
          print('$timePay : Ngày nhận xe ');
          print(
              '$timePay : Ngày nhận xe timestamp ${timePay.millisecondsSinceEpoch}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm chi phí xe'),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                _saveData();
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.car['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.car['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.car['plate'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              _entryField('Tên loại chi phí', _nameController, false),
              SizedBox(
                height: 12,
              ),
              _entryField('Số tiền', _expenseController, false),
              SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () {
                  showDialogPickDate();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày chi trả',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(timePay)),
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
            ],
          ),
        ),
      ),
    );
  }
}
