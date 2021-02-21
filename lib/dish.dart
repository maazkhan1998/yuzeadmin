import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String id;
  String name;
  String imageURL;
  String credit;
  String date;
  bool isLunch;
  bool isDinner;
  bool isBreakfast;
  bool isDessert;
  String link;

  Dish(
      {this.id,
      this.name,
      this.imageURL,
      this.credit,
      this.date,
      this.isBreakfast,
      this.isDessert,
      this.isDinner,
      this.isLunch,
      this.link});

  factory Dish.fromDocument(DocumentSnapshot doc) {
    return Dish(
      id: doc.id,
      name: doc['name'],
      imageURL: doc['imageURL'],
      credit: doc['credit'],
      date: doc['date'],
      isLunch: doc['isLunch'],
      isBreakfast: doc['isBreakfast'],
      isDessert: doc['isDessert'],
      isDinner: doc['isDinner'],
      link: doc['link'],
    );
  }
}
