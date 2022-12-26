import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:chef_yas/model/order.dart';

class PrinterService extends StatefulWidget {
  final Order? newOrder;
  final Function save;
  final Function clearOldData;
  const PrinterService({
    Key? key,
    this.newOrder,
    required this.save,
    required this.clearOldData,
  }) : super(key: key);

  @override
  State<PrinterService> createState() => _PrinterServiceState();
}

class _PrinterServiceState extends State<PrinterService> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool isOn = true;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connect';
  late final Function saveOrder;
  late final Function clearData;
  Order? myOrder;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    } catch (e) {
      setState(() {
        isOn = false;
      });
    }

    myOrder = widget.newOrder;
    saveOrder = widget.save;
    clearData = widget.clearOldData;
  }

  Future<void> initBluetooth() async {
    try {
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
    } catch (e) {
      setState(() {
        isOn = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isOn
        ? SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Text(tips),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 3,
                    indent: 80,
                    endIndent: 80,
                    color: Colors.black,
                  ),
                  StreamBuilder<List<BluetoothDevice>>(
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
                  ),
                  if (_device == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.print_disabled_rounded),
                        const SizedBox(width: 8),
                        const Text('No printer found'),
                        const SizedBox(width: 8),
                        SizedBox(child: Text('${myOrder.toString().length}'))
                      ],
                    ),
                  const Divider(
                    thickness: 3,
                    color: Colors.black,
                    indent: 60,
                    endIndent: 60,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
                              onPressed: _connected
                                  ? null
                                  : () async {
                                      if (_device != null && _device!.address != null) {
                                        setState(() {
                                          tips = 'connecting...';
                                        });
                                        await bluetoothPrint.connect(_device!);
                                      } else {
                                        setState(() {
                                          tips = 'please select device';
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
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
                              onPressed: _connected
                                  ? () async {
                                      setState(() {
                                        tips = 'disconnecting...';
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
                            ),
                          ],
                        ),
                        const Divider(),
                        ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(180, 170, 101, 0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.print_rounded),
                              SizedBox(width: 8),
                              Text('Print Test'),
                            ],
                          ),
                          onPressed: () {
                            saveOrder();
                            clearData();
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  StreamBuilder<bool>(
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
                  )
                ],
              ),
            ),
          )
        : const Center(
            child: Text('Please on thr Bluetooth'),
          );
  }
}
