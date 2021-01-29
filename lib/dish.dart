import 'package:cloud_firestore/cloud_firestore.dart';

class Dish{
  final String id;
   String name;
   String imageURL;

  Dish({this.id,this.name,this.imageURL});

  factory Dish.fromDocument(DocumentSnapshot doc){
    return Dish(
      id: doc.id,
      name: doc['name'],
      imageURL: doc['imageURL']
    );
  }
}