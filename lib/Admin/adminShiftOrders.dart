import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Admin/adminOrderCard.dart';
import 'package:r_r/Config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/orderCard.dart';

class AdminShiftOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<AdminShiftOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
          stream: FirebaseFirestore.instance.collection("orders").snapshots(),
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
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("items")
                            .where("shortInfo", whereIn: productIDs)
                            .get(),
                        builder: (c, snap) {
                          if (snap.hasData) {
                            List<QueryDocumentSnapshot> docs = snap.data!.docs;
                            print(docs);
                            final Map<String, dynamic>? docData =
                                docs[index].data() as Map<String, dynamic>?;
                            final String? orderBy =
                                docData?["orderBy"] as String?;
                            final String? addressID =
                                docData?["addressID"] as String?;
                            return AdminOrderCard(
                              key: UniqueKey(),
                              itemCount: docs.length,
                              data: docs,
                              orderID: snapshot.data!.docs[index].id,
                              orderBy: orderBy ?? "",
                              addressID: addressID ?? "",
                            );
                          } else {
                            return Text("Invalid index");
                          }
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
