import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chef_yas/model/item.dart';
import 'package:chef_yas/model/order.dart';
import 'package:chef_yas/service/print_page.dart';
import 'package:chef_yas/view/content/background.dart';
import 'package:chef_yas/view/content/my_icon.dart';
import 'package:chef_yas/view/content/show_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_list/toggle_list.dart';
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
  List<Item> myItems = [
    Item(itemID: 0, itemName: 'C Small', itemPrice: 6),
    Item(itemID: 1, itemName: 'C Small & Cheese', itemPrice: 8),
    Item(itemID: 2, itemName: 'C Large', itemPrice: 10),
    Item(itemID: 3, itemName: 'C Large & Cheese', itemPrice: 12),
    Item(itemID: 4, itemName: 'C Plate', itemPrice: 10),
    Item(itemID: 5, itemName: 'B Small', itemPrice: 9),
    Item(itemID: 6, itemName: 'B Small & Cheese', itemPrice: 11),
    Item(itemID: 7, itemName: 'B Large', itemPrice: 14),
    Item(itemID: 8, itemName: 'B Large & Cheese', itemPrice: 16),
    Item(itemID: 9, itemName: 'B Plate', itemPrice: 14),
    Item(itemID: 10, itemName: 'Kunafa', itemPrice: 10)
  ];

  int itemN = 5;
  int lastOrder = 0;
  int orderType = 0;
  int savedDate = 0;
  int totalRes = 0;
  static const int menuItemsNumber = 11;
  List<bool> activeNote = List.generate(menuItemsNumber, ((index) => false));
  List<TextEditingController> noteInput = List.generate(menuItemsNumber, ((index) => TextEditingController()));
  List<double> orderQuantity = List.generate(menuItemsNumber, (index) => 0);
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

    for (int i = 0; i < itemN; i++) {
      ch.add(menu(index: i, i: myItems[i]));
    }
    return ch;
  }

  List<Widget> buildBeef() {
    List<Widget> beef = [];

    for (int i = itemN; i < myItems.length - 1; i++) {
      beef.add(menu(index: i, i: myItems[i]));
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

  Column menu({required Item i, required int index}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                i.itemName,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                'RM${i.itemPrice}',
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

  List<Widget> sweet() {
    List<Widget> sweet = [];

    sweet.add(menu(index: 10, i: myItems.last));

    return sweet;
  }

  Container section({required int op}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black.withOpacity(0.1),
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          children: op == 0
              ? buildChicken()
              : op == 1
                  ? buildBeef()
                  : sweet(),
        ),
      ),
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

  AwesomeDialog myDialog() {
    return AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      body: const Center(
        child: Text(
          'Your order has submitted successfully',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      title: 'This is Ignored',
      desc: 'This is also Ignored',
      btnOkOnPress: () {},
    )..show();
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
        width: 200,
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

  ToggleList trigger() {
    return ToggleList(
      scrollPhysics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      trailing: const Icon(Icons.arrow_downward_rounded),
      children: [
        ToggleListItem(
          content: section(op: 0),
          title: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black.withOpacity(0.2),
              ),
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              child: Center(child: Text('Chicken Shawarma'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))),
        ),
        ToggleListItem(
          content: section(op: 1),
          title: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black.withOpacity(0.2),
              ),
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              child: Center(child: Text('Beef Shawarma'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))),
        ),
        ToggleListItem(
          content: section(op: 2),
          title: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black.withOpacity(0.2),
              ),
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              child: Center(child: Text('Dessert'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))),
        ),
      ],
    );
  }

  SingleChildScrollView myBody() {
    return SingleChildScrollView(
        controller: ScrollController(),
        child: Column(children: [
          const MyIcon(),
          welcoming(),
          option(),
          trigger(),
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
          myBody: PrinterService(newOrder: finalOrder ?? makeOrder(), clearOldData: setDefault, save: saveOrder, dialog: myDialog),
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
