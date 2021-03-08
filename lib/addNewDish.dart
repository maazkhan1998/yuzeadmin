import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebasestorage;

class AddDish extends StatefulWidget {
  @override
  _AddDishState createState() => _AddDishState();
}

class _AddDishState extends State<AddDish> {
  File image = null;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  bool isLoading = false;
  bool isLunch = false;
  bool isDinner = false;
  bool isBreakfast = false;
  bool isDessert = false;

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/yuze.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      image = compressedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add New Dish'),
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
                        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                        sourcePath: pickedFile.path,
                        maxHeight: 3120,
                        maxWidth: 4160,
                        aspectRatioPresets: Platform.isAndroid
                            ? [
                                CropAspectRatioPreset.original,
                                CropAspectRatioPreset.ratio3x2,
                                CropAspectRatioPreset.square,
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
                        ? Center(
                            child: Text('Please choose an image',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          )
                        : Image.file(image,
                            width: double.infinity,
                            height: ScreenUtil().setHeight(200),
                            fit: BoxFit.cover)),
              ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Dish Name'),
              ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              TextField(
                controller: creditController,
                decoration: InputDecoration(hintText: 'Credits'),
              ),
              SizedBox(height: ScreenUtil().setHeight(20)),
              TextField(
                controller: linkController,
                decoration: InputDecoration(hintText: 'Link'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                value: isBreakfast,
                onChanged: (val) => setState(() => isBreakfast = val),
                title: Text('is Breakfast?'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                value: isLunch,
                onChanged: (val) => setState(() => isLunch = val),
                title: Text('is Lunch?'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                value: isDinner,
                onChanged: (val) => setState(() => isDinner = val),
                title: Text('is Dinner?'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                value: isDessert,
                onChanged: (val) => setState(() => isDessert = val),
                title: Text('is Dessert?'),
              ),
              SizedBox(height: ScreenUtil().setHeight(150))
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: keyboardIsOpened
          ? null
          : GestureDetector(
              onTap: () async {
                if (image == null)
                  return Fluttertoast.showToast(
                      msg: 'Choose an image', gravity: ToastGravity.CENTER);
                if (nameController.text.isEmpty)
                  return Fluttertoast.showToast(
                      msg: 'Add dish name', gravity: ToastGravity.CENTER);
                if (linkController.text.isNotEmpty &&
                    creditController.text.isEmpty)
                  return Fluttertoast.showToast(
                      msg: 'Add a credit to add a link',
                      gravity: ToastGravity.CENTER);
                setState(() => isLoading = true);
                final String id = DateTime.now().toIso8601String();
                await compressImage();
                final ref = await firebasestorage.FirebaseStorage.instance
                    .ref()
                    .child('dishes')
                    .child(id)
                    .putFile(image);
                String imageURL = await ref.ref.getDownloadURL();

                FirebaseFirestore.instance.collection('dishes').doc(id).set({
                  'name': nameController.text,
                  'imageURL': imageURL,
                  'date': DateTime.now().toIso8601String(),
                  'credit': creditController.text.isEmpty
                      ? ''
                      : creditController.text,
                  'isLunch': isLunch,
                  'isDinner': isDinner,
                  'isBreakfast': isBreakfast,
                  'isDessert': isDessert,
                  'link':
                      linkController.text.isEmpty ? null : linkController.text
                });

                Navigator.of(context).pop();
              },
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
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
                            'Add Dish',
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
