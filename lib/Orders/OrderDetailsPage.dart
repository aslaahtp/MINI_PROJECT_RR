import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:r_r/Config/config.dart';
import 'package:r_r/Store/storehome.dart';
import 'package:r_r/Widgets/loadingWidget.dart';
import 'package:r_r/Widgets/orderCard.dart';
import 'package:r_r/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Address/address.dart';
import '../main.dart';

String getOrderId = "";

class OrderDetails extends StatelessWidget {
  late final String orderID;
  OrderDetails({
    required Key key,
    required this.orderID,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    getOrderId = orderID;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
              future: EcommerceApp.firestore
                  ?.collection(EcommerceApp.collectionUser)
                  .doc(EcommerceApp.sharedPreferences
                      ?.getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.collectionOrders)
                  .doc(orderID)
                  .get(),
              builder: (c, snapshot) {
                Map<String, dynamic>? dataMap;
                if (snapshot.hasData) {
                  final data = snapshot.data?.data();
                  if (data != null && data is Map<String, dynamic>) {
                    dataMap = data;
                  }
                }
                return snapshot.hasData && dataMap != null
                    ? Container(
                        child: Column(
                          children: [
                            StatusBanner(
                              status: dataMap[EcommerceApp.isSuccess]!,
                              key: UniqueKey(),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "RS" +
                                      dataMap[EcommerceApp.totalAmount]
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text("Order ID:" + getOrderId),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Ordered at:" +
                                    DateFormat("dd MMMM,yyyy -hh:mm aa").format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(dataMap["orderTime"]))),
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                              ),
                            ),
                            Divider(
                              height: 2.0,
                            ),
                            FutureBuilder<QuerySnapshot>(
                                future: EcommerceApp.firestore
                                    ?.collection("items")
                                    .where("shortInfo",
                                        whereIn:
                                            dataMap[EcommerceApp.productID])
                                    .get(),
                                builder: (c, dataSnapshot) {
                                  // print(dataMap[EcommerceApp.productID]);
                                  return dataSnapshot.hasData
                                      ? OrderCard(
                                          itemCount:
                                              dataSnapshot.data?.docs.length ??
                                                  0,
                                          data: dataSnapshot.data?.docs as List<
                                              DocumentSnapshot<Object?>>,
                                          key: UniqueKey(),
                                          orderID: getOrderId,
                                        )
                                      : Center(
                                          child: circularProgress(),
                                        );
                                }),
                            Divider(
                              height: 2.0,
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: EcommerceApp.firestore
                                  ?.collection(EcommerceApp.collectionUser)
                                  .doc(EcommerceApp.sharedPreferences
                                      ?.getString(EcommerceApp.userUID))
                                  .collection(EcommerceApp.subCollectionAddress)
                                  .doc(dataMap[EcommerceApp.addressID])
                                  .get(),
                              builder: (c, snap) {
                                return snap.hasData
                                    ? ShippingDetails(
                                        model: AddressModel.fromJson(snap.data
                                            ?.data() as Map<String, dynamic>),
                                        key: UniqueKey(),
                                      )
                                    : Center(
                                        child: circularProgress(),
                                      );
                              },
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: circularProgress(),
                      );
              }),
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;
  StatusBanner({
    required Key key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msg = "";
    IconData iconData;
    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Successful" : msg = "Unsuccessful";
    return Container(
        height: 40.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  SystemNavigator.pop();
                },
                child: Container(
                  child: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.white,
                  ),
                )),
            SizedBox(
              width: 20.0,
            ),
            Text(
              "Order Placed" + msg,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 5.0,
            ),
            CircleAvatar(
              radius: 8.0,
              backgroundColor: Colors.grey,
              child: Center(
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 14.0,
                ),
              ),
            ),
          ],
        ));
  }
}

class ShippingDetails extends StatelessWidget {
  final AddressModel model;
  ShippingDetails({required Key key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Text(
            "Shipment Details:",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(
                children: [
                  KeyText(
                    msg: "Name",
                    key: Key('1231'),
                  ),
                  Text(model.name),
                ],
              ),
              TableRow(children: [
                KeyText(
                  msg: "Phone number",
                  key: UniqueKey(),
                ),
                Text(model.phoneNumber),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Home name",
                  key: UniqueKey(),
                ),
                Text(model.homeName),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Place",
                  key: UniqueKey(),
                ),
                Text(model.place),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "City",
                  key: UniqueKey(),
                ),
                Text(model.city),
              ]),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                confirmeduserOrderReceived(context, getOrderId);
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                child: Center(
                  child: Text(
                    "Confirmed,Items Received",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  confirmeduserOrderReceived(BuildContext context, String mOrderId) {
    EcommerceApp.firestore
        ?.collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences?.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders)
        .doc(mOrderId)
        .delete();
    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => SplashScreen());
    Navigator.pushReplacement(context, route);
    Fluttertoast.showToast(msg: "Order has been Received.confirmed.");
  }
}
