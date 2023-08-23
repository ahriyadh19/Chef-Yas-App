// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Item {
  int itemID;
  String itemName;
  String itemNameDisplay;
  String? itemNote;
  int itemPrice;
  Item({
    required this.itemID,
    required this.itemName,
    required this.itemNameDisplay,
    this.itemNote,
    required this.itemPrice,
  });

  Item copyWith({
    int? itemID,
    String? itemName,
    String? itemNameDisplay,
    String? itemNote,
    int? itemPrice,
  }) {
    return Item(
      itemID: itemID ?? this.itemID,
      itemName: itemName ?? this.itemName,
      itemNameDisplay: itemNameDisplay ?? this.itemNameDisplay,
      itemNote: itemNote ?? this.itemNote,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemID': itemID,
      'itemName': itemName,
      'itemNameDisplay': itemNameDisplay,
      'itemNote': itemNote,
      'itemPrice': itemPrice,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemID: map['itemID'] as int,
      itemName: map['itemName'] as String,
      itemNameDisplay: map['itemNameDisplay'] as String,
      itemNote: map['itemNote'] != null ? map['itemNote'] as String : null,
      itemPrice: map['itemPrice'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Item(itemID: $itemID, itemName: $itemName, itemNameDisplay: $itemNameDisplay, itemNote: $itemNote, itemPrice: $itemPrice)';
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;
  
    return 
      other.itemID == itemID &&
      other.itemName == itemName &&
      other.itemNameDisplay == itemNameDisplay &&
      other.itemNote == itemNote &&
      other.itemPrice == itemPrice;
  }

  @override
  int get hashCode {
    return itemID.hashCode ^
      itemName.hashCode ^
      itemNameDisplay.hashCode ^
      itemNote.hashCode ^
      itemPrice.hashCode;
  }
}
