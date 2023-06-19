import 'package:r_r/Store/cart.dart';
import 'package:r_r/Counters/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_r/Store/storehome.dart';

import '../Config/config.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  //late PreferredSizeWidget bottom; // = Size(56, AppBar().preferredSize.height);
  //MyAppBar({required this.bottom);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Route route = MaterialPageRoute(builder: (c) => StoreHome());
          Navigator.pushReplacement(context, route);
        },
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      centerTitle: true,
      title: Text(
        "RURAL REACH",
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
      backgroundColor: Colors.green,
      //bottom:bottom,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => CartPage());
                Navigator.pushReplacement(context, route);
              },
            ),
            Positioned(
              child: Stack(
                children: [
                  Icon(
                    Icons.brightness_1,
                    color: Colors.orange,
                    size: 20,
                  ),
                  Positioned(
                    top: 3.0,
                    bottom: 4.0,
                    left: 6.5,
                    child: Consumer<CartItemCounter>(
                      builder: (context, counter, _) {
                        return Text(
                          ((EcommerceApp.sharedPreferences
                                      ?.getStringList(EcommerceApp.userCartList)
                                      ?.length)! -
                                  1)
                              .toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(56, AppBar().preferredSize.height);

  // Size get preferredSize => bottom == null
  //     ? Size(56, AppBar().preferredSize.height)
  //     : Size(56, 80 + AppBar().preferredSize.height);
}
