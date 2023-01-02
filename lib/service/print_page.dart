import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:chef_yas/view/content/show_result.dart';
import 'package:flutter/material.dart';
import 'package:chef_yas/model/order.dart';
import 'package:intl/intl.dart';

class PrinterService extends StatefulWidget {
  final Order newOrder;
  final Function save;
  final Function clearOldData;
  const PrinterService({
    Key? key,
    required this.newOrder,
    required this.save,
    required this.clearOldData,
  }) : super(key: key);

  @override
  State<PrinterService> createState() => _PrinterServiceState();
}

class _PrinterServiceState extends State<PrinterService> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connect';
  late final Function saveOrder;
  late final Function clearData;
  late final ShowResult result;
  late final Order myOrder;
  List<Widget> conn = [];
  List<Widget> disConn = [];

  @override
  void initState() {
    super.initState();
    myOrder = widget.newOrder;
    saveOrder = widget.save;
    clearData = widget.clearOldData;
    result = ShowResult(o: myOrder);
    conn = [connText(), div(), result, div(), printBtn()];
    disConn = [status(), div(), printerFound(), div(), optionBtn(), searchBtn()];
  
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
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
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Center(child: Text('Connected')),
    );
  }

  String buildOutputOwner({required Order order}) {
    String out = "";
    out += "${"Order Number".padRight(13)}${order.orderNumber}\n";
    out += "${"Order Type".padRight(13)}${order.orderType == 0 ? 'Dine-in' : 'Takeaway'}\n";
    out += "${"Date & time".padRight(13)}${DateFormat.MMMEd().add_jm().format(order.orderTime).split(',').join()}\n";
    out += "--------------------------------\n";
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

  String buildOutputOwnerCustomer({required Order order}) {
    String out = 'Chef Yas\n';
    out += "${"Order Number".padRight(13)}${order.orderNumber}\n";
    out += "${"Order Type".padRight(13)}${order.orderType == 0 ? 'Dine-in' : 'Takeaway'}\n";
    out += "${"Date & time".padRight(13)}${DateFormat.MMMEd().add_jm().format(order.orderTime).split(',').join()}\n";
    out += "${"Total".padRight(13)}RM${order.total}\n";
    out += "    (^^) HAVE A GOOD DAY (^^)   \n";
    out += "--------------------------------\n\n";

    return out;
  }

  Row status() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(!_connected ? tips : 'Connected'),
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

  StreamBuilder printerFound() {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: bluetoothPrint.scanResults,
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map((d) => ListTile(
                  title: Text(d.name ?? ''),
                  subtitle: Text(d.address ?? ''),
                  onTap: () async {
                    setState(() {
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

  ElevatedButton connectBtn() {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      onPressed: _connected
          ? null
          : () async {
              if (_device != null && _device!.address != null) {
                setState(() {
                  tips = 'Connecting...';
                });
                await bluetoothPrint.connect(_device!);
              } else {
                setState(() {
                  tips = 'Please select device';
                });
              }
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bluetooth_connected_rounded),
          SizedBox(width: 8),
          Text('Connect'),
        ],
      ),
    );
  }

  ElevatedButton disConnectBtn() {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
      onPressed: _connected
          ? () async {
              setState(() {
                tips = 'Disconnecting...';
              });
              await bluetoothPrint.disconnect();
            }
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bluetooth_disabled_rounded),
          SizedBox(width: 8),
          Text('Disconnect'),
        ],
      ),
    );
  }

  Container optionBtn() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [connectBtn(), const SizedBox(width: 10), disConnectBtn()],
      ),
    );
  }

  SizedBox printBtn() {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.print_rounded),
            SizedBox(width: 8),
            Text('Print'),
          ],
        ),
        onPressed: () async {
          setState(() {
            _connected = true;
          });
          Map<String, dynamic> config = {};
          config['width'] = 50;
          config['height'] = 70;
          config['gap'] = 2;
          List<LineText> owner = [];
          List<LineText> customer = [];
          owner.add(LineText(type: LineText.TYPE_TEXT, content: buildOutputOwner(order: myOrder), align: LineText.ALIGN_CENTER));
          customer.add(LineText(type: LineText.TYPE_TEXT, content: buildOutputOwnerCustomer(order: myOrder), align: LineText.ALIGN_CENTER));
          await bluetoothPrint.printLabel(config, owner);
          await bluetoothPrint.printLabel(config, customer);
          saveOrder();
          clearData();
          setState(() {
            Navigator.pop(context);
          });
        },
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
            child: SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
              child: SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      height: h / 1.3,
      child: SingleChildScrollView(
        child: Column(
          children: _connected ? conn : disConn,
        ),
      ),
    );
  }
}
