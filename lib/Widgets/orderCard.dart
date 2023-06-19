import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Orders/OrderDetailsPage.dart';
import 'package:r_r/Models/item.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';

int counter = 0;

class OrderCard extends StatelessWidget {
  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;

  const OrderCard(
      {required Key key,
      required this.itemCount,
      required this.data,
      required this.orderID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (counter == 0) {
          counter = counter + 1;
          Route route = MaterialPageRoute(
            builder: (c) => OrderDetails(
              orderID: orderID,
              key: UniqueKey(),
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

Widget sourceOrderInfo(ItemModel model, BuildContext context,
    {required Color background}) {
  width = MediaQuery.of(context).size.width;

  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
    child: Card(
      elevation: 4.0,
      child: Container(
        color: Colors.white10,
        height: 170.0,
        width: width,
        child: Row(
          children: [
            Image.network(
              model.thumbnailUrl,
              width: 180.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.shortInfo.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                              children: [
                                Text(
                                  "₹ " + (model.price).toString() + "/-",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Flexible(
                    child: Container(), //to remove cart items
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
