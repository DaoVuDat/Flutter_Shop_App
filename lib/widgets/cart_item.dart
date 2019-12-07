import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id, this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text("Do you want to remove the item from the cart?"),
            actions: <Widget>[
              FlatButton(child: Text("No"), onPressed: (){
                // ctx not context because this AlertDialog belongs to context of showDialog
                Navigator.of(ctx).pop(false); // this return false value to confirmDismiss = false => not activate onDismissed
              },),
              FlatButton(child: Text("Yes"), onPressed: (){
                Navigator.of(ctx).pop(true); 
              },),
            ],
          ),
        );
      },
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$${price}'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(quantity * price)}'),
            trailing: Text("$quantity x"),
          ),
        ),
      ),
    );
  }
}
