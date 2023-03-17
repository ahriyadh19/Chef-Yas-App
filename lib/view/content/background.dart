import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  final Widget myBody;
  final bool isSub;
  const BackGround({
    Key? key,
    required this.myBody,
    required this.isSub,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        borderRadius: isSub ? const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)) : null,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
          const Color.fromARGB(180, 113, 68, 0).withOpacity(1),
          const Color.fromARGB(180, 170, 101, 0).withOpacity(1),
          const Color.fromARGB(180, 255, 152, 0).withOpacity(1),
          const Color.fromARGB(180, 255, 192, 6).withOpacity(1),
          const Color.fromARGB(234, 255, 193, 3).withOpacity(1),
          const Color.fromARGB(255, 255, 193, 0).withOpacity(1)
        ]),
      ),
      child: myBody,
    );
  }
}
