import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_yas/view/main_pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int lastOrder = preferences.getInt('lastOrder') ?? 0;
  runApp(MyApp(
    lastOrder: lastOrder,
  ));
}

class MyApp extends StatelessWidget {
  final int lastOrder;
  const MyApp({
    Key? key,
    required this.lastOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(last: lastOrder),
    );
  }
}
