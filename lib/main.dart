import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talkrr/pages/CompleteProfile.dart';
import 'package:talkrr/pages/HomePage.dart';
import 'package:talkrr/pages/LogInPage.dart';
import 'package:talkrr/pages/SignUpPage.dart';

import 'models/FirebaseHelper.dart';
import 'models/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {
    //Logged In
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById
    (currentUser.uid);
    if(thisUserModel != null) {
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: 
      currentUser));
    }
    
  }
  else {
    //Not Logged In
    runApp(MyApp());
  }
}

//NOT LOGGED IN
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

//ALREADY LOGGED IN
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.
  firebaseUser}) : super(key: key);
   
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel:userModel, firebaseUser: firebaseUser),
    );
  }
}