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
    Item(itemID: 0, itemName: 'C Small', itemPrice: 6, itemNameDisplay: 'Small'),
    Item(itemID: 1, itemName: 'C Small & Cheese', itemPrice: 8, itemNameDisplay: 'Small & Cheese'),
    Item(itemID: 2, itemName: 'C Large', itemPrice: 10, itemNameDisplay: 'Large'),
    Item(itemID: 3, itemName: 'C Large & Cheese', itemPrice: 12, itemNameDisplay: 'Large & Cheese'),
    Item(itemID: 4, itemName: 'C Plate', itemPrice: 10, itemNameDisplay: 'Plate'),
    Item(itemID: 5, itemName: 'B Small', itemPrice: 9, itemNameDisplay: 'Small'),
    Item(itemID: 6, itemName: 'B Small & Cheese', itemPrice: 11, itemNameDisplay: 'Small & Cheese'),
    Item(itemID: 7, itemName: 'B Large', itemPrice: 14, itemNameDisplay: 'Large'),
    Item(itemID: 8, itemName: 'B Large & Cheese', itemPrice: 16, itemNameDisplay: 'Large & Cheese'),
    Item(itemID: 9, itemName: 'B Plate', itemPrice: 14, itemNameDisplay: 'Plate'),
    Item(itemID: 10, itemName: 'Kunafa', itemPrice: 10, itemNameDisplay: 'Kunafa'),
    Item(itemID: 11, itemName: '7up', itemPrice: 3, itemNameDisplay: '7up'),
    Item(itemID: 12, itemName: 'Pepsi', itemPrice: 3, itemNameDisplay: 'Pepsi'),
    Item(itemID: 13, itemName: 'Water', itemPrice: 2, itemNameDisplay: 'Water'),
  ];

  int itemN = 5;
  int lastOrder = 0;
  int orderType = 0;
  int savedDate = 0;
  double totalRes = 0;
  TextEditingController orderName = TextEditingController();
  static const int menuItemsNumber = 14;
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
      orderName.clear();
    });
  }

  List<Widget> buildChicken() {
    List<Widget> ch = [];

    for (int i = 0; i < 5; i++) {
      ch.add(menu(index: i, i: myItems[i]));
    }
    return ch;
  }

  List<Widget> buildBeef() {
    List<Widget> beef = [];

    for (int i = 5; i < 10; i++) {
      beef.add(menu(index: i, i: myItems[i]));
    }
    return beef;
  }

  List<Widget> buildSweet() {
    List<Widget> sweet = [];
    sweet.add(menu(index: 10, i: myItems[10]));
    return sweet;
  }

  List<Widget> buildDrinks() {
    List<Widget> drinks = [];

    for (int i = 11; i < myItems.length; i++) {
      drinks.add(menu(index: i, i: myItems[i]));
    }

    return drinks;
  }

  Padding orderCounter() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          'Last Order ${lastOrder == 0 ? "_" : lastOrder}'.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ));
  }

  Center optionOfOrder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ToggleSwitch(
          minWidth: 150,
          initialLabelIndex: orderType,
          cornerRadius: 20.0,
          activeFgColor: Colors.black,
          inactiveBgColor: Colors.grey.withOpacity(0.7),
          inactiveFgColor: Colors.white.withOpacity(0.7),
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

  String formatPrice(double price) {
    String priceString = price.toString();
    if (priceString.endsWith('.0') || priceString.endsWith('.00') || priceString.endsWith('.000')) {
      return 'RM ${price.toInt()}';
    } else {
      return 'RM $price';
    }
  }

  Column menu({required Item i, required int index}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                i.itemNameDisplay,
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              formatPrice(i.itemPrice),
            ),
            Expanded(
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
                  : op == 2
                      ? buildDrinks()
                      : buildSweet(),
        ),
      ),
    );
  }

  Order makeOrder() {
    Order processOrder;
    double totalCurrentOrder = 0;
    processOrder =
        Order(orderNumber: lastOrder + 1, orderTime: DateTime.now(), orderType: orderType, items: [], total: totalCurrentOrder, itemsQuantity: []);
    for (var i = 0; i < orderQuantity.length; i++) {
      if (orderQuantity[i] != 0) {
        processOrder.items.add(myItems[i]);
        processOrder.itemsQuantity.add(orderQuantity[i].toInt());
        totalCurrentOrder += myItems[i].itemPrice * orderQuantity[i].toInt();
      }
    }
    processOrder.total = totalCurrentOrder;
    totalRes = totalCurrentOrder;
    processOrder.orderName = orderName.text;
    return processOrder;
  }

  AwesomeDialog myDialog() {
    return AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      body: const Center(
        child: Text(
          'Order has Printed successfully',
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

  ToggleList triggerListOfFood() {
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
              child: Center(child: Text('Drinks'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))),
        ),
        ToggleListItem(
          content: section(op: 3),
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        const MyIcon(),
        orderCounter(),
        optionOfOrder(),
        triggerListOfFood(),
        customerName(),
        if (activeSubmit)
          Column(
            children: [
              ShowResult(currentOrder: makeOrder()),
              //orderBtn(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            ],
          ),
      ]),
    );
  }

  Padding customerName() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.black.withOpacity(0.2),
        ),
        padding: const EdgeInsets.all(10),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Customer Name',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          controller: orderName,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Future showMyBottomSheet() async {
    return await showModalBottomSheet(
      enableDrag: true,
      context: context,
      isDismissible: true,
      elevation: 50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      ),
      builder: (_) {
        return StatefulBuilder(
            builder: (context, setState) =>
                PrinterService(newOrder: finalOrder ?? makeOrder(), clearOldData: setDefault, save: saveOrder, dialog: myDialog));
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
