import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Admin/adminOrderDetails.dart';
import 'package:r_r/Models/item.dart';
import 'package:flutter/material.dart';

import '../Models/item.dart';
import '../Store/storehome.dart';
import '../Widgets/orderCard.dart';

int counter = 0;

class AdminOrderCard extends StatelessWidget {
  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;
  final String addressID;
  final String orderBy;
  AdminOrderCard(
      {required this.itemCount,
      required this.data,
      required this.orderID,
      required this.addressID,
      required this.orderBy,
      required Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (counter == 0) {
          counter = counter + 1;
          Route route = MaterialPageRoute(
            builder: (c) => AdminOrderDetails(
              orderID: orderID, orderBy: orderBy, addressID: addressID,
              key: UniqueKey(),
              //key: UniqueKey(),
            ),
          );
          Navigator.push(context, route);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        height: itemCount * 190.0,
        child: ListView.builder(
            itemCount: itemCount,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, index) {
              ItemModel model = ItemModel.fromJson(
                  data[index].data() as Map<String, dynamic>);
              return sourceOrderInfo(model, context, background: Colors.white);
            }),
      ),
    );
  }
}
