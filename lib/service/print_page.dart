import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

class PrinterService extends StatefulWidget {
  const PrinterService({Key? key}) : super(key: key);

  @override
  State<PrinterService> createState() => _PrinterServiceState();
}
class _PrinterServiceState extends State<PrinterService> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

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

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: h,
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
            Divider(
              thickness: 3,
              indent: w / 6,
              endIndent: w / 6,
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
                children: const [
                  Icon(Icons.print_disabled_rounded),
                  SizedBox(width: 8),
                  Text('No printer found'),
                ],
              ),
            Divider(
              thickness: 3,
              color: Colors.black,
              indent: w / 10,
              endIndent: w / 10,
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
                      width: w / 5,
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
                        width: w / 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Search'),
                            SizedBox(width: 8),
                            Icon(Icons.bluetooth_searching_rounded),
                          ],
                        ),
                      ),
                      onPressed: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
