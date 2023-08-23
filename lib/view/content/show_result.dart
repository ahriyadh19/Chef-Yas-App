import 'package:chef_yas/model/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowResult extends StatelessWidget {
  final Order currentOrder;
  const ShowResult({
    Key? key,
    required this.currentOrder,
  }) : super(key: key);

  String formatPrice(double price) {
    String priceString = price.toString();
    if (priceString.endsWith('.0') || priceString.endsWith('.00') || priceString.endsWith('.000')) {
      return '${price.toInt()}';
    } else {
      return '$price';
    }
  }

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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cust.Nm'),
                    Text('Number'),
                    Text('Type'),
                    Text('Date & Time'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currentOrder.orderName != null && currentOrder.orderName != '' ? currentOrder.orderName! : '-'),
                    Text('${currentOrder.orderNumber}'),
                    Text(currentOrder.orderType == 0 ? 'Dine-in' : 'Takeaway'),
                    Text(DateFormat.MMMEd().add_jm().format(currentOrder.orderTime).split(',').join()),
                  ],
                ),
              ],
            ),
            Divider(endIndent: w / 6, indent: w / 6, thickness: 2),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 45, child: Text('Qty')),
                SizedBox(width: 150, child: Text('Name')),
                SizedBox(width: 45, child: Text('Price')),
                SizedBox(width: 45, child: Text('Total'))
              ],
            ),
            if (currentOrder.items.length > 1) Divider(endIndent: w / 6, indent: w / 6, thickness: 2),
            ListView.builder(
              padding: const EdgeInsets.all(5),
              shrinkWrap: true,
              controller: ScrollController(),
              itemCount: currentOrder.items.length,
              itemBuilder: (_, int index) {
                return Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: 45, child: Text('${currentOrder.itemsQuantity[index]}')),
                            SizedBox(width: 150, child: Text(currentOrder.items[index].itemName)),
                            SizedBox(width: 45, child: Text(formatPrice(currentOrder.items[index].itemPrice))),
                            SizedBox(width: 45, child: Text(formatPrice(currentOrder.items[index].itemPrice * currentOrder.itemsQuantity[index])))
                          ],
                        ),
                        if (currentOrder.items[index].itemNote != null && currentOrder.items[index].itemNote!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Align(alignment: Alignment.centerLeft, child: Text('Note: ${currentOrder.items[index].itemNote!}')),
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
              children: [const Text('Total'), Text('RM${formatPrice(currentOrder.total)}')],
            )
          ],
        ),
      ),
    );
  }
}
