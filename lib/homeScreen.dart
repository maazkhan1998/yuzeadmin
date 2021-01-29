import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:foodsuggestionadmin/addNewDish.dart';
import 'package:foodsuggestionadmin/dish.dart';
import 'package:foodsuggestionadmin/editDishScreen.dart';

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
        title:Text('All Dishes',)
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal:ScreenUtil().setWidth(10),vertical:ScreenUtil().setHeight(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('dishes').snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot>snapshot){
                if(snapshot.connectionState==ConnectionState.waiting) return Center(child:CircularProgressIndicator());
                if(snapshot.data.docs.length==0) return Center(child:Text('No Dishes, start adding some',style: TextStyle(
                  color:Colors.black
                ),));

                return Container(
                  width: ScreenUtil().setWidth(411),
                  child: Wrap(
                    direction: Axis.horizontal,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    children: List.generate(snapshot.data.docs.length,(index){
                      final dish=Dish.fromDocument(snapshot.data.docs[index]);
                      return GestureDetector(
                        onTap: ()=>Navigator.push(context,
          CupertinoPageRoute(
            builder: (context)=>EditDishScreen(
              dish: dish,
            )
          )
        ),
                                              child: Container(
                        width: 190,height:190,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(dish.imageURL)
                          )
                        ),
                        child:Center(
                          child: Text(dish.name,style:TextStyle(
                            color:Colors.white,fontSize:18,fontWeight: FontWeight.w600                      )),
                        )
                    ),
                      );
                    }),
                  ),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>Navigator.push(context,
          CupertinoPageRoute(
            builder: (context)=>AddDish()
          )
        ),
        child:Icon(Icons.add,size:30,color:Colors.white)
      ),
    );
  }
}