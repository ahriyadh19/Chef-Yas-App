import 'package:chef_yas/model/item.dart';
import 'package:chef_yas/model/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MainPage extends StatefulWidget {
  final int last;

  const MainPage({Key? key, required this.last}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool activeSubmit = false;
  List<Item> myItems = [
    Item(itemID: 0, itemName: 'Shawarma S', itemPrice: 6),
    Item(itemID: 1, itemName: 'Small cheese', itemPrice: 8),
    Item(itemID: 2, itemName: 'Shawarma L', itemPrice: 10),
    Item(itemID: 3, itemName: 'Large cheese', itemPrice: 12),
    Item(itemID: 4, itemName: 'Chicken plate', itemPrice: 10),
    Item(itemID: 5, itemName: 'Shawarma S', itemPrice: 9),
    Item(itemID: 6, itemName: 'Small cheese', itemPrice: 11),
    Item(itemID: 7, itemName: 'Shawarma L', itemPrice: 14),
    Item(itemID: 8, itemName: 'Large cheese', itemPrice: 16),
    Item(itemID: 9, itemName: 'Beef plate', itemPrice: 14),
  ];
  List<bool> activeNote = List.generate(10, ((index) => false));
  List<TextEditingController> noteInput = List.generate(10, ((index) => TextEditingController()));
  List<double> orderQuantity = List.generate(10, (index) => 0);
  int lastOrder = 0;
  int orderType = 0;

  Future saveOrder() async {
    int currentDate = DateTime.now().day;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int savedDate = preferences.getInt('date') ?? 0;
    if (savedDate < currentDate || (savedDate != 0 && savedDate > currentDate)) {
      preferences.setInt('date', currentDate);
      preferences.setInt('lastOrder', 0);
      lastOrder = 0;
      preferences.setInt('lastOrder', ++lastOrder);
    } else {
      lastOrder++;
      preferences.setInt('lastOrder', lastOrder);
    }
  }

  @override
  void initState() {
    super.initState();
    lastOrder = widget.last;
  }

  void setDefault() {
    setState(() {
      for (int i = 0; i < myItems.length; i++) {
        activeNote[i] = false;
        noteInput[i].clear();
        orderQuantity[i] = 0;
      }
      activeSubmit = false;
      orderType = 0;
    });
  }

  List<Widget> buildChicken() {
    List<Widget> ch = [];

    for (int i = 0; i < myItems.length / 2; i++) {
      ch.add(menu(index: i, name: myItems[i].itemName, price: myItems[i].itemPrice));
    }
    return ch;
  }

  List<Widget> buildBeef() {
    List<Widget> beef = [];

    for (int i = myItems.length ~/ 2; i < myItems.length; i++) {
      beef.add(menu(index: i, name: myItems[i].itemName, price: myItems[i].itemPrice));
    }

    return beef;
  }

  Padding welcoming() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          'Last Order ${lastOrder == 0 ? "_" : lastOrder}'.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ));
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
          initialLabelIndex: orderType,
          cornerRadius: 20.0,
          activeFgColor: Colors.black,
          inactiveBgColor: Colors.grey.withOpacity(0.4),
          inactiveFgColor: Colors.white.withOpacity(0.4),
          totalSwitches: 2,
          labels: const ['Dine-in', 'Takeaway'],
          icons: const [Icons.dinner_dining_rounded, Icons.outbond_rounded],
          activeBgColors: const [
            [Colors.greenAccent],
            [Colors.blueAccent]
          ],
          onToggle: (index) {
            setState(() {
              orderType = index!;
            });
          },
        ),
      ),
    );
  }

  Padding myIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Image.asset('lib/assets/logo.png'),
      ),
    );
  }

  Column menu({required int index, required String name, required int price}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                name,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                '${price}RM',
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 105,
              child: SpinBox(
                value: orderQuantity[index],
                min: 0,
                max: 25,
                step: 1,
                onChanged: (value) {
                  setState(() {
                    orderQuantity[index] = value;
                    activeSubmit = false;
                    for (int i = 0; i < orderQuantity.length; i++) {
                      if (orderQuantity[i] != 0) {
                        activeSubmit = true;
                      }
                    }
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              iconSize: 20,
              onPressed: () {
                setState(() {
                  activeNote[index] = !activeNote[index];
                  noteInput[index].clear();
                });
              },
              icon: activeNote[index] ? const Icon(Icons.remove_circle_outline_outlined) : const Icon(Icons.note_alt_rounded),
            )
          ],
        ),
        if (activeNote[index])
          SizedBox(
            child: TextField(
              controller: noteInput[index],
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Add note',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          )
      ],
    );
  }

  Container chicken({required bool op}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black.withOpacity(0.1),
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(op ? 'Chicken Shawarma'.toUpperCase() : 'Beef Shawarma'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: op ? buildChicken() : buildBeef(),
          ),
        )
      ]),
    );
  }

  ElevatedButton submitBtn() {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          Order o;
          if (activeSubmit) {
            int t = 0;
            o = Order(orderNumber: lastOrder + 1, orderTime: DateTime.now(), orderType: orderType, items: [], total: t);
            for (var i = 0; i < orderQuantity.length; i++) {
              if (orderQuantity[i] != 0) {
                o.items.add(myItems[i]);
                t += myItems[i].itemPrice * orderQuantity[i].toInt();
              }
            }
            o.total = t;
          }
          setDefault();
        });
        await saveOrder();
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      child: SizedBox(
        width: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.done_all_outlined),
            SizedBox(width: 8),
            Text('ORDER'),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView myBody({required double w}) {
    return SingleChildScrollView(
        controller: ScrollController(),
        child: Column(children: [
          myIcon(),
          welcoming(),
          option(),
          chicken(op: true),
          chicken(op: false),
          if (activeSubmit)
            Column(
              children: const [
                SizedBox(
                  height: 50,
                ),
              ],
            )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        body: backGround(h: h, w: w), floatingActionButton: activeSubmit ? Align(alignment: Alignment.bottomCenter, child: submitBtn()) : null);
  }
}
