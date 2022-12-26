import 'package:chef_yas/model/item.dart';
import 'package:chef_yas/model/order.dart';
import 'package:chef_yas/service/print_page.dart';
import 'package:chef_yas/view/content/background.dart';
import 'package:chef_yas/view/content/show_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MainPage extends StatefulWidget {
  final int last;
  final int day;

  const MainPage({Key? key, required this.last, required this.day}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool activeSubmit = false;
  final List<Item> myItems = [
    Item(itemID: 0, itemName: 'Chicken S', itemPrice: 6),
    Item(itemID: 1, itemName: 'Chicken S/CH', itemPrice: 8),
    Item(itemID: 2, itemName: 'Chicken L', itemPrice: 10),
    Item(itemID: 3, itemName: 'Chicken L/CH', itemPrice: 12),
    Item(itemID: 4, itemName: 'Chicken plate', itemPrice: 10),
    Item(itemID: 5, itemName: 'Beef S', itemPrice: 9),
    Item(itemID: 6, itemName: 'Beef S/CH', itemPrice: 11),
    Item(itemID: 7, itemName: 'Beef L', itemPrice: 14),
    Item(itemID: 8, itemName: 'Beef L/CH', itemPrice: 16),
    Item(itemID: 9, itemName: 'Beef plate', itemPrice: 14),
  ];
  List<bool> activeNote = List.generate(10, ((index) => false));
  List<TextEditingController> noteInput = List.generate(10, ((index) => TextEditingController()));
  List<double> orderQuantity = List.generate(10, (index) => 0);
  int lastOrder = 0;
  int orderType = 0;
  int savedDate = 0;
  int totalRes = 0;
  late Order? finalOrder;

  Future saveOrder() async {
    int currentDate = DateTime.now().day;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    savedDate = preferences.getInt('date') ?? 0;
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
    savedDate = widget.day;
  }

  void setDefault() {
    setState(() {
      for (int i = 0; i < myItems.length; i++) {
        activeNote[i] = false;
        noteInput[i].clear();
        orderQuantity[i] = 0;
        myItems[i].itemNote = null;
      }
      finalOrder = null;
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

  Center option() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ToggleSwitch(
          minWidth: 150,
          initialLabelIndex: orderType,
          cornerRadius: 20.0,
          activeFgColor: Colors.black,
          inactiveBgColor: Colors.grey.withOpacity(0.3),
          inactiveFgColor: Colors.white.withOpacity(0.3),
          totalSwitches: 2,
          labels: const ['Dine-in', 'Takeaway'],
          icons: const [Icons.dinner_dining_rounded, Icons.outbond_rounded],
          activeBgColors: const [
            [Colors.greenAccent],
            [Colors.greenAccent]
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
                'RM$price',
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
                readOnly: true,
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
                });
              },
              icon: activeNote[index] ? const Icon(Icons.remove_circle_outline_outlined) : const Icon(Icons.note_alt_rounded),
            )
          ],
        ),
        if (activeNote[index])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      myItems[index].itemNote = value;
                    });
                  },
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
              ),
              IconButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
                onPressed: () {
                  setState(() {
                    noteInput[index].clear();
                    myItems[index].itemNote = null;
                  });
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  size: 20,
                ),
              )
            ],
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

  Order makeOrder() {
    Order processOrder;
    int t = 0;
    processOrder = Order(orderNumber: lastOrder + 1, orderTime: DateTime.now(), orderType: orderType, items: [], total: t, itemsQuantity: []);
    for (var i = 0; i < orderQuantity.length; i++) {
      if (orderQuantity[i] != 0) {
        processOrder.items.add(myItems[i]);
        processOrder.itemsQuantity.add(orderQuantity[i].toInt());
        t += myItems[i].itemPrice * orderQuantity[i].toInt();
      }
    }
    processOrder.total = t;
    totalRes = t;
    return processOrder;
  }

  ElevatedButton orderBtn() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (activeSubmit) {
            finalOrder = makeOrder();
            showMyBottomSheet();
          }
        });
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      child: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.done_all_outlined),
            const SizedBox(width: 8),
            Text('ORDER (RM$totalRes)'),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView myBody() {
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
              children: [
                ShowResult(o: makeOrder()),
                const SizedBox(
                  height: 60,
                ),
              ],
            )
        ]));
  }

  Future showMyBottomSheet() async {
    return await showModalBottomSheet(
      enableDrag: true,
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      ),
      builder: (_) {
        return BackGround(
          myBody: PrinterService(newOrder: finalOrder ?? makeOrder(), clearOldData: setDefault, save: saveOrder),
          isSub: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: BackGround(myBody: myBody(), isSub: false),
          floatingActionButton: activeSubmit ? Align(alignment: Alignment.bottomCenter, child: orderBtn()) : null),
    );
  }
}
