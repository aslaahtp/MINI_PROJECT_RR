import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:r_r/Config/config.dart';
import 'package:r_r/Store/storehome.dart';
import 'package:r_r/Counters/cartitemcounter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_r/main.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final double totalAmount;
  const PaymentPage({
    required Key key,
    required this.addressId,
    required this.totalAmount,
  }) : super(key: key);
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset("images/cash.png"),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the background color
                  onPrimary: Colors.white, // Set the text color
                  padding: EdgeInsets.all(8.0),
                  onSurface: Colors.lightGreenAccent, // Set the splash color
                ),
                onPressed: () => addOrderDetails(),
                child: Text(
                  "Place Order",
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addOrderDetails() {
    writeOrderDetailsForUser({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy":
          EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences
          ?.getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Cash on delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    });

    writeOrderDetailsForAdmin({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy":
          EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences
          ?.getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Cash on delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    }).whenComplete(() => emptyCartNow());
  }

  emptyCartNow() {
    EcommerceApp.sharedPreferences
        ?.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
    List<String>? tempList = EcommerceApp.sharedPreferences
        ?.getStringList(EcommerceApp.userCartList);

    FirebaseFirestore.instance
        .collection("users")
        .doc(EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID))
        .update({
      EcommerceApp.userCartList: tempList,
    }).then((value) {
      EcommerceApp.sharedPreferences
          ?.setStringList(EcommerceApp.userCartList, tempList!);
      Provider.of<CartItemCounter>(context, listen: false).displayResult();
    });
    Fluttertoast.showToast(msg: "Order Placed Succesfully");
    Route route = MaterialPageRoute(builder: (c) => SplashScreen());
    Navigator.pushReplacement(context, route);
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    final userUID =
        EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID);
    final orderTime = data['orderTime'].toString();
    if (userUID != null) {
      await EcommerceApp.firestore
          ?.collection(EcommerceApp.collectionUser)
          .doc(userUID)
          .collection(EcommerceApp.collectionOrders)
          .doc(userUID + orderTime)
          .set(data);
    }
  }

  Future writeOrderDetailsForAdmin(Map<String, dynamic> data) async {
    final userUID =
        EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID);
    final orderTime = data['orderTime'].toString();
    if (userUID != null) {
      await EcommerceApp.firestore
          ?.collection(EcommerceApp.collectionOrders)
          .doc(userUID + orderTime)
          .set(data);
    }
  }
}
