import 'package:flutter/material.dart';

import '../screens/order_screen.dart';

class AppDraw extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Hello Friend"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Order"),
            onTap: () => Navigator.of(context).pushReplacementNamed(OrderScreen.routeName),
          )
        ],
      ),
    );
  }
}
