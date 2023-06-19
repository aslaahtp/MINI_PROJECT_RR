import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Config/config.dart';
import 'package:r_r/Address/address.dart';
import 'package:r_r/Widgets/customAppBar.dart';
import 'package:r_r/Widgets/loadingWidget.dart';
import 'package:r_r/Models/item.dart';
import 'package:r_r/Counters/cartitemcounter.dart';
import 'package:r_r/Counters/totalMoney.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:r_r/Store/storehome.dart';
import 'package:provider/provider.dart';
import 'package:r_r/Widgets/myDrawer.dart';
import '../main.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmound = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalAmound = 0.0;
    Provider.of<TotalAmount>(context, listen: false).displayResult(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (EcommerceApp.sharedPreferences!
                  .getStringList(EcommerceApp.userCartList)
                  ?.length ==
              1) {
            Fluttertoast.showToast(msg: "Your cart is empty");
          } else {
            Route route = MaterialPageRoute(
              builder: (c) => Address(
                totalAmount: totalAmound,
                key: UniqueKey(),
              ),
            );
            Navigator.pushReplacement(context, route);
          }
        },
        label: Text("Check Out"),
        backgroundColor: Colors.pink,
        icon: Icon(Icons.navigate_next),
      ),
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
                builder: (context, amountProvider, cartProvider, c) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: cartProvider.count == 0
                      ? Container()
                      : Text(
                          "Total Price:Rs ${amountProvider.totalAmount.toString()}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ),
                ),
              );
            }),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: EcommerceApp.firestore
                ?.collection("items")
                .where("shortInfo",
                    whereIn: EcommerceApp.sharedPreferences
                        ?.getStringList(EcommerceApp.userCartList))
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          ItemModel model = ItemModel.fromJson(
                              snapshot.data?.docs[index].data()
                                  as Map<String, dynamic>);

                          if (index == 0) {
                            totalAmound = 0.0;
                            totalAmound = model.price + totalAmound;
                          } else {
                            totalAmound = model.price + totalAmound;
                          }
                          if ((snapshot.data?.docs.length)! - 1 == index) {
                            WidgetsBinding.instance.addPostFrameCallback((t) {
                              Provider.of<TotalAmount>(context, listen: false)
                                  .displayResult(totalAmound as double);
                            });
                          }
                          return sourceInfo(model, context,
                              removeCartFunction: () =>
                                  removeItemFromUserCart(model.shortInfo),
                              background: Colors.yellow);
                        },
                        childCount:
                            snapshot.hasData ? snapshot.data!.docs.length : 0,
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  beginBuildingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_emoticon,
                color: Colors.white,
              ),
              Text("Cart is empty"),
              Text("Start adding items to cart"),
            ],
          ),
        ),
      ),
    );
  }

  removeItemFromUserCart(String shortInfoAsId) {
    List<String>? tempcartList = EcommerceApp.sharedPreferences
        ?.getStringList(EcommerceApp.userCartList);
    tempcartList?.remove(shortInfoAsId);

    EcommerceApp.firestore
        ?.collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences!.getString(EcommerceApp.userUID))
        .update({
      EcommerceApp.userCartList: tempcartList,
    }).then((v) {
      Fluttertoast.showToast(msg: "Item removed succesfully");

      EcommerceApp.sharedPreferences
          ?.setStringList(EcommerceApp.userCartList, tempcartList!);

      Provider.of<CartItemCounter>(context, listen: false).displayResult();

      totalAmound = 0;
    });
  }
}
