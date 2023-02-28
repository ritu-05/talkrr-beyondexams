import "dart:convert";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:talkrr/pages/SignUpPage.dart";
import "../models/UserModel.dart";


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == "") {
      print("Please fill all the fields!");
    }
    else{
      logIn(email,password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword
      (email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      print(ex.message.toString());
    }

    if(credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.
      collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
    

      //Go to HomePage
      print("Log In Successfully!");
    }
  }

  Map<String, dynamic> newMethod(DocumentSnapshot<Object?> userData) {
    return userData.data() as
    Map<String, dynamic>;
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
                    hintText: "Email Address"
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

                 SizedBox(height: 20,),

                 CupertinoButton(
                   onPressed: () {
                    checkValues();
                   },
                   color: Theme.of(context).colorScheme.secondary,
                   child: Text("Log In"),
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
          
            Text("Don't have an account?"),

            CupertinoButton(
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpPage();
                    }
                  ),
                );
              },
              child: Text("Sign Up", style: TextStyle(
               fontSize: 16
              ),),
            ),
          ],
        ),
      ),
    );
  }
}