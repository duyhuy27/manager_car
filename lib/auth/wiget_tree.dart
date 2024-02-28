import 'package:flutter/cupertino.dart';
import 'package:manager_car/auth/auth.dart';
import 'package:manager_car/screen/gnavbar/bottom_nav_bar.dart';
import 'package:manager_car/screen/login_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const GNavBar();
          } else {
            return const LoginScreen();
          }
        });
  }
}
