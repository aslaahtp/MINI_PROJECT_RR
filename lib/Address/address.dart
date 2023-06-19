import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Config/config.dart';
import 'package:r_r/Orders/placeOrderPayment.dart';
import 'package:r_r/Widgets/customAppBar.dart';
import 'package:r_r/Widgets/loadingWidget.dart';
import 'package:r_r/Widgets/wideButton.dart';
import 'package:r_r/Models/address.dart';
import 'package:r_r/Counters/changeAddresss.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'addAddress.dart';

class Address extends StatefulWidget {
  final double totalAmount = 0.0;
  const Address({required Key key, required double totalAmount})
      : super(key: key);
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Scaffold(
          appBar: MyAppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Select Address",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Consumer<AddressChanger>(builder: (context, address, c) {
                return Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: EcommerceApp.firestore
                        ?.collection(EcommerceApp.collectionUser)
                        .doc(EcommerceApp.sharedPreferences
                            ?.getString(EcommerceApp.userUID))
                        .collection(EcommerceApp.subCollectionAddress)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return !snapshot.hasData
                          ? Center(
                              child: circularProgress(),
                            )
                          : snapshot.data?.docs.length == 0
                              ? noAddressCard()
                              : ListView.builder(
                                  itemCount: snapshot.data?.docs.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    //print(snapshot.data!.docs[index].data);
                                    return AddressCard(
                                      currentIndex: address.count,
                                      value: index,
                                      addressId: snapshot.data?.docs[index].id
                                          as String,
                                      totalAmount: widget.totalAmount,
                                      model: AddressModel.fromJson(
                                          snapshot.data?.docs[index].data()
                                              as Map<String, dynamic>),
                                      /*model: AddressModel.fromJson(
                                          snapshot.data!.docs[index].data()
                                              as Map<String, dynamic>),*/
                                      key: UniqueKey(),
                                    );
                                  },
                                );
                    },
                  ),
                );
              }),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
              label: Text("Add New Address"),
              backgroundColor: Colors.green,
              icon: Icon(Icons.add_location),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => AddAddress());
                Navigator.pushReplacement(context, route);
              }),
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: Colors.pink.withOpacity(0.5),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location,
              color: Colors.white,
            ),
            Text("No address has been saved."),
            Text("Please add your Address so that we can deliver product."),
          ],
        ),
      ),
    );
  }
}

AddressModel dummyAddress = AddressModel(
  name: "John Doe",
  phoneNumber: "1234567890",
  homeName: "Dummy Home",
  place: "Dummy Place",
  city: "Dummy City",
  pinCode: "12345",
);

class AddressCard extends StatefulWidget {
  AddressModel model = dummyAddress;
  String addressId = "";
  double totalAmount = 0.0;
  int currentIndex = 0;
  int value = 0;

  // AddressCard({required Key key,required this.model,required this.currentIndex,required this.addressId,required this.totalAmount,required this.value}):super=(key:key);
  AddressCard({
    required Key key,
    required this.model,
    required this.currentIndex,
    required this.addressId,
    required this.totalAmount,
    required this.value,
  }) : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false)
            .displayResult(widget.value);
      },
      child: Card(
        color: Colors.pinkAccent.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  activeColor: Colors.pink,
                  value: widget.value,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false)
                        .displayResult(val!);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Name",
                                key: Key('1231'),
                              ),
                              Text(widget.model.name),
                            ],
                          ),
                          TableRow(children: [
                            KeyText(
                              msg: "Phone number",
                              key: UniqueKey(),
                            ),
                            Text(widget.model.phoneNumber),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Home name",
                              key: UniqueKey(),
                            ),
                            Text(widget.model.homeName),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Place",
                              key: UniqueKey(),
                            ),
                            Text(widget.model.place),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "City",
                              key: UniqueKey(),
                            ),
                            Text(widget.model.city),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
                ? WideButton(
                    message: "Proceed",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (c) => PaymentPage(
                                addressId: widget.addressId,
                                totalAmount: widget.totalAmount,
                                key: UniqueKey(),
                              ));
                      Navigator.push(context, route);
                    },
                    key: UniqueKey(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;
  const KeyText({required Key key, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
