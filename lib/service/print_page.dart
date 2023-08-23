import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:chef_yas/view/content/background.dart';
import 'package:chef_yas/view/content/show_result.dart';
import 'package:flutter/material.dart';
import 'package:chef_yas/model/order.dart';
import 'package:intl/intl.dart';

class PrinterService extends StatefulWidget {
  final Order newOrder;
  final Function save;
  final Function clearOldData;
  final Function dialog;
  const PrinterService({Key? key, required this.newOrder, required this.save, required this.clearOldData, required this.dialog}) : super(key: key);

  @override
  State<PrinterService> createState() => _PrinterServiceState();
}

class _PrinterServiceState extends State<PrinterService> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  bool _isPrinted = false;
  bool _isCusPrinted = false;
  bool _isResPrinted = false;
  BluetoothDevice? _device;
  String tips = 'No device connect';
  late final Function saveOrder;
  late final Function clearData;
  late final Function dialog;
  late final ShowResult result;
  late final Order myOrder;

  @override
  void initState() {
    super.initState();
    myOrder = widget.newOrder;
    saveOrder = widget.save;
    clearData = widget.clearOldData;
    dialog = widget.dialog;
    result = ShowResult(o: myOrder);
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Row titles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.print_rounded, size: 30),
        const SizedBox(
          width: 15,
        ),
        Text('Print'.toUpperCase(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 2));
    bool isConnected = await bluetoothPrint.isConnected ?? false;
    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Padding connText() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Printer is Connected'),
          const SizedBox(width: 10),
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }

  String printTitle({required Order order}) {
    String outTitle = "Restaurant Copy\n\n";
    outTitle += "${"Order Number: ".padRight(13)}${order.orderNumber}\n";
    outTitle += "${"Customer Name: ".padRight(13)}${order.orderName != null && order.orderName != '' ? order.orderName : ' -'}\n";
    outTitle += "${"Order Type: ".padRight(13)}${order.orderType == 0 ? 'Dine-in' : 'Takeaway'}\n";
    outTitle += "${"Date & time: ".padRight(13)}${DateFormat.MMMEd().add_jm().format(order.orderTime).split(',').join()}\n";
    outTitle += "--------------------------------\n";
    return outTitle;
  }

  String printInfo({required Order order}) {
    String out = "";
    for (int i = 0; i < order.items.length; i++) {
      out +=
          "${order.itemsQuantity[i].toString().padRight(3)} ${order.items[i].itemName.padRight(19)} RM${order.items[i].itemPrice * order.itemsQuantity[i]}\n";
      if (order.items[i].itemNote != null && order.items[i].itemNote!.trim().isNotEmpty) {
        out += "Note: ${order.items[i].itemNote!.trim()}\n";
      }
    }
    out += "--------------------------------\n";
    out += "${"Total".padRight(24)}RM${order.total}\n";
    out += "--------------------------------\n";

    return out;
  }

  String printForCustomer({required Order order}) {
    String outCustomer = 'Chef Yas\n\n';
    outCustomer += 'Customer Copy\n';
    outCustomer += "${"Order Number: ".padRight(13)}${order.orderNumber}\n";
    outCustomer += "${"Customer Name: ".padRight(13)}${order.orderName != null && order.orderName != '' ? order.orderName : '-'}\n";
    outCustomer += "${"Order Type: ".padRight(13)}${order.orderType == 0 ? 'Dine-in' : 'Takeaway'}\n";
    outCustomer += "${"Date & time: ".padRight(13)}${DateFormat.MMMEd().add_jm().format(order.orderTime).split(',').join()}\n";
    outCustomer += "${"Total: ".padRight(13)}RM${order.total}\n";
    outCustomer += "    (^^) HAVE A GOOD DAY (^^)   \n";
    outCustomer += "--------------------------------\n\n";
    return outCustomer;
  }

  Row status() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: _connected ? connText() : Text(!_connected ? tips : ''),
        ),
      ],
    );
  }

  Divider div() {
    return const Divider(
      thickness: 1.2,
      indent: 80,
      endIndent: 80,
      color: Colors.black,
    );
  }

  StreamBuilder printerFound({required Function set}) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: bluetoothPrint.scanResults,
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map((d) => ListTile(
                  title: Text(d.name ?? ''),
                  subtitle: Text(d.address ?? ''),
                  onTap: () async {
                    set(() {
                      _device = d;
                    });
                  },
                  trailing: _device != null && _device!.address == d.address
                      ? const Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : null,
                ))
            .toList(),
      ),
    );
  }

  ElevatedButton connectBtn({required Function set}) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      onPressed: _connected
          ? null
          : () async {
              if (_device != null && _device!.address != null) {
                set(() {
                  tips = 'Connecting...';
                });
                await bluetoothPrint.connect(_device!);
              } else {
                set(() {
                  tips = 'Please select device';
                });
              }
            },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_connected_rounded),
          SizedBox(width: 8),
          Text('Connect'),
        ],
      ),
    );
  }

  ElevatedButton disConnectBtn({required Function set}) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      onPressed: _connected
          ? () async {
              set(() {
                tips = 'Disconnecting...';
              });
              await bluetoothPrint.disconnect();
            }
          : null,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled_rounded),
          SizedBox(width: 8),
          Text('Disconnect'),
        ],
      ),
    );
  }

  Container optionBtn({required Function set}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [connectBtn(set: set), const SizedBox(width: 10), disConnectBtn(set: set)],
      ),
    );
  }

  SizedBox printBtnRes({required Function set}) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
        onPressed: _isResPrinted
            ? null
            : () async {
                Map<String, dynamic> config = {};
                List<LineText> bill = [];
                config['width'] = 50;
                config['height'] = 70;
                config['gap'] = 2;
                bill.add(LineText(type: LineText.TYPE_TEXT, content: printTitle(order: myOrder), align: LineText.ALIGN_CENTER));
                bill.add(LineText(type: LineText.TYPE_TEXT, content: printInfo(order: myOrder), align: LineText.ALIGN_LEFT));
                await bluetoothPrint.printLabel(config, bill);
                !_isPrinted ? {saveOrder(), clearData()} : null;
                set(() {
                  _isPrinted = true;
                  _connected = true;
                  _isResPrinted = true;
                });
                dialog();
              },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded),
            SizedBox(width: 8),
            Text('Restaurant Copy'),
          ],
        ),
      ),
    );
  }

  SizedBox printBtnCus({required Function set}) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
        onPressed: _isCusPrinted
            ? null
            : () async {
                Map<String, dynamic> config = {};
                List<LineText> bill = [];
                config['width'] = 50;
                config['height'] = 70;
                config['gap'] = 2;
                bill.add(LineText(type: LineText.TYPE_TEXT, content: printForCustomer(order: myOrder), align: LineText.ALIGN_CENTER));
                await bluetoothPrint.printLabel(config, bill);
                !_isPrinted ? {saveOrder(), clearData()} : null;
                set(() {
                  _isPrinted = true;
                  _connected = true;
                  _isCusPrinted = true;
                });
                dialog();
              },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('Customer Copy'),
          ],
        ),
      ),
    );
  }

  StreamBuilder searchBtn() {
    return StreamBuilder<bool>(
      stream: bluetoothPrint.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        if (snapshot.data == true) {
          return ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
            onPressed: () => bluetoothPrint.stopScan(),
            child: const SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Stop'),
                  SizedBox(width: 8),
                  Icon(Icons.stop),
                ],
              ),
            ),
          );
        } else {
          return ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.greenAccent)),
              child: const SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Search'),
                    SizedBox(width: 8),
                    Icon(Icons.bluetooth_searching_rounded),
                  ],
                ),
              ),
              onPressed: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 2)));
        }
      },
    );
  }

  SizedBox backBtn() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back_ios_new_rounded), SizedBox(width: 15), Text('Back')]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackGround(
      myBody: Center(
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, mySetState) {
              return Column(
                children: _connected
                    ? [
                        connText(),
                        div(),
                        result,
                        div(),
                        titles(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [printBtnRes(set: mySetState), const SizedBox(width: 20), printBtnCus(set: mySetState)]),
                        if (_isCusPrinted && _isResPrinted) backBtn()
                      ]
                    : [status(), div(), printerFound(set: mySetState), div(), optionBtn(set: mySetState), searchBtn()],
              );
            },
          ),
        ),
      ),
      isSub: true,
    );
  }
}
