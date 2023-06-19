import 'package:r_r/Config/config.dart';
import 'package:r_r/Widgets/customAppBar.dart';
import 'package:r_r/Models/address.dart';
import 'package:flutter/material.dart';

import '../Store/storehome.dart';

class AddAddress extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final cName = TextEditingController();
  final cPhoneNo = TextEditingController();
  final cHomeName = TextEditingController();
  final cPlace = TextEditingController();
  final cCity = TextEditingController();
  final cPinCode = TextEditingController();

  AddAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final model = AddressModel(
                        name: cName.text.trim(),
                        phoneNumber: cPhoneNo.text.trim(),
                        homeName: cHomeName.text.trim(),
                        place: cPlace.text.trim(),
                        city: cCity.text.trim(),
                        pinCode: cPinCode.text)
                    .toJson();
                EcommerceApp.firestore
                    ?.collection(EcommerceApp.collectionUser)
                    .doc(EcommerceApp.sharedPreferences
                        ?.getString(EcommerceApp.userUID))
                    .collection(EcommerceApp.subCollectionAddress)
                    .doc(DateTime.now().millisecondsSinceEpoch.toString())
                    .set(model)
                    .then((value) {
                  final snack =
                      SnackBar(content: Text("New Address Added Successfully"));
                  scaffoldKey.currentState?.showSnackBar(snack);
                  FocusScope.of(context).requestFocus(FocusNode());
                  formKey.currentState?.reset();
                });
                Route route = MaterialPageRoute(builder: (c) => StoreHome());
                Navigator.pushReplacement(context, route);
              }
            },
            backgroundColor: Colors.green,
            icon: Icon(Icons.check),
            label: Text("Done")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Add New Address",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                        key: UniqueKey(), hint: "Name", controller: cName),
                    MyTextField(
                        key: UniqueKey(),
                        hint: "Phone No",
                        controller: cPhoneNo),
                    MyTextField(
                        key: UniqueKey(),
                        hint: "Home Name",
                        controller: cHomeName),
                    MyTextField(
                        key: UniqueKey(), hint: "Place", controller: cPlace),
                    MyTextField(
                        key: UniqueKey(), hint: "City", controller: cCity),
                    MyTextField(
                        key: UniqueKey(),
                        hint: "PinCode",
                        controller: cPinCode),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const MyTextField(
      {required Key key, required this.hint, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val!.isEmpty ? "Field can not be Empty" : null,
      ),
    );
  }
}
