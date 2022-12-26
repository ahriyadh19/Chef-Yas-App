import 'package:flutter/material.dart';

class MyIcon extends StatelessWidget {
  const MyIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Image.asset('lib/assets/logo.png'),
      ),
    );
  }
}