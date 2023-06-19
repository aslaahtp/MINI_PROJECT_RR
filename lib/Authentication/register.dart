//import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:r_r/Widgets/customTextField.dart';
import 'package:r_r/DialogBox/errorDialog.dart';
import 'package:r_r/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:r_r/Config/config.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _cpasswordTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile = File('');
  var isSelected = false;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 10.0,
            ),
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenWidth * 0.15,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("images/admin.png"),
                foregroundImage: isSelected
                    ? FileImage(_imageFile) as ImageProvider<Object>
                    : AssetImage("images/admin.png"),
                child: _imageFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: _screenWidth * 0.15,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    key: Key('nameField'),
                    controller: _nameTextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
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
                  CustomTextField(
                    key: Key('cpasswordField'),
                    controller: _cpasswordTextEditingController,
                    data: Icons.person,
                    hintText: "Confirm password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Set the desired background color
              ),
              onPressed: () {
                uploadAndSaveImage();
              },
              child: Text("Sign up"),
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    final picker = ImagePicker();
    final filename = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(filename!.path);
      isSelected = true;
    });
  }

  Future<void> uploadAndSaveImage() async {
    print("inside else");
    _passwordTextEditingController.text == _cpasswordTextEditingController.text
        ? _emailTextEditingController.text.isNotEmpty &&
                _passwordTextEditingController.text.isNotEmpty &&
                _cpasswordTextEditingController.text.isNotEmpty &&
                _nameTextEditingController.text.isNotEmpty
            ? uploadToStorage()
            : displayDialog("Please fill form completely")
        : displayDialog("Password do not match");
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(key: UniqueKey(), message: msg);
        });
  }

  uploadToStorage() async {
    if (!isSelected) {
      print("inside if");
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
                key: UniqueKey(), message: "Please select image file");
          } //Uniqe key added by aslah
          );
    } else {
      print("inside upload");
      showDialog(
          context: context,
          builder: (c) {
            return LoadingAlertDialog(
                key: UniqueKey(), message: 'Registering, Please wait.....');
          });
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child("profile-pic/$imageFileName");
      UploadTask storageUploadTask = storageReference.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await storageUploadTask;
      await taskSnapshot.ref.getDownloadURL().then((urlImage) {
        setState(() {
          userImageUrl = urlImage;
        });

        _registerUser();
      });
    }
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async {
    User? firebaseUser;
    await _auth
        .createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((auth) {
      firebaseUser = auth.user;
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
      saveUserInfoToFireStore(firebaseUser!).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserInfoToFireStore(User fUser) async {
    FirebaseFirestore.instance.collection("users").doc(fUser.uid).set({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameTextEditingController.text.trim(),
      "url": userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"]
    });
    await EcommerceApp.sharedPreferences?.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences
        ?.setString(EcommerceApp.userEmail, fUser.email!);
    await EcommerceApp.sharedPreferences
        ?.setString(EcommerceApp.userName, _nameTextEditingController.text);
    await EcommerceApp.sharedPreferences
        ?.setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences
        ?.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}
