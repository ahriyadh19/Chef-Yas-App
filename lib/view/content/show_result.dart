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
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
      ),
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: o.items.length,
            itemBuilder: (_, int index) {
              return Column(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 20, child: Text('${o.itemsQuantity[index]}')),
                          SizedBox(width: 100, child: Text(o.items[index].itemName)),
                          SizedBox(width: 20, child: Text('${o.items[index].itemPrice}')),
                          SizedBox(width: 40, child: Text('${o.items[index].itemPrice * o.itemsQuantity[index]}'))
                        ],
                      ),
                      if (o.items[index].itemNote != null && o.items[index].itemNote!.trim().isNotEmpty) Text('Note: ${o.items[index].itemNote!}')
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
    );
  }
}
