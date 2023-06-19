import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Admin/adminLogin.dart';
import 'package:r_r/Widgets/customTextField.dart';
import 'package:r_r/DialogBox/errorDialog.dart';
import 'package:r_r/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:r_r/Config/config.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child:
                  Image.asset("images/login.png", height: 240.0, width: 240.0),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "USER LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    key: Key('emailField'),
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    key: Key('passwordField'),
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xff53B175), // Set the desired background color
              ),
              onPressed: () {
                _emailTextEditingController.text.isNotEmpty &&
                        _passwordTextEditingController.text.isNotEmpty
                    ? loginUser()
                    : showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                              key: UniqueKey(), message: "write email and pw");
                        });
              },
              child: Container(
                color: Color(0xff53B175),
                height: 40,
                width: 80,
                child: Center(
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.green,
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xff53B175), // Set the desired background color
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminSignInPage())),
                child: Text("SELLER LOGIN")
                //icon: (Icon(Icons.nature_people,color: Colors.white,)),
                )
          ],
        ),
      ),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void loginUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
              key: UniqueKey(), message: "Authenticating wait...");
        });
    User? firebaseUser;
    await _auth
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((authUser) {
      firebaseUser = authUser.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              key: UniqueKey(),
              message: error.message.toString(),
            );
          });
    });
    if (firebaseUser != null) {
      readData(firebaseUser!).then((s) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future readData(User fUser) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(fUser.uid)
        .get()
        .then((dataSnapshot) async {
      final data = dataSnapshot.data?.call();
      if (data != null) {
        await EcommerceApp.sharedPreferences
            ?.setString("uid", data[EcommerceApp.userUID]);
        await EcommerceApp.sharedPreferences
            ?.setString(EcommerceApp.userEmail, data[EcommerceApp.userEmail]);
        await EcommerceApp.sharedPreferences
            ?.setString(EcommerceApp.userName, data[EcommerceApp.userName]);
        await EcommerceApp.sharedPreferences?.setString(
            EcommerceApp.userAvatarUrl, data[EcommerceApp.userAvatarUrl]);
        List<String> cartList = data[EcommerceApp.userCartList].cast<String>();
        await EcommerceApp.sharedPreferences
            ?.setStringList(EcommerceApp.userCartList, cartList);
      }
    });
  }
}
