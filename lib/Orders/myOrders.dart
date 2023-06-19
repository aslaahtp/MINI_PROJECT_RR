import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:r_r/Config/config.dart';
import 'package:flutter/services.dart';
import '../Store/storehome.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/orderCard.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (c) => StoreHome());
              Navigator.pushReplacement(context, route);
            },
          ),
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(),
          centerTitle: true,
          title: Text(
            "My Orders",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: EcommerceApp.firestore
              ?.collection(EcommerceApp.collectionUser)
              .doc(EcommerceApp.sharedPreferences
                  ?.getString(EcommerceApp.userUID))
              .collection(EcommerceApp.collectionOrders)
              .snapshots(),
          builder: (c, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (c, index) {
                      var data = snapshot.data?.docs[index].data()
                          as Map<String, dynamic>;
                      var productIDs = <dynamic>[]; // Initialize an empty list
                      for (var i = 1;
                          i < data[EcommerceApp.productID].length;
                          i++) {
                        productIDs.add(data[EcommerceApp.productID]
                            [i]); // Add each value to the list
                      }
                      //log("suiiiii${data}");
                      // var i = 1;
                      print(data[EcommerceApp.productID].length);
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("items")
                            .where("shortInfo", whereIn: productIDs)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            List<QueryDocumentSnapshot> docs =
                                snapshot.data!.docs;
                            // docs.add(value)
                            // print(docs[0].data());
                            // print(data[EcommerceApp.productID].length);
                            // print(snapshot.data!.docs);
                            // print(i);
                            //if (index < snapshot.data!.docs.length) {
                            return OrderCard(
                              key: UniqueKey(),
                              itemCount: docs.length,
                              data: docs,
                              orderID: docs[index].id,
                            );
                          } else {
                            return Text("Invalid index");
                          }
                          //} else {
                          //return Center(child: circularProgress());
                          //}
                        },
                      );
                    },
                  )
                : Center();
          },
        ),
      ),
    );
  }
}
