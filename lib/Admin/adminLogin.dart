import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Admin/uploadItems.dart';
import 'package:r_r/Authentication/authenication.dart';
import 'package:r_r/Widgets/customTextField.dart';
import 'package:r_r/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          color: Colors.green,
        ),
        title: Text(
          "Rural Reach",
          style: TextStyle(
            fontSize: 35.0,
          ),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _adminIDTextEditingController =
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
        color: Colors.white10,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child:
                  Image.asset("images/admin.png", height: 240.0, width: 240.0),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "SELLER LOGIN",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    key: Key('emailField'),
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "id",
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
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Set the desired background color
              ),
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty &&
                        _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                              key: UniqueKey(), message: "write email and pw");
                        });
              },
              child: Text("Sign in"),
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
              height: 20.0,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuthenticScreen())),
                child: Text("Im not a Seller")
                //icon: (Icon(Icons.nature_people,color: Colors.white,)),
                )
          ],
        ),
      ),
    );
  }

  void loginAdmin() {
    FirebaseFirestore.instance.collection("admins").get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if (result.data()["id"] != _adminIDTextEditingController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Your ID is not correct")),
          );
        } else if (result.data()["password"] !=
            _passwordTextEditingController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Your password is not correct")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome, dear admin, " + result.data()["name"]),
            ),
          );

          setState(() {
            _adminIDTextEditingController.text = "";
            _passwordTextEditingController.text = "";
          });

          Route route = MaterialPageRoute(builder: (c) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }

// loginAdmin() {
  //   FirebaseFirestore.instance.collection("admins").get().then((snapshot){
  //     snapshot.docs.forEach(result){
  //       if (result.data["id"] != _adminIDTextEditingController.text.trim()) {
  //         Scaffold.of(context).showSnackBar(
  //             SnackBar(content: Text(" your id is not correct"),));
  //       }
  //       else if (result.data["password"] !=
  //           _passwordTextEditingController.text.trim) {
  //         Scaffold.of(context).showSnackbar(
  //             SnackBar(content: Text(" Your password is not correct"),));
  //       }
  //       else {
  //         Scaffold.of(context).showSnackbar(SnackBar(
  //           content: Text(" Welcome dear admin," + result.data()["name"]),));
  //
  //         setState(() {
  //           _adminIDTextEditingController.text = "";
  //           _passwordTextEditingController.text = "";
  //         });
  //
  //         Route route = MaterialPageRoute(builder: (c) => UploadPage());
  //         Navigator.pushReplacement(context, route);
  //       }
  //
  //
  //
  //
  //
  //
  //     });
  //
  //   });
  //
  //
  //
  //
  //
  //
  //
  //  }
}
