import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_yas/view/main_pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int lastOrder = preferences.getInt('lastOrder') ?? 0;
  int savedDay = preferences.getInt('date') ?? 0;
  int cuDay = DateTime.now().day;
  if (savedDay < cuDay || (savedDay != 0 && savedDay > cuDay)) {
    preferences.setInt('date', cuDay);
    preferences.setInt('lastOrder', 0);
    lastOrder = 0;
    savedDay = cuDay;
  }

  runApp(MyApp(
    lastOrder: lastOrder,
    day: savedDay,
  ));
}

class MyApp extends StatelessWidget {
  final int lastOrder;
  final int day;
  const MyApp({
    Key? key,
    required this.lastOrder,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(last: lastOrder, day: day),
    );
  }
}
