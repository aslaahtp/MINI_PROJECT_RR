import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_r/Admin/uploadItems.dart';
import 'package:r_r/Config/config.dart';
import 'package:r_r/Widgets/loadingWidget.dart';
import 'package:r_r/Widgets/orderCard.dart';
import 'package:r_r/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdminOrderDetails extends StatelessWidget {
  final String orderID;
  final String orderBy;
  final String addressID;
  AdminOrderDetails(
      {required Key key,
      required this.orderID,
      required this.orderBy,
      required this.addressID})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(),
    );
  }
}

class StatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PaymentDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ShippingDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class KeyText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("");
  }
}
