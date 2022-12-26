// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chef_yas/model/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowResult extends StatelessWidget {
  final Order o;
  const ShowResult({
    Key? key,
    required this.o,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
      ),
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('Order Number'),
                    Text('Date& Time'),
                    Text('Order Type'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('${o.orderNumber}'),
                    Text(DateFormat.MMMEd().add_jm().format(o.orderTime)),
                    Text(o.orderType == 0 ? 'Dine-in' : 'Takeaway'),
                  ],
                ),
              ],
            ),
            Divider(endIndent: w / 6, indent: w / 6, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(width: 30, child: Text('Unit')),
                SizedBox(width: 90, child: Text('Name')),
                SizedBox(width: 40, child: Text('Price')),
                SizedBox(width: 40, child: Text('Total'))
              ],
            ),
            ListView.builder(
              padding: const EdgeInsets.all(5),
              shrinkWrap: true,
              controller: ScrollController(),
              itemCount: o.items.length,
              itemBuilder: (_, int index) {
                return Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: 30, child: Text('${o.itemsQuantity[index]}')),
                            SizedBox(width: 90, child: Text(o.items[index].itemName)),
                            SizedBox(width: 40, child: Text('${o.items[index].itemPrice}')),
                            SizedBox(width: 40, child: Text('${o.items[index].itemPrice * o.itemsQuantity[index]}'))
                          ],
                        ),
                        if (o.items[index].itemNote != null && o.items[index].itemNote!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(alignment: Alignment.centerLeft, child: Text('Note: ${o.items[index].itemNote!}')),
                          )
                      ],
                    )
                  ],
                );
              },
            ),
            Divider(endIndent: w / 6, indent: w / 6, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [const Text('Total'), Text('RM${o.total}')],
            )
          ],
        ),
      ),
    );
  }
}
