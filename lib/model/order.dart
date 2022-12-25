
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:chef_yas/model/item.dart';

class Order {
  DateTime orderTime;
  int orderNumber;
  int orderType;
  int total;
  List<Item> items;
  List<int> itemsQuantity;
  Order({
    required this.orderTime,
    required this.orderNumber,
    required this.orderType,
    required this.total,
    required this.items,
    required this.itemsQuantity,
  });

  Order copyWith({
    DateTime? orderTime,
    int? orderNumber,
    int? orderType,
    int? total,
    List<Item>? items,
    List<int>? itemsQuantity,
  }) {
    return Order(
      orderTime: orderTime ?? this.orderTime,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      total: total ?? this.total,
      items: items ?? this.items,
      itemsQuantity: itemsQuantity ?? this.itemsQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderTime': orderTime.millisecondsSinceEpoch,
      'orderNumber': orderNumber,
      'orderType': orderType,
      'total': total,
      'items': items.map((x) => x.toMap()).toList(),
      'itemsQuantity': itemsQuantity,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderTime: DateTime.fromMillisecondsSinceEpoch(map['orderTime'] as int),
      orderNumber: map['orderNumber'] as int,
      orderType: map['orderType'] as int,
      total: map['total'] as int,
      items: List<Item>.from((map['items'] as List<int>).map<Item>((x) => Item.fromMap(x as Map<String,dynamic>),),),
      itemsQuantity: List<int>.from((map['itemsQuantity'] as List<int>),
    ));
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(orderTime: $orderTime, orderNumber: $orderNumber, orderType: $orderType, total: $total, items: $items, itemsQuantity: $itemsQuantity)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;
  
    return 
      other.orderTime == orderTime &&
      other.orderNumber == orderNumber &&
      other.orderType == orderType &&
      other.total == total &&
      listEquals(other.items, items) &&
      listEquals(other.itemsQuantity, itemsQuantity);
  }

  @override
  int get hashCode {
    return orderTime.hashCode ^
      orderNumber.hashCode ^
      orderType.hashCode ^
      total.hashCode ^
      items.hashCode ^
      itemsQuantity.hashCode;
  }
}
