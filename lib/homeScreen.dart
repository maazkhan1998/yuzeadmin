import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:foodsuggestionadmin/addNewDish.dart';
import 'package:foodsuggestionadmin/dish.dart';
import 'package:foodsuggestionadmin/editDishScreen.dart';
import 'package:foodsuggestionadmin/notificationScreen.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'All Dishes',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationScreen())),
          )
        ],
      ),
      body: PaginateFirestore(
        itemsPerPage: 20,
        itemBuilderType: PaginateBuilderType.gridView,
        query: FirebaseFirestore.instance
            .collection('dishes')
            .orderBy('date', descending: true),
        isLive: true,
        itemBuilder: (index, context, doc) {
          final dish = Dish.fromDocument(doc);
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => EditDishScreen(
                          dish: dish,
                        ))),
            child: Container(
                margin: EdgeInsets.only(left: 5, bottom: 5),
                width: 185,
                height: 185,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(dish.imageURL))),
                child: Center(
                  child: Text(dish.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
                context, CupertinoPageRoute(builder: (context) => AddDish()));
            // final snapshot =
            //     await FirebaseFirestore.instance.collection('dishes').get();
            // snapshot.docs.forEach((element) {
            //   FirebaseFirestore.instance
            //       .collection('dishes')
            //       .doc(element.id)
            //       .update({
            //     'isLunch': true,
            //     'isDinner': false,
            //     'isBreakfast': false,
            //     'isDessert': false
            //   });
            // });
          },
          child: Icon(Icons.add, size: 30, color: Colors.white)),
    );
  }
}
