import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:chef_yas/model/item.dart';

class Order {
  String orderID;
  DateTime orderTime;
  int orderNumber;
  int orderType;
  double total;
  List<Item> items;
  Order({
    required this.orderID,
    required this.orderTime,
    required this.orderNumber,
    required this.orderType,
    required this.total,
    required this.items,
  });

  Order copyWith({
    String? orderID,
    DateTime? orderTime,
    int? orderNumber,
    int? orderType,
    double? total,
    List<Item>? items,
  }) {
    return Order(
      orderID: orderID ?? this.orderID,
      orderTime: orderTime ?? this.orderTime,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      total: total ?? this.total,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderID': orderID,
      'orderTime': orderTime.millisecondsSinceEpoch,
      'orderNumber': orderNumber,
      'orderType': orderType,
      'total': total,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderID: map['orderID'] as String,
      orderTime: DateTime.fromMillisecondsSinceEpoch(map['orderTime'] as int),
      orderNumber: map['orderNumber'] as int,
      orderType: map['orderType'] as int,
      total: map['total'] as double,
      items: List<Item>.from((map['items'] as List<int>).map<Item>((x) => Item.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(orderID: $orderID, orderTime: $orderTime, orderNumber: $orderNumber, orderType: $orderType, total: $total, items: $items)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;
  
    return 
      other.orderID == orderID &&
      other.orderTime == orderTime &&
      other.orderNumber == orderNumber &&
      other.orderType == orderType &&
      other.total == total &&
      listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return orderID.hashCode ^
      orderTime.hashCode ^
      orderNumber.hashCode ^
      orderType.hashCode ^
      total.hashCode ^
      items.hashCode;
  }
}
