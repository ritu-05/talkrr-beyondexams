import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talkrr/models/UserModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talkrr/pages/HomePage.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  late File? imageFile;
  CroppedFile? finalFile = null;
  TextEditingController _fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    
    if(pickedFile != null){
      cropImage(pickedFile);
    }

  }

  void cropImage(XFile file) async {
    CroppedFile? cropperdImage = await ImageCropper().cropImage(
        sourcePath: file.path,
      compressQuality: 20
    );

    if(cropperdImage != null){
      setState(() {
        finalFile = cropperdImage;
      });
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilePictures").child(widget.userModel.uid.toString()).putFile(File(finalFile!.path));
    TaskSnapshot  snapshot = await uploadTask;
    String uploadedImageUrl = await snapshot.ref.getDownloadURL();
    String fullName = _fullNameController.text.trim();
    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = uploadedImageUrl;
    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){

      print("Data updated!");
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
      }));

    });
  }

  void checkValues(){
    String fullName = _fullNameController.text.trim();
    if(fullName == "" || finalFile == null){
      print("Please fill all the fields");
    }else{
      uploadData();
    }
  }

  
  
  void showPhotoOptions() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ListTile(
              onTap: () {
                Navigator.pop(context);
                  selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"), 
            ),

            ListTile(
              onTap: () {
                Navigator.pop(context);
                  selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"), 
            ),

          ],
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40
          ),
          child: ListView(
            children: [

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (finalFile!=null)?  FileImage(File(finalFile!.path)):null,
                  child: (finalFile==null)? Icon(Icons.person, size: 60,): null,
                ),
              ),

              SizedBox(height: 20,),

              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Sign Up"),
              ),
            ],
          ),        ),
      ),
    );
  }
}


