import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  TextEditingController searchController = TextEditingController();
  Query mainQuery = FirebaseFirestore.instance
      .collection('dishes')
      .orderBy('date', descending: true);
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
      body: SafeArea(
          child: Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: Theme(
            data: Theme.of(context)
                .copyWith(splashColor: Color.fromRGBO(237, 237, 237, 1)),
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: ScreenUtil().setWidth(380),
              child: TextField(
                maxLines: 1,
                controller: searchController,
                cursorColor: Color.fromRGBO(140, 140, 140, 1),
                onChanged: (val) async {
                  if (val == '') {
                    mainQuery = FirebaseFirestore.instance
                        .collection('dishes')
                        .orderBy('date', descending: true);
                  } else {
                    mainQuery = FirebaseFirestore.instance
                        .collection('dishes')
                        .where('name', isEqualTo: val)
                        .orderBy('name', descending: true);
                  }
                  setState(() {});
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        mainQuery = FirebaseFirestore.instance
                            .collection('dishes')
                            .orderBy('date', descending: true);
                        setState(() => searchController.clear());
                      },
                    ),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.black, size: 35),
                    hintText: 'Search Dish',
                    hintStyle: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1),
                        fontSize:
                            ScreenUtil().setSp(18, allowFontScalingSelf: true)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(237, 237, 237, 1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(237, 237, 237, 1))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(237, 237, 237, 1))),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(237, 237, 237, 1))),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(237, 237, 237, 1)))),
              ),
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
            child: StreamBuilder(
              stream: Stream.value(mainQuery),
              builder: (context, AsyncSnapshot<Query> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Container();
                if (snapshot.connectionState == ConnectionState.done)
                  return PaginateFirestore(
                    itemsPerPage: 20,
                    itemBuilderType: PaginateBuilderType.gridView,
                    query: snapshot.data,
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
                                    fit: BoxFit.cover,
                                    image: NetworkImage(dish.imageURL))),
                            child: Center(
                              child: Text(dish.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            )),
                      );
                    },
                  );
              },
            ))
      ])),
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
