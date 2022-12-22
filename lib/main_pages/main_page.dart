import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chef_yas/model/item.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Item> myItems = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  List<Widget> buildChicken() {
    List<Widget> ch = [];

    return ch;
  }

  initData() {
    myItems.add(Item(
        itemID: 0,
        itemName: 'Shawarma Small',
        itemDescription: 'fgg',
        itemPrice: 6.00));
    myItems.add(Item(
        itemID: 1,
        itemName: 'Small with cheese',
        itemDescription: 'fgg',
        itemPrice: 8.00));
    myItems.add(Item(
        itemID: 2,
        itemName: 'Shawarma Large',
        itemDescription: 'fgg',
        itemPrice: 10.00));
    myItems.add(Item(
        itemID: 3,
        itemName: 'Large with cheese',
        itemDescription: 'fgg',
        itemPrice: 12.00));
    myItems.add(Item(
        itemID: 4,
        itemName: 'Chicken with rice',
        itemDescription: 'fgg',
        itemPrice: 12.00));
    myItems.add(Item(
        itemID: 5,
        itemName: 'Chicken plate',
        itemDescription: 'fgg',
        itemPrice: 10.00));
    myItems.add(Item(
        itemID: 6,
        itemName: 'Shawarma Small',
        itemDescription: 'fgg',
        itemPrice: 9.00));
    myItems.add(Item(
        itemID: 7,
        itemName: 'Small with cheese',
        itemDescription: 'fgg',
        itemPrice: 11.00));
    myItems.add(Item(
        itemID: 8,
        itemName: 'Shawarma Large',
        itemDescription: 'fgg',
        itemPrice: 14.00));
    myItems.add(Item(
        itemID: 9,
        itemName: 'Large with cheese',
        itemDescription: 'fgg',
        itemPrice: 16.00));
    myItems.add(Item(
        itemID: 10,
        itemName: 'Beef with rice',
        itemDescription: 'fgg',
        itemPrice: 15.00));
    myItems.add(Item(
        itemID: 11,
        itemName: 'Beef plate',
        itemDescription: 'fgg',
        itemPrice: 14.00));
  }

  Padding welcoming() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 20.0,
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText('Welcome'.toUpperCase()),
            TypewriterAnimatedText('Please make your order'.toUpperCase(),
                speed: const Duration(milliseconds: 140)),
          ],
          repeatForever: true,
          onTap: () {},
        ),
      ),
    );
  }

  Container backGround({required double w, required double h}) {
    return Container(
      height: h,
      width: w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 75, 44, 0),
            Color.fromARGB(255, 113, 67, 0),
            Color.fromARGB(255, 170, 101, 0),
            Color.fromARGB(255, 255, 152, 0),
            Color.fromARGB(255, 255, 192, 6),
          ],
        ),
      ),
      child: myBody(w: w),
    );
  }

  Center option() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ToggleSwitch(
          minWidth: 150,
          initialLabelIndex: 0,
          cornerRadius: 20.0,
          activeFgColor: Colors.black,
          inactiveBgColor: Colors.grey.withOpacity(0.4),
          inactiveFgColor: Colors.white.withOpacity(0.4),
          totalSwitches: 2,
          labels: const ['Dine-in', 'Take-away'],
          icons: const [Icons.dinner_dining_rounded, Icons.outbond_rounded],
          activeBgColors: const [
            [Colors.greenAccent],
            [Colors.blueAccent]
          ],
          onToggle: (index) {},
        ),
      ),
    );
  }

  Container myIcon() {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 5),
      width: 150,
      height: 150,
      child: Image.asset('lib/assets/logo.png'),
    );
  }

  Row menu({required String name, required double price}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            name,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            '$price RM',
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Container chicken() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 150),
      child: Column(children: [
        Text('Chicken Shawarma'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ListView(
          shrinkWrap: true,
          children: [],
        )
      ]),
    );
  }

  myBody({required double w}) {
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [myIcon(), welcoming(), option(), chicken()]),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: backGround(h: h, w: w),
    );
  }
}


