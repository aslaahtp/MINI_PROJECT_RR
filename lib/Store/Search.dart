import 'dart:async';

import 'package:r_r/Models/item.dart';
import 'package:r_r/Store/storehome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/customAppBar.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => new _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  Completer<QuerySnapshot<Object?>> completer =
      Completer<QuerySnapshot<Object?>>();
  late Future<QuerySnapshot<Object?>> docList = completer.future;

// Initializing with a dummy value
//   completer.complete(QuerySnapshot<Object?>(docs: []));
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (c) => StoreHome());
              Navigator.pushReplacement(context, route);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: TextField(
                        onChanged: (value) {
                          startSearching(value);
                        },
                        decoration:
                            InputDecoration.collapsed(hintText: "Search here"),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: FutureBuilder<QuerySnapshot>(
                future: docList,
                builder: (context, snap) {
                  print(docList);
                  return snap.hasData
                      ? ListView.builder(
                          itemCount: snap.data!.docs.length,
                          itemBuilder: (context, index) {
                            ItemModel model = ItemModel.fromJson(snap.data
                                ?.docs[index].data as Map<String, dynamic>);
                            return sourceInfo(model, context,
                                background: Colors.white);
                          },
                        )
                      : Text("No data Available");
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future startSearching(String query) async {
    docList = FirebaseFirestore.instance
        .collection("items")
        .where("shortInfo", isGreaterThanOrEqualTo: query)
        .get() as Future<QuerySnapshot>;
  }
}

Widget buildResultCard(data) {
  return Card();
}
