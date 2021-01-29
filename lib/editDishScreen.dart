import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodsuggestionadmin/dish.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebasestorage;

class EditDishScreen extends StatefulWidget {
  Dish dish;

  EditDishScreen({@required this.dish});
  @override
  _EditDishScreenState createState() => _EditDishScreenState();
}

class _EditDishScreenState extends State<EditDishScreen> {
  File image = null;
  final picker = ImagePicker();
  TextEditingController nameController;
  bool isLoading = false;

  initState() {
    nameController = TextEditingController(text: widget.dish.name);
    super.initState();
  }

  deleteDialg(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Delete Dish'),
              content: Text('Are you sure you want to delete this dish?'),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('dishes')
                        .doc(widget.dish.id)
                        .delete();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    firebasestorage.FirebaseStorage.instance
                        .ref()
                        .child('dishes')
                        .child(widget.dish.id)
                        .delete();
                  },
                  child: Text('Yes'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.dish.name),
          actions: [
            IconButton(
              onPressed: () {
                deleteDialg(context);
              },
              icon: Icon(Icons.delete, color: Colors.red, size: 30),
            )
          ],
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setHeight(20),
                horizontal: ScreenUtil().setWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await picker.getImage(
                        source: ImageSource.gallery,
                        maxHeight: 3120,
                        maxWidth: 4160);
                    if (pickedFile != null) {
                      File croppedFile = await ImageCropper.cropImage(
                          sourcePath: pickedFile.path,
                          maxHeight: 3120,
                          maxWidth: 4160,
                          aspectRatioPresets: Platform.isAndroid
                              ? [
                                  CropAspectRatioPreset.square,
                                  CropAspectRatioPreset.ratio3x2,
                                  CropAspectRatioPreset.original,
                                  CropAspectRatioPreset.ratio4x3,
                                  CropAspectRatioPreset.ratio16x9
                                ]
                              : [
                                  CropAspectRatioPreset.original,
                                  CropAspectRatioPreset.square,
                                  CropAspectRatioPreset.ratio3x2,
                                  CropAspectRatioPreset.ratio4x3,
                                  CropAspectRatioPreset.ratio5x3,
                                  CropAspectRatioPreset.ratio5x4,
                                  CropAspectRatioPreset.ratio7x5,
                                  CropAspectRatioPreset.ratio16x9
                                ],
                          androidUiSettings: AndroidUiSettings(
                              toolbarTitle: 'Cropper',
                              toolbarColor: Colors.deepOrange,
                              toolbarWidgetColor: Colors.white,
                              initAspectRatio: CropAspectRatioPreset.original,
                              lockAspectRatio: false),
                          iosUiSettings: IOSUiSettings(
                            title: 'Cropper',
                          ));
                      if (croppedFile != null) {
                        image = croppedFile;
                        setState(() {});
                      } else {
                        image = File(pickedFile.path);
                        setState(() {});
                      }
                    } else {
                      print('No image selected.');
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      height: ScreenUtil().setHeight(35),
                      width: double.infinity,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Text('Choose Image',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600))),
                ),
                SizedBox(height: ScreenUtil().setHeight(25)),
                Center(
                  child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1)),
                      child: image == null
                          ? Image.network(widget.dish.imageURL,
                              width: double.infinity,
                              height: ScreenUtil().setHeight(200),
                              fit: BoxFit.cover)
                          : Image.file(image,
                              width: double.infinity,
                              height: ScreenUtil().setHeight(200),
                              fit: BoxFit.cover)),
                ),
                SizedBox(height: ScreenUtil().setHeight(20)),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Dish Name'),
                )
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: keyboardIsOpened
            ? null
            : GestureDetector(
                onTap: () async {
                  if (nameController.text.isEmpty)
                    return Fluttertoast.showToast(
                        msg: 'Add dish name', gravity: ToastGravity.CENTER);
                  String imageURL;
                  setState(() => isLoading = true);
                  if (image != null) {
                    final ref = await firebasestorage.FirebaseStorage.instance
                        .ref()
                        .child('dishes')
                        .child(widget.dish.id)
                        .putFile(image);
                    imageURL = await ref.ref.getDownloadURL();
                  }
                  FirebaseFirestore.instance
                      .collection('dishes')
                      .doc(widget.dish.id)
                      .set({
                    'name': nameController.text,
                    'imageURL': image == null ? widget.dish.imageURL : imageURL
                  });

                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20)),
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
                              'Update Dish',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            )),
                ),
              ));
  }
}