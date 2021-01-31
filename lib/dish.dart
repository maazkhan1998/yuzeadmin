import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String id;
  String name;
  String imageURL;
  String credit;

  Dish({this.id, this.name, this.imageURL, this.credit});

  factory Dish.fromDocument(DocumentSnapshot doc) {
    return Dish(
        id: doc.id,
        name: doc['name'],
        imageURL: doc['imageURL'],
        credit: doc['credit']);
  }
}
