// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talkrr/pages/CompleteProfile.dart';
// import 'package:flutter/scheduler.dart';

import '../models/UserModel.dart';
// import 'CompleteProfile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  
  // get password => null;

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email == "" || password == "" || cPassword == ""){
      print("Please fill all the fields!");
    }
    else if(password != cPassword) {
      print("Passwords do no match!");
    }
    else{
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    try{
      credential = await FirebaseAuth.instance.
      createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      print(ex.message.toString());
    }

    if(credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: ""
      );
      
      await FirebaseFirestore.instance.collection("users").doc(uid).set
      (newUser.toMap()).then((value) {
        print("Created New User!");
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!);
        }));
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                  Text("Talkkr", style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 45,
                    fontWeight: FontWeight.bold
                  ),),

                  SizedBox(height: 10,),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email"
                  ),
                ),

                SizedBox(height: 10,),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password"
                  ),
                 ),

                 SizedBox(height: 10,),

                TextField(
                  controller: cPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password"
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
             ),
            )
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
            Text("Already have an account?"),

            CupertinoButton(
              onPressed:() {
                Navigator.pop(context);
              },
              child: Text("Log In", style: TextStyle(
               fontSize: 16
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
  
