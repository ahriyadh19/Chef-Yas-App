
import 'dart:convert';

class Item {
  int itemID;
  String itemName;
  String itemDescription;
  double itemPrice;
  Item({
    required this.itemID,
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
  });

  Item copyWith({
    int? itemID,
    String? itemName,
    String? itemDescription,
    double? itemPrice,
  }) {
    return Item(
      itemID: itemID ?? this.itemID,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemID': itemID,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemID: map['itemID'] as int,
      itemName: map['itemName'] as String,
      itemDescription: map['itemDescription'] as String,
      itemPrice: map['itemPrice'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Item(itemID: $itemID, itemName: $itemName, itemDescription: $itemDescription, itemPrice: $itemPrice)';
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;
  
    return 
      other.itemID == itemID &&
      other.itemName == itemName &&
      other.itemDescription == itemDescription &&
      other.itemPrice == itemPrice;
  }

  @override
  int get hashCode {
    return itemID.hashCode ^
      itemName.hashCode ^
      itemDescription.hashCode ^
      itemPrice.hashCode;
  }
}
