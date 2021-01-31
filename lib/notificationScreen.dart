import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setHeight(10)),
              child: Column(
                children: [
                  Text(
                    'Send New Notication',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(30)),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: 'Notification Title'),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  TextField(
                    controller: bodyController,
                    decoration: InputDecoration(hintText: 'Notification Body'),
                  )
                ],
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (titleController.text.isEmpty)
            return Fluttertoast.showToast(
                msg: 'Enter title', gravity: ToastGravity.CENTER);
          if (bodyController.text.isEmpty)
            return Fluttertoast.showToast(
                msg: 'Enter body', gravity: ToastGravity.CENTER);
          setState(() => isLoading = true);
          try {
            await FirebaseFirestore.instance.collection('notification').add(
                {'title': titleController.text, 'body': bodyController.text});
            setState(() => isLoading = false);
            return Fluttertoast.showToast(
                msg: 'Notification Sent', gravity: ToastGravity.CENTER);
          } catch (e) {
            setState(() => isLoading = false);
            return Fluttertoast.showToast(
                msg: e.toString(), gravity: ToastGravity.CENTER);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
          child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: ScreenUtil().setHeight(50),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(40),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : Text(
                      'Send Notification',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )),
        ),
      ),
    );
  }
}
